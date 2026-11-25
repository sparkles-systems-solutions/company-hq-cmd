import test from "node:test";
import assert from "node:assert/strict";
import { SESSION_POLICY, calculateSessionExpiry, evaluateSessionLifecycle, isMfaFresh, shouldRefreshLastSeen } from "../src/session-lifecycle.js";
const NOW = Date.parse("2026-11-25T12:00:00.000Z");
const iso = (ms) => new Date(ms).toISOString();
const activeSession = (overrides = {}) => ({ issuedAt: iso(NOW - 60000), expiresAt: iso(NOW + 3600000), lastSeenAt: iso(NOW - 60000), revokedAt: null, ...overrides });
test("session policy defaults are bounded", () => {
  assert.equal(SESSION_POLICY.idleTimeoutSeconds, 1800);
  assert.equal(SESSION_POLICY.absoluteLifetimeSeconds, 43200);
  assert.equal(SESSION_POLICY.mfaFreshnessSeconds, 600);
});
test("accepts a valid session", () => assert.deepEqual(evaluateSessionLifecycle(activeSession(), NOW), { valid: true, reason: "active" }));
test("rejects missing, revoked and malformed sessions", () => {
  assert.equal(evaluateSessionLifecycle(null, NOW).reason, "missing_session");
  assert.equal(evaluateSessionLifecycle(activeSession({ revokedAt: iso(NOW - 1) }), NOW).reason, "revoked");
  assert.equal(evaluateSessionLifecycle(activeSession({ issuedAt: "bad-date" }), NOW).reason, "invalid_timestamps");
});
test("rejects idle timeout and absolute expiry", () => {
  assert.equal(evaluateSessionLifecycle(activeSession({ lastSeenAt: iso(NOW - 31 * 60000) }), NOW).reason, "idle_timeout");
  assert.equal(evaluateSessionLifecycle(activeSession({ expiresAt: iso(NOW) }), NOW).reason, "absolute_expiry");
});
test("rejects inconsistent issue, last-seen and expiry ordering", () => {
  assert.equal(evaluateSessionLifecycle(activeSession({ expiresAt: iso(NOW - 120000) }), NOW).reason, "invalid_timestamp_order");
  assert.equal(evaluateSessionLifecycle(activeSession({ lastSeenAt: iso(NOW - 120000) }), NOW).reason, "invalid_timestamp_order");
});
test("rejects excessive lifetime and future issue time", () => {
  assert.equal(evaluateSessionLifecycle(activeSession({ expiresAt: iso(NOW + 13 * 3600000) }), NOW).reason, "absolute_lifetime_exceeded");
  assert.equal(evaluateSessionLifecycle(activeSession({ issuedAt: iso(NOW + 60000) }), NOW).reason, "issued_in_future");
});
test("calculates fixed absolute expiry", () => {
  assert.equal(calculateSessionExpiry(NOW), iso(NOW + 12 * 3600000));
  assert.throws(() => calculateSessionExpiry("bad"), /epoch millisecond/);
});
test("throttles last-seen refreshes", () => {
  assert.equal(shouldRefreshLastSeen(iso(NOW - 4 * 60000), NOW), false);
  assert.equal(shouldRefreshLastSeen(iso(NOW - 5 * 60000), NOW), true);
  assert.equal(shouldRefreshLastSeen("bad", NOW), false);
});
test("enforces ten-minute MFA freshness", () => {
  assert.equal(isMfaFresh(iso(NOW - 9 * 60000), NOW), true);
  assert.equal(isMfaFresh(iso(NOW - 11 * 60000), NOW), false);
  assert.equal(isMfaFresh(iso(NOW + 60000), NOW), false);
  assert.equal(isMfaFresh(null, NOW), false);
});
