import test, { before, after } from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { Miniflare } from "miniflare";
import { authorizeActor } from "../src/index.js";
import { sha256Hex } from "../src/authorization.js";

const migrationFiles = [
  "../../migrations/0001_initial.sql",
  "../../migrations/0002_virtual_legal_advisor.sql",
  "../../migrations/0003_virtual_ai_role_catalogue.sql",
  "../../migrations/0004_virtual_ai_member_onboarding.sql",
  "../../migrations/0005_authorization_schema.sql"
];

let mf;
let db;
let rawSessionToken;
let revokedSessionToken;

async function seedFixtures() {
  await db.prepare(
    "INSERT INTO people (id, display_name, email, person_type, status) VALUES (?, ?, ?, 'human', 'active')"
  ).bind("test-human-ceo", "Disposable Test CEO", "test-ceo@integration.invalid").run();

  await db.prepare(
    "INSERT INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by) VALUES (?, ?, ?, 'company', NULL, ?)"
  ).bind("test-assignment-pmo", "test-human-ceo", "role-head-pmo", "test-human-ceo").run();

  await db.prepare(
    "INSERT INTO role_assignments (id, person_id, role_id, scope_type, scope_id, assigned_by) VALUES (?, ?, ?, 'company', NULL, ?)"
  ).bind("test-assignment-product", "test-human-ceo", "role-head-product", "test-human-ceo").run();

  await db.prepare(
    "INSERT INTO auth_users (id, person_id, auth_provider, provider_subject, account_status) VALUES (?, ?, 'email_otp', ?, 'active')"
  ).bind("test-auth-user", "test-human-ceo", "test-provider-subject").run();

  rawSessionToken = "integration-session-token-0123456789-abcdef";
  revokedSessionToken = "integration-revoked-session-token-0123456789";
  const tokenHash = await sha256Hex(rawSessionToken);
  const revokedHash = await sha256Hex(revokedSessionToken);

  await db.prepare(
    "INSERT INTO auth_sessions (id, auth_user_id, session_token_hash, expires_at) VALUES (?, ?, ?, datetime('now', '+1 hour'))"
  ).bind("test-session-active", "test-auth-user", tokenHash).run();

  await db.prepare(
    "INSERT INTO auth_sessions (id, auth_user_id, session_token_hash, expires_at, revoked_at) VALUES (?, ?, ?, datetime('now', '+1 hour'), CURRENT_TIMESTAMP)"
  ).bind("test-session-revoked", "test-auth-user", revokedHash).run();
}

before(async () => {
  mf = new Miniflare({
    modules: true,
    modulesRules: [{ type: "ESModule", include: ["**/*.js"] }],
    scriptPath: "./src/index.js",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-disposable-integration-db" }
  });
  db = await mf.getD1Database("DB");

  for (const file of migrationFiles) {
    const sql = await readFile(new URL(file, import.meta.url), "utf8");
    // D1 manages foreign-key enforcement itself and does not accept SQLite PRAGMA statements.
    const d1CompatibleSql = sql.replace(/^\\s*PRAGMA\\s+foreign_keys\\s*=\\s*ON\\s*;\\s*/gim, "");
    await db.exec(d1CompatibleSql);
  }

  await seedFixtures();
});

after(async () => {
  if (mf) await mf.dispose();
});

test("Cloudflare workerd D1 runtime replays migrations 0001-0005", async () => {
  const roles = await db.prepare("SELECT COUNT(*) AS count FROM roles").first();
  const people = await db.prepare("SELECT COUNT(*) AS count FROM people WHERE person_type='virtual' AND status='pending'").first();
  const permissions = await db.prepare("SELECT COUNT(*) AS count FROM permission_catalogue").first();

  assert.equal(roles.count, 41);
  assert.equal(people.count, 41);
  assert.equal(permissions.count, 60);
});

