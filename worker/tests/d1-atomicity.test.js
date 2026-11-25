import test from "node:test";
import assert from "node:assert/strict";
import { Miniflare } from "miniflare";

/**
 * This suite verifies the pinned Miniflare D1 batch behavior using a fresh,
 * disposable in-memory database. It does not connect to Cloudflare or CMD data.
 */
test("D1 batch commits related session and audit inserts together", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-atomicity-success-db" }
  });

  try {
    const db = await mf.getD1Database("DB");
    await db.prepare("CREATE TABLE sessions (id TEXT PRIMARY KEY, token_hash TEXT NOT NULL UNIQUE)").run();
    await db.prepare("CREATE TABLE audit_logs (id TEXT PRIMARY KEY, session_id TEXT NOT NULL)").run();

    const results = await db.batch([
      db.prepare("INSERT INTO sessions (id, token_hash) VALUES (?, ?)").bind("session-1", "hash-1"),
      db.prepare("INSERT INTO audit_logs (id, session_id) VALUES (?, ?)").bind("audit-1", "session-1")
    ]);

    assert.equal(results.length, 2);
    assert.equal((await db.prepare("SELECT COUNT(*) AS count FROM sessions").first()).count, 1);
    assert.equal((await db.prepare("SELECT COUNT(*) AS count FROM audit_logs").first()).count, 1);
  } finally {
    await mf.dispose();
  }
});

test("D1 batch rolls back earlier statements when a later statement fails", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-atomicity-rollback-db" }
  });

  try {
    const db = await mf.getD1Database("DB");
    await db.prepare("CREATE TABLE sessions (id TEXT PRIMARY KEY, token_hash TEXT NOT NULL UNIQUE)").run();
    await db.prepare("CREATE TABLE audit_logs (id TEXT PRIMARY KEY, session_id TEXT NOT NULL)").run();

    await assert.rejects(
      db.batch([
        db.prepare("INSERT INTO sessions (id, token_hash) VALUES (?, ?)").bind("session-rollback", "hash-rollback"),
        // Force a constraint failure after the first statement has executed.
        db.prepare("INSERT INTO audit_logs (id, session_id) VALUES (?, ?)").bind("audit-invalid", null)
      ])
    );

    assert.equal((await db.prepare("SELECT COUNT(*) AS count FROM sessions").first()).count, 0);
    assert.equal((await db.prepare("SELECT COUNT(*) AS count FROM audit_logs").first()).count, 0);
  } finally {
    await mf.dispose();
  }
});


test("rotation batch rolls back replacement and old-session revocation when audit insert fails", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-rotation-audit-rollback-db" }
  });

  try {
    const db = await mf.getD1Database("DB");
    await db.prepare("CREATE TABLE sessions (id TEXT PRIMARY KEY, status TEXT NOT NULL CHECK (status IN ('active', 'revoked')))").run();
    await db.prepare("CREATE TABLE audit_logs (id TEXT PRIMARY KEY, session_id TEXT NOT NULL)").run();
    await db.prepare("INSERT INTO sessions (id, status) VALUES ('old-session', 'active')").run();

    await assert.rejects(db.batch([
      db.prepare("INSERT INTO sessions (id, status) VALUES (?, 'active')").bind("replacement-session"),
      db.prepare("UPDATE sessions SET status = 'revoked' WHERE id = ? AND status = 'active'").bind("old-session"),
      // Inject audit failure after the replacement and revocation statements.
      db.prepare("INSERT INTO audit_logs (id, session_id) VALUES (?, ?)").bind("audit-failure", null)
    ]));

    const oldSession = await db.prepare("SELECT status FROM sessions WHERE id = 'old-session'").first();
    const replacement = await db.prepare("SELECT COUNT(*) AS count FROM sessions WHERE id = 'replacement-session'").first();
    const audits = await db.prepare("SELECT COUNT(*) AS count FROM audit_logs").first();
    assert.equal(oldSession.status, "active", "old session must remain active after failed rotation");
    assert.equal(replacement.count, 0, "replacement must not survive failed audit");
    assert.equal(audits.count, 0);
  } finally {
    await mf.dispose();
  }
});

test("unique exchange idempotency key prevents duplicate session and audit records atomically", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-exchange-idempotency-db" }
  });

  try {
    const db = await mf.getD1Database("DB");
    await db.prepare("CREATE TABLE sessions (id TEXT PRIMARY KEY, token_hash TEXT NOT NULL UNIQUE)").run();
    await db.prepare("CREATE TABLE audit_logs (id TEXT PRIMARY KEY, session_id TEXT NOT NULL)").run();
    await db.prepare("CREATE TABLE exchange_requests (idempotency_key TEXT PRIMARY KEY, session_id TEXT NOT NULL UNIQUE)").run();

    const exchangeBatch = (sessionId, tokenHash, auditId, key) => db.batch([
      db.prepare("INSERT INTO sessions (id, token_hash) VALUES (?, ?)").bind(sessionId, tokenHash),
      db.prepare("INSERT INTO audit_logs (id, session_id) VALUES (?, ?)").bind(auditId, sessionId),
      db.prepare("INSERT INTO exchange_requests (idempotency_key, session_id) VALUES (?, ?)").bind(key, sessionId)
    ]);

    await exchangeBatch("session-1", "hash-1", "audit-1", "request-once");
    await assert.rejects(exchangeBatch("session-2", "hash-2", "audit-2", "request-once"));

    assert.equal((await db.prepare("SELECT COUNT(*) AS count FROM sessions").first()).count, 1);
    assert.equal((await db.prepare("SELECT COUNT(*) AS count FROM audit_logs").first()).count, 1);
    assert.equal((await db.prepare("SELECT COUNT(*) AS count FROM exchange_requests").first()).count, 1);
    assert.equal((await db.prepare("SELECT session_id FROM exchange_requests WHERE idempotency_key = 'request-once'").first()).session_id, "session-1");
  } finally {
    await mf.dispose();
  }
});
