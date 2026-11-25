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