test("Worker /api/me rejects missing and revoked sessions and accepts active human session", async () => {
  const missing = await mf.dispatchFetch("https://cmd.test/api/me");
  assert.equal(missing.status, 401);

  const revoked = await mf.dispatchFetch("https://cmd.test/api/me", {
    headers: { Cookie: `__Host-cmd_session=${revokedSessionToken}` }
  });
  assert.equal(revoked.status, 401);

  const active = await mf.dispatchFetch("https://cmd.test/api/me", {
    headers: { Cookie: `__Host-cmd_session=${rawSessionToken}` }
  });
  assert.equal(active.status, 200);
  const body = await active.json();
  assert.equal(body.actor.id, "test-human-ceo");
  assert.equal(body.actor.type, "human");
});

test("authorizeActor allows only matching role permission and scope rows", async () => {
  await db.prepare(
    "INSERT INTO role_permission_rules (id, role_id, module_key, action_key, effect) VALUES (?, ?, 'PMO', 'read', 'allow')"
  ).bind("test-pmo-read-allow", "role-head-pmo").run();

  await db.prepare(
    "INSERT INTO role_scope_grants (id, role_assignment_id, module_key, scope_type, scope_id, grant_status, granted_by, granted_at) VALUES (?, ?, 'PMO', 'project', ?, 'active', ?, CURRENT_TIMESTAMP)"
  ).bind("test-pmo-scope-match", "test-assignment-pmo", "project-1", "test-human-ceo").run();

  const actor = { personId: "test-human-ceo", personType: "human", mfaVerifiedAt: null };
  const matching = await authorizeActor(
    db, actor,
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "integration-matching-scope"
  );
  assert.deepEqual(matching, { allowed: true, status: 200, reason: "scoped_allow" });

  await db.prepare("DELETE FROM role_scope_grants WHERE id='test-pmo-scope-match'").run();
  await db.prepare(
    "INSERT INTO role_scope_grants (id, role_assignment_id, module_key, scope_type, scope_id, grant_status, granted_by, granted_at) VALUES (?, ?, 'PMO', 'project', ?, 'active', ?, CURRENT_TIMESTAMP)"
  ).bind("test-pmo-scope-wrong-role", "test-assignment-product", "project-1", "test-human-ceo").run();

  const mismatched = await authorizeActor(
    db, actor,
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "integration-mismatched-role-scope"
  );
  assert.deepEqual(mismatched, { allowed: false, status: 403, reason: "no_matching_scoped_allow" });
});

test("authorizeActor enforces explicit deny and fresh MFA on sensitive modules", async () => {
  await db.prepare("DELETE FROM role_scope_grants WHERE id='test-pmo-scope-wrong-role'").run();
  await db.prepare("DELETE FROM role_permission_rules WHERE id='test-pmo-read-allow'").run();
  await db.prepare(
    "INSERT INTO role_permission_rules (id, role_id, module_key, action_key, effect) VALUES (?, ?, 'PMO', 'read', 'deny')"
  ).bind("test-pmo-read-deny", "role-head-pmo").run();
  await db.prepare(
    "INSERT INTO role_scope_grants (id, role_assignment_id, module_key, scope_type, scope_id, grant_status, granted_by, granted_at) VALUES (?, ?, 'PMO', 'project', ?, 'active', ?, CURRENT_TIMESTAMP)"
  ).bind("test-pmo-scope-denied", "test-assignment-pmo", "project-1", "test-human-ceo").run();

  const actor = { personId: "test-human-ceo", personType: "human", mfaVerifiedAt: null };
  const denied = await authorizeActor(
    db, actor,
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "integration-explicit-deny"
  );
  assert.deepEqual(denied, { allowed: false, status: 403, reason: "explicit_deny" });

  const mfa = await authorizeActor(
    db, actor,
    { module: "FIN", action: "read", scopeType: "company", scopeId: null },
    "integration-mfa-required"
  );
  assert.deepEqual(mfa, { allowed: false, status: 403, reason: "fresh_mfa_required" });

  const audit = await db.prepare(
    "SELECT COUNT(*) AS count FROM audit_logs WHERE request_id IN (?, ?, ?)"
  ).bind("integration-explicit-deny", "integration-mfa-required", "integration-mismatched-role-scope").first();
  assert.equal(audit.count, 3);
});
