import test from "node:test";
import assert from "node:assert/strict";
import { Miniflare } from "miniflare";

/**
 * Concurrency contract test for a one-time session-rotation claim.
 * Uses only a disposable Miniflare D1 database and synthetic rows.
 * This does not implement or invoke the CMD session-exchange route.
 */
test("concurrent rotation claims produce at most one winner", async () => {
  const mf = new Miniflare({
    modules: true,
    script: "export default { fetch() { return new Response('ok'); } };",
    compatibilityDate: "2026-08-06",
    d1Databases: { DB: "cmd-session-rotation-race-db" }
  });

  try {
    const db = await mf.getD1Database("DB");
    await db.prepare(`
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        status TEXT NOT NULL CHECK (status IN ('active', 'rotated', 'revoked')),
        replacement_session_id TEXT
      )
    `).run();
    await db.prepare(
      "INSERT INTO sessions (id, status) VALUES (?, 'active')"
    ).bind("old-session").run();

    // Competing requests attempt the same compare-and-set transition.
    const claim = () => db.prepare(`
      UPDATE sessions
         SET status = 'rotated', replacement_session_id = ?
       WHERE id = ? AND status = 'active'
       RETURNING id, replacement_session_id
    `).bind("replacement-session", "old-session").all();

    const outcomes = await Promise.all([claim(), claim()]);
    const winners = outcomes.flatMap((outcome) => outcome.results || []);

    assert.equal(winners.length, 1, "exactly one request may claim the active session");
    assert.equal(winners[0].id, "old-session");
    assert.equal(winners[0].replacement_session_id, "replacement-session");

    const oldSession = await db.prepare(
      "SELECT status, replacement_session_id FROM sessions WHERE id = ?"
    ).bind("old-session").first();
    assert.equal(oldSession.status, "rotated");
    assert.equal(oldSession.replacement_session_id, "replacement-session");

    const replacementRows = await db.prepare(
      "SELECT COUNT(*) AS count FROM sessions WHERE id = ?"
    ).bind("replacement-session").first();
    assert.equal(replacementRows.count, 0,
      "this claim-only test must not pretend a replacement session was issued");
  } finally {
    await mf.dispose();
  }
});
