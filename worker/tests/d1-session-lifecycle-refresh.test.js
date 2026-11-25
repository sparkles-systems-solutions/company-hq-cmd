import test from "node:test";
import assert from "node:assert/strict";
import { Miniflare } from "miniflare";

// Disposable D1 contract tests. Column names and timestamp storage mirror
// migrations/0005_authorization_schema.sql; no production D1 is accessed.
const CREATE_SQL = `
  CREATE TABLE auth_sessions (
    id TEXT PRIMARY KEY,
    auth_user_id TEXT NOT NULL,
    session_token_hash TEXT NOT NULL UNIQUE,
    issued_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TEXT NOT NULL,
    last_seen_at TEXT,
    revoked_at TEXT,
    revoke_reason TEXT,
    mfa_verified_at TEXT,
    ip_address_hash TEXT,
    user_agent_summary TEXT,
    CHECK (expires_at > issued_at)
  )
`;

const REFRESH_SQL = `
  UPDATE auth_sessions
     SET last_seen_at = ?
   WHERE id = ?
     AND revoked_at IS NULL
     AND issued_at <= ?
     AND expires_at > ?
     AND last_seen_at IS NOT NULL
     AND last_seen_at <= ?
     AND last_seen_at < ?
  RETURNING id, issued_at, expires_at, last_seen_at
`;

const iso = (value) => new Date(value).toISOString();

async function insertSession(db, {
  id = "session-1",
  issuedAt = "2026-11-25T08:00:00.000Z",
  expiresAt = "2026-11-25T20:00:00.000Z",
  lastSeenAt = "2026-11-25T08:00:00.000Z",
  revokedAt = null
} = {}) {
  await db.prepare(`
    INSERT INTO auth_sessions
      (id, auth_user_id, session_token_hash, issued_at, expires_at, last_seen_at, revoked_at)
    VALUES (?, 'synthetic-user', ?, ?, ?, ?, ?)
  `).bind(id, `hash-${id}`, issuedAt, expiresAt, lastSeenAt, revokedAt).run();
}

async function refresh(db, id, now) {
  const candidate = iso(now);
  const cutoff = iso(now - 300_000);
  const result = await db.prepare(REFRESH_SQL)
    .bind(candidate, id, candidate, candidate, cutoff, candidate)
    .all();
  return result.results || [];
}

test("last-seen refresh waits until the five-minute throttle boundary", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-session-lifecycle-refresh-db" }
  });
  try {
    const db = await mf.getD1Database("DB");
    await db.prepare(CREATE_SQL).run();
    const now = Date.parse("2026-11-25T09:00:00.000Z");
    await insertSession(db, { lastSeenAt: iso(now - 299_999) });
    assert.equal((await refresh(db, "session-1", now)).length, 0);
    const before = await db.prepare("SELECT last_seen_at FROM auth_sessions WHERE id=?").bind("session-1").first();
    assert.equal(before.last_seen_at, iso(now - 299_999));

    await db.prepare("UPDATE auth_sessions SET last_seen_at=? WHERE id=?")
      .bind(iso(now - 300_000), "session-1").run();
    const updated = await refresh(db, "session-1", now);
    assert.equal(updated.length, 1);
    assert.equal(updated[0].last_seen_at, iso(now));
  } finally {
    await mf.dispose();
  }
});

test("revoked and expired sessions cannot refresh last-seen", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-session-lifecycle-deny-db" }
  });
  try {
    const db = await mf.getD1Database("DB");
    await db.prepare(CREATE_SQL).run();
    const now = Date.parse("2026-11-25T09:00:00.000Z");
    await insertSession(db, { id: "revoked", lastSeenAt: iso(now - 600_000), revokedAt: iso(now - 1_000) });
    await insertSession(db, { id: "expired", lastSeenAt: iso(now - 600_000), expiresAt: iso(now) });
    assert.equal((await refresh(db, "revoked", now)).length, 0);
    assert.equal((await refresh(db, "expired", now)).length, 0);
  } finally {
    await mf.dispose();
  }
});

test("competing refreshes are monotonic and never change fixed expiry or issue time", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-session-lifecycle-race-db" }
  });
  try {
    const db = await mf.getD1Database("DB");
    await db.prepare(CREATE_SQL).run();
    const issuedAt = "2026-11-25T08:00:00.000Z";
    const expiresAt = "2026-11-25T20:00:00.000Z";
    const initialSeen = "2026-11-25T08:00:00.000Z";
    await insertSession(db, { issuedAt, expiresAt, lastSeenAt: initialSeen });

    const later = Date.parse("2026-11-25T09:06:00.000Z");
    const earlier = Date.parse("2026-11-25T09:05:00.000Z");
    const outcomes = await Promise.all([
      refresh(db, "session-1", later),
      refresh(db, "session-1", earlier)
    ]);
    const row = await db.prepare(
      "SELECT issued_at, expires_at, last_seen_at FROM auth_sessions WHERE id=?"
    ).bind("session-1").first();

    assert.equal(row.issued_at, issuedAt);
    assert.equal(row.expires_at, expiresAt);
    assert.equal(row.last_seen_at, iso(later));
    assert.ok(outcomes.flat().length >= 1);

    // A delayed older candidate must never move last_seen_at backwards.
    await refresh(db, "session-1", earlier);
    const afterDelayed = await db.prepare(
      "SELECT last_seen_at FROM auth_sessions WHERE id=?"
    ).bind("session-1").first();
    assert.equal(afterDelayed.last_seen_at, iso(later));
  } finally {
    await mf.dispose();
  }
});
