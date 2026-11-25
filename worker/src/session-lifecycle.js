/**
 * CMD session lifecycle policy.
 * Pure helpers only: no token issuance, D1 writes, cookies, or Worker route integration.
 */
export const SESSION_POLICY = Object.freeze({
  idleTimeoutSeconds: 1800,
  absoluteLifetimeSeconds: 43200,
  mfaFreshnessSeconds: 600,
  lastSeenRefreshIntervalSeconds: 300
});
function toEpochMs(value) {
  if (typeof value !== "string" || !value.trim()) return null;
  const normalized = value.includes("T") ? value : value.replace(" ", "T");
  const hasTimezone = /(?:Z|[+-]\d{2}:?\d{2})$/i.test(normalized);
  const parsed = Date.parse(normalized + (hasTimezone ? "" : "Z"));
  return Number.isFinite(parsed) ? parsed : null;
}
export function evaluateSessionLifecycle(session, now = Date.now()) {
  if (!session || typeof session !== "object") return { valid: false, reason: "missing_session" };
  if (session.revokedAt) return { valid: false, reason: "revoked" };
  const issuedAt = toEpochMs(session.issuedAt);
  const expiresAt = toEpochMs(session.expiresAt);
  const lastSeenValue = session.lastSeenAt === null || session.lastSeenAt === undefined
    ? session.issuedAt
    : session.lastSeenAt;
  const lastSeenAt = toEpochMs(lastSeenValue);
  if (issuedAt === null || expiresAt === null || lastSeenAt === null) return { valid: false, reason: "invalid_timestamps" };
  if (issuedAt > now + 30000) return { valid: false, reason: "issued_in_future" };
  if (expiresAt <= issuedAt || lastSeenAt < issuedAt) return { valid: false, reason: "invalid_timestamp_order" };
  if (expiresAt <= now) return { valid: false, reason: "absolute_expiry" };
  if (expiresAt - issuedAt > SESSION_POLICY.absoluteLifetimeSeconds * 1000) return { valid: false, reason: "absolute_lifetime_exceeded" };
  if (lastSeenAt > now + 30000) return { valid: false, reason: "last_seen_in_future" };
  if (now - lastSeenAt > SESSION_POLICY.idleTimeoutSeconds * 1000) return { valid: false, reason: "idle_timeout" };
  return { valid: true, reason: "active" };
}
export function calculateSessionExpiry(issuedAt = Date.now()) {
  if (!Number.isFinite(issuedAt)) throw new TypeError("issuedAt must be an epoch millisecond number");
  return new Date(issuedAt + SESSION_POLICY.absoluteLifetimeSeconds * 1000).toISOString();
}
export function shouldRefreshLastSeen(lastSeenAt, now = Date.now()) {
  const lastSeen = toEpochMs(lastSeenAt);
  if (lastSeen === null || !Number.isFinite(now)) return false;
  return now - lastSeen >= SESSION_POLICY.lastSeenRefreshIntervalSeconds * 1000;
}
export function isMfaFresh(verifiedAt, now = Date.now()) {
  const verified = toEpochMs(verifiedAt);
  if (verified === null || !Number.isFinite(now)) return false;
  return verified <= now + 30000 && now - verified <= SESSION_POLICY.mfaFreshnessSeconds * 1000;
}

/**
 * Classifies the result of a conditional last-seen UPDATE.
 * Callers must deny the request unless exactly one active session row changed.
 * This helper performs no database operation and never treats errors as success.
 */
export function evaluateLastSeenRefreshResult(result, error = null) {
  if (error) return { accepted: false, reason: "refresh_failed" };
  if (!result || !result.meta || result.meta.changes !== 1) {
    return { accepted: false, reason: "refresh_not_applied" };
  }
  return { accepted: true, reason: "refreshed" };
}
