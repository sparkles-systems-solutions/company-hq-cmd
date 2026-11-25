import test from "node:test";
import assert from "node:assert/strict";
import {
  parseCookies,
  isValidPermissionRequest,
  requiresFreshMfa,
  evaluateRolePolicy
} from "../src/authorization.js";
import { authorizeActor } from "../src/index.js";

test("cookie parser handles multiple cookies and ignores malformed parts", () => {
  assert.deepEqual(
    { ...parseCookies("a=1; __Host-cmd_session=opaque-token; malformed; b=two") },
    { a: "1", "__Host-cmd_session": "opaque-token", b: "two" }
  );
});

test("permission request rejects unknown modules and actions", () => {
  assert.equal(isValidPermissionRequest({
    module: "PMO", action: "read", scopeType: "project", scopeId: "p-1"
  }), true);
  assert.equal(isValidPermissionRequest({
    module: "ROOT", action: "execute", scopeType: "company", scopeId: null
  }), false);
  assert.equal(isValidPermissionRequest({
    module: "PMO", action: "read", scopeType: "project", scopeId: null
  }), false);
});

test("company scope requires null scope id", () => {
  assert.equal(isValidPermissionRequest({
    module: "EXEC", action: "read", scopeType: "company", scopeId: null
  }), true);
  assert.equal(isValidPermissionRequest({
    module: "EXEC", action: "read", scopeType: "company", scopeId: "all"
  }), false);
});

test("fresh MFA is required for privileged actions and modules", () => {
  assert.equal(requiresFreshMfa({ module: "PMO", action: "read" }), false);
  assert.equal(requiresFreshMfa({ module: "FIN", action: "read" }), true);
  assert.equal(requiresFreshMfa({ module: "PMO", action: "execute" }), true);
});

test("virtual actor can never approve or execute", () => {
  assert.equal(evaluateRolePolicy({
    personType: "virtual", action: "approve", hasExplicitDeny: false, hasScopedAllow: true
  }).allowed, false);
  assert.equal(evaluateRolePolicy({
    personType: "virtual", action: "execute", hasExplicitDeny: false, hasScopedAllow: true
  }).allowed, false);
});

test("explicit deny overrides scoped allow", () => {
  assert.deepEqual(evaluateRolePolicy({
    personType: "human", action: "read", hasExplicitDeny: true, hasScopedAllow: true
  }), { allowed: false, reason: "explicit_deny" });
});

test("missing scoped allow is denied", () => {
  assert.deepEqual(evaluateRolePolicy({
    personType: "human", action: "draft", hasExplicitDeny: false, hasScopedAllow: false
  }), { allowed: false, reason: "no_matching_scoped_allow" });
});

test("matching scoped allow is accepted by policy evaluator", () => {
  assert.deepEqual(evaluateRolePolicy({
    personType: "human", action: "read", hasExplicitDeny: false, hasScopedAllow: true
  }), { allowed: true, reason: "scoped_allow" });
});


function createAuthorizationDb({ assignments = [{ assignment_id: "as-1", role_id: "role-pmo" }], policies = [], scopedAllow = { allowed: 1 }, auditFails = false } = {}) {
  const auditEvents = [];
  return {
    auditEvents,
    prepare(sql) {
      return {
        bind(...values) {
          return {
            async all() {
              if (sql.includes("FROM role_assignments ra")) return { results: assignments };
              if (sql.includes("FROM role_permission_rules")) return { results: policies };
              throw new Error("Unexpected .all() SQL: " + sql);
            },
            async first() {
              if (sql.includes("FROM role_scope_grants g")) return scopedAllow;
              throw new Error("Unexpected .first() SQL: " + sql);
            },
            async run() {
              if (sql.includes("INSERT INTO audit_logs")) {
                if (auditFails) throw new Error("synthetic audit outage");
                auditEvents.push({ sql, values });
                return { success: true };
              }
              throw new Error("Unexpected .run() SQL: " + sql);
            }
          };
        }
      };
    }
  };
}

