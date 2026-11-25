/**
 * Testable contract for the future protected-request pipeline.
 *
 * This module is deliberately NOT imported by worker/src/index.js. It is a
 * dependency-injected prototype seam for isolated ordering/fail-closed tests;
 * it does not parse cookies, query D1, issue sessions, or expose a route.
 */
import {
  evaluateSessionLifecycle,
  evaluateLastSeenRefreshResult,
  shouldRefreshLastSeen,
  isMfaFresh
} from "./session-lifecycle.js";

function denied(reason, status = 401) {
  return { allowed: false, status, reason };
}

export async function runSessionPipelineContract({
  sessionTokenHash,
  now,
  loadSession,
  isActiveHuman,
  refreshLastSeen,
  authorize,
  readProtectedData,
  auditDenial = async () => {},
  needsFreshMfa = false
}) {
  if (typeof sessionTokenHash !== "string" || !sessionTokenHash ||
      !Number.isFinite(now) || typeof loadSession !== "function" ||
      typeof isActiveHuman !== "function" || typeof refreshLastSeen !== "function" ||
      typeof authorize !== "function" || typeof readProtectedData !== "function") {
    return denied("invalid_pipeline_input", 400);
  }

  let row;
  try {
    row = await loadSession(sessionTokenHash);
  } catch {
    return denied("session_lookup_failed", 503);
  }
  if (!row) return denied("invalid_session");

  let activeHuman = false;
  try {
    activeHuman = await isActiveHuman(row);
  } catch {
    return denied("identity_lookup_failed", 503);
  }
  if (!activeHuman) return denied("inactive_or_nonhuman_identity");

  const lifecycle = evaluateSessionLifecycle({
    issuedAt: row.issued_at,
    expiresAt: row.expires_at,
    lastSeenAt: row.last_seen_at === null || row.last_seen_at === undefined ? row.issued_at : row.last_seen_at,
    revokedAt: row.revoked_at
  }, now);
  if (!lifecycle.valid) {
    try {
      await auditDenial(lifecycle.reason);
    } catch {
      return denied("denial_audit_failed", 503);
    }
    return denied(lifecycle.reason);
  }

  if (shouldRefreshLastSeen(row.last_seen_at === null || row.last_seen_at === undefined ? row.issued_at : row.last_seen_at, now)) {
    let refreshResult;
    try {
      refreshResult = await refreshLastSeen(row.id, new Date(now).toISOString());
    } catch {
      return denied("refresh_failed", 503);
    }
    const refreshDecision = evaluateLastSeenRefreshResult(refreshResult);
    if (!refreshDecision.accepted) {
      return denied(refreshDecision.reason, 503);
    }
  }

  if (needsFreshMfa && !isMfaFresh(row.mfa_verified_at, now)) {
    try {
      await auditDenial("fresh_mfa_required");
    } catch {
      return denied("denial_audit_failed", 503);
    }
    return denied("fresh_mfa_required", 403);
  }

  let authorization;
  try {
    authorization = await authorize({
      personId: row.person_id,
      sessionId: row.id,
      mfaVerifiedAt: row.mfa_verified_at,
      now
    });
  } catch {
    return denied("authorization_failed", 503);
  }
  if (!authorization || authorization.allowed !== true) {
    return denied(authorization?.reason || "authorization_denied", authorization?.status || 403);
  }

  try {
    const data = await readProtectedData();
    return { allowed: true, status: 200, reason: "authorized", data };
  } catch {
    return denied("protected_data_unavailable", 503);
  }
}
