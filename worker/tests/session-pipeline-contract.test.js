import test from "node:test";
import assert from "node:assert/strict";
import { runSessionPipelineContract } from "../src/session-pipeline-contract.js";

const NOW = Date.parse("2026-11-25T12:00:00.000Z");
const iso = (ms) => new Date(ms).toISOString();
const validRow = (overrides = {}) => ({
  id: "synthetic-session",
  person_id: "synthetic-human",
  issued_at: iso(NOW - 60_000),
  expires_at: iso(NOW + 60 * 60_000),
  last_seen_at: iso(NOW - 60_000),
  revoked_at: null,
  mfa_verified_at: iso(NOW - 60_000),
  ...overrides
});

function harness(overrides = {}) {
  const events = [];
  const row = overrides.row === undefined ? validRow() : overrides.row;
  const deps = {
    sessionTokenHash: "synthetic-hash",
    now: NOW,
    loadSession: async () => { events.push("session"); return row; },
    isActiveHuman: async () => { events.push("identity"); return true; },
    refreshLastSeen: async () => { events.push("refresh"); return { meta: { changes: 1 } }; },
    authorize: async () => { events.push("authorize"); return { allowed: true }; },
    readProtectedData: async () => { events.push("data"); return ["synthetic"]; },
    auditDenial: async (reason) => { events.push("audit:" + reason); },
    ...overrides
  };
  return { deps, events };
}

test("valid request pipeline orders session, identity, lifecycle, authorization and data", async () => {
  const { deps, events } = harness();
  const result = await runSessionPipelineContract(deps);
  assert.deepEqual(result, { allowed: true, status: 200, reason: "authorized", data: ["synthetic"] });
  assert.deepEqual(events, ["session", "identity", "authorize", "data"]);
});

test("NULL last_seen_at falls back to issued_at and does not count as recent activity", async () => {
  const { deps, events } = harness({ row: validRow({ last_seen_at: null }) });
  const result = await runSessionPipelineContract(deps);
  assert.equal(result.allowed, true);
  assert.deepEqual(events, ["session", "identity", "authorize", "data"]);
});

test("lifecycle denials never refresh, authorize, or read protected data", async (t) => {
  const scenarios = [
    ["revoked", { revoked_at: iso(NOW - 1) }, "revoked"],
    ["idle", { issued_at: iso(NOW - 32 * 60_000), last_seen_at: iso(NOW - 31 * 60_000) }, "idle_timeout"],
    ["expired", { expires_at: iso(NOW) }, "absolute_expiry"],
    ["malformed issue time", { issued_at: "not-a-date" }, "invalid_timestamps"],
    ["future last seen", { last_seen_at: iso(NOW + 31_000) }, "last_seen_in_future"]
  ];
  for (const [name, override, reason] of scenarios) {
    await t.test(name, async () => {
      const { deps, events } = harness({ row: validRow(override) });
      const result = await runSessionPipelineContract(deps);
      assert.equal(result.allowed, false);
      assert.equal(result.reason, reason);
      assert.deepEqual(events, ["session", "identity", "audit:" + reason]);
    });
  }
});

test("missing session and non-human identity stop before authorization and data", async (t) => {
  await t.test("missing session", async () => {
    const { deps, events } = harness({ row: null });
    const result = await runSessionPipelineContract(deps);
    assert.equal(result.reason, "invalid_session");
    assert.deepEqual(events, ["session"]);
  });
  await t.test("virtual or inactive identity", async () => {
    const { deps, events } = harness({ isActiveHuman: async () => { events.push("identity"); return false; } });
    const result = await runSessionPipelineContract(deps);
    assert.equal(result.reason, "inactive_or_nonhuman_identity");
    assert.deepEqual(events, ["session", "identity"]);
  });
});

test("refresh is skipped inside throttle and required refresh failure blocks authorization", async (t) => {
  await t.test("refresh not due", async () => {
    const { deps, events } = harness();
    const result = await runSessionPipelineContract(deps);
    assert.equal(result.allowed, true);
    assert.equal(events.includes("refresh"), false);
  });
  for (const [name, refreshLastSeen] of [
    ["D1 exception", async () => { throw new Error("synthetic"); }],
    ["zero rows", async () => ({ meta: { changes: 0 } })],
    ["missing metadata", async () => ({})],
    ["multiple rows", async () => ({ meta: { changes: 2 } })]
  ]) {
    await t.test(name, async () => {
      const { deps, events } = harness({
        row: validRow({ last_seen_at: iso(NOW - 301_000) }),
        refreshLastSeen: async (...args) => { events.push("refresh"); return refreshLastSeen(...args); }
      });
      const result = await runSessionPipelineContract(deps);
      assert.equal(result.allowed, false);
      assert.equal(events.includes("authorize"), false);
      assert.equal(events.includes("data"), false);
    });
  }
});

test("authorization denial prevents protected data access", async () => {
  const { deps, events } = harness({
    authorize: async () => { events.push("authorize"); return { allowed: false, status: 403, reason: "no_scope" }; }
  });
  const result = await runSessionPipelineContract(deps);
  assert.deepEqual(result, { allowed: false, status: 403, reason: "no_scope" });
  assert.deepEqual(events, ["session", "identity", "authorize"]);
});

test("fresh MFA uses the request's captured now and blocks authorization when stale", async () => {
  const { deps, events } = harness({
    row: validRow({ mfa_verified_at: iso(NOW - 10 * 60_000 - 1) }),
    needsFreshMfa: true
  });
  const result = await runSessionPipelineContract(deps);
  assert.equal(result.reason, "fresh_mfa_required");
  assert.equal(events.includes("authorize"), false);
  assert.equal(events.includes("data"), false);
});

test("lookup, identity, audit and protected-data failures fail closed", async (t) => {
  const cases = [
    ["lookup", { loadSession: async () => { throw new Error("db"); } }, "session_lookup_failed"],
    ["identity", { isActiveHuman: async () => { throw new Error("db"); } }, "identity_lookup_failed"],
    ["audit", { row: validRow({ revoked_at: iso(NOW - 1) }), auditDenial: async () => { throw new Error("audit"); } }, "denial_audit_failed"],
    ["data", { readProtectedData: async () => { throw new Error("db"); } }, "protected_data_unavailable"]
  ];
  for (const [name, override, reason] of cases) {
    await t.test(name, async () => {
      const { deps, events } = harness(override);
      const result = await runSessionPipelineContract(deps);
      assert.equal(result.allowed, false);
      assert.equal(result.reason, reason);
    });
  }
});