test("authorizeActor loads role policies from D1 and explicit deny overrides scoped allow", async () => {
  const db = createAuthorizationDb({
    policies: [{ effect: "allow" }, { effect: "deny" }],
    scopedAllow: { allowed: 1 }
  });
  const result = await authorizeActor(
    db,
    { personId: "human-1", personType: "human", mfaVerifiedAt: null },
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "request-1"
  );
  assert.deepEqual(result, { allowed: false, status: 403, reason: "explicit_deny" });
  assert.equal(db.auditEvents.length, 1);
});

test("authorizeActor permits a matching scoped allow when no explicit deny exists", async () => {
  const db = createAuthorizationDb({ policies: [{ effect: "allow" }], scopedAllow: { allowed: 1 } });
  const result = await authorizeActor(
    db,
    { personId: "human-1", personType: "human", mfaVerifiedAt: null },
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "request-2"
  );
  assert.deepEqual(result, { allowed: true, status: 200, reason: "scoped_allow" });
  assert.equal(db.auditEvents.length, 1);
});

test("authorizeActor denies when no matching scoped grant exists", async () => {
  const db = createAuthorizationDb({ policies: [{ effect: "allow" }], scopedAllow: null });
  const result = await authorizeActor(
    db,
    { personId: "human-1", personType: "human", mfaVerifiedAt: null },
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "request-3"
  );
  assert.deepEqual(result, { allowed: false, status: 403, reason: "no_matching_scoped_allow" });
  assert.equal(db.auditEvents.length, 1);
});


test("authorizeActor denies when there are no active role assignments", async () => {
  const db = createAuthorizationDb({ assignments: [] });
  const result = await authorizeActor(db,
    { personId: "human-1", personType: "human", mfaVerifiedAt: null },
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "request-no-role");
  assert.deepEqual(result, { allowed: false, status: 403, reason: "no_active_role" });
  assert.equal(db.auditEvents.length, 1);
});

test("authorizeActor never grants virtual actors approve or execute even with scoped allow", async (t) => {
  for (const action of ["approve", "execute"]) {
    await t.test(action, async () => {
      const db = createAuthorizationDb({ policies: [{ effect: "allow" }], scopedAllow: { allowed: 1 } });
      const result = await authorizeActor(db,
        { personId: "virtual-1", personType: "virtual", mfaVerifiedAt: new Date().toISOString() },
        { module: "PMO", action, scopeType: "project", scopeId: "project-1" },
        "request-virtual-" + action);
      assert.equal(result.allowed, false);
      assert.equal(result.reason, "virtual_privileged_action_denied");
    });
  }
});

test("authorizeActor requires fresh MFA for privileged modules and audits the denial", async () => {
  const db = createAuthorizationDb({ policies: [{ effect: "allow" }], scopedAllow: { allowed: 1 } });
  const result = await authorizeActor(db,
    { personId: "human-1", personType: "human", mfaVerifiedAt: null },
    { module: "FIN", action: "read", scopeType: "company", scopeId: null },
    "request-mfa");
  assert.deepEqual(result, { allowed: false, status: 403, reason: "fresh_mfa_required" });
  assert.equal(db.auditEvents.length, 1);
});

test("authorizeActor fails closed when denial audit persistence fails", async () => {
  const db = createAuthorizationDb({ assignments: [], auditFails: true });
  await assert.rejects(authorizeActor(db,
    { personId: "human-1", personType: "human", mfaVerifiedAt: null },
    { module: "PMO", action: "read", scopeType: "project", scopeId: "project-1" },
    "request-audit-failure"));
});

test("authorizeActor rejects malformed server policy before querying role data", async () => {
  let queryCount = 0;
  const db = createAuthorizationDb();
  const originalPrepare = db.prepare.bind(db);
  db.prepare = (sql) => { queryCount += 1; return originalPrepare(sql); };
  const result = await authorizeActor(db,
    { personId: "human-1", personType: "human", mfaVerifiedAt: null },
    { module: "PMO", action: "delete", scopeType: "project", scopeId: "project-1" },
    "request-invalid-policy");
  assert.deepEqual(result, { allowed: false, status: 400, reason: "invalid_permission_request" });
  assert.equal(queryCount, 1, "only the denial audit insert is allowed");
});
