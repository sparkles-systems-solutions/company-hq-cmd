import test from "node:test";
import assert from "node:assert/strict";
import {
  SESSION_POLICY,
  evaluateSessionLifecycle,
  isMfaFresh,
  shouldRefreshLastSeen
} from "../src/session-lifecycle.js";

const NOW = Date.parse("2026-11-25T12:00:00.000Z");
const iso = (value) => new Date(value).toISOString();
const validSession = (overrides = {}) => ({
  issuedAt: iso(NOW - 60_000),
  expiresAt: iso(NOW + 60_000),
  lastSeenAt: iso(NOW - 60_000),
  revokedAt: null,
  ...overrides
});

test("session lifecycle rejects at the exact absolute-expiry boundary", () => {
  assert.equal(
    evaluateSessionLifecycle(validSession({ expiresAt: iso(NOW) }), NOW).reason,
    "absolute_expiry"
  );
});

test("session lifecycle accepts exactly the idle-timeout boundary and rejects beyond it", () => {
  const issuedAt = NOW - 60 * 60_000;
  const atBoundary = validSession({
    issuedAt: iso(issuedAt),
    expiresAt: iso(NOW + 60 * 60_000),
    lastSeenAt: iso(NOW - SESSION_POLICY.idleTimeoutSeconds * 1000)
  });
  const beyondBoundary = {
    ...atBoundary,
    lastSeenAt: iso(NOW - (SESSION_POLICY.idleTimeoutSeconds * 1000 + 1))
  };
  assert.deepEqual(evaluateSessionLifecycle(atBoundary, NOW), { valid: true, reason: "active" });
  assert.equal(evaluateSessionLifecycle(beyondBoundary, NOW).reason, "idle_timeout");
});

test("session lifecycle rejects timestamps too far in the future", () => {
  assert.equal(
    evaluateSessionLifecycle(validSession({ lastSeenAt: iso(NOW + 31_000) }), NOW).reason,
    "last_seen_in_future"
  );
});

test("MFA freshness includes exactly ten minutes but rejects one millisecond older", () => {
  assert.equal(isMfaFresh(iso(NOW - SESSION_POLICY.mfaFreshnessSeconds * 1000), NOW), true);
  assert.equal(isMfaFresh(iso(NOW - (SESSION_POLICY.mfaFreshnessSeconds * 1000 + 1)), NOW), false);
});

test("last-seen refresh throttle activates at five minutes, not before", () => {
  assert.equal(shouldRefreshLastSeen(iso(NOW - 299_999), NOW), false);
  assert.equal(shouldRefreshLastSeen(iso(NOW - 300_000), NOW), true);
});
