/**
 * Design-only session exchange planner.
 *
 * This module validates already-verified facts and returns a non-secret plan.
 * It deliberately does not verify JWTs, consume exchange keys, access D1,
 * generate session tokens, issue cookies, or integrate with Worker routes.
 */
import { isMfaFresh, SESSION_POLICY } from "./session-lifecycle.js";

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA256_HEX_PATTERN = /^[0-9a-f]{64}$/i;

function reject(reason) {
  return { accepted: false, reason };
}

/**
 * Build a plan only after upstream trusted verifier/identity gates succeed.
 * exchangeKeyHash must be a server-generated hash; never pass raw key material.
 */
export function planCmdSessionExchange(input) {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    return reject("invalid_exchange_input");
  }

  const {
    jwtSignatureVerified,
    issuerAudienceExpiryVerified,
    assuranceLevel,
    authProvider,
    emailVerified,
    mfaVerifiedAt,
    activeHuman,
    authUserId,
    personId,
    exchangeKeyHash,
    exchangeKeyExpiresAt,
    exchangeKeyConsumed,
    browserMutationValidated,
    now
  } = input;

  if (jwtSignatureVerified !== true || issuerAudienceExpiryVerified !== true) {
    return reject("trusted_provider_token_required");
  }
  if (assuranceLevel !== "aal2") return reject("mfa_aal2_required");
  if (authProvider !== "email_password") return reject("approved_auth_provider_required");
  if (emailVerified !== true) return reject("verified_email_required");
  if (!activeHuman) return reject("active_human_identity_required");
  if (!UUID_PATTERN.test(authUserId || "") || !UUID_PATTERN.test(personId || "")) {
    return reject("invalid_mapped_identity");
  }
  if (!Number.isFinite(now) || !isMfaFresh(mfaVerifiedAt, now)) {
    return reject("fresh_mfa_required");
  }
  if (browserMutationValidated !== true) return reject("browser_mutation_guard_required");
  if (!SHA256_HEX_PATTERN.test(exchangeKeyHash || "")) {
    return reject("invalid_exchange_key_hash");
  }
  if (exchangeKeyConsumed !== false) return reject("exchange_key_unavailable");
  if (!Number.isFinite(exchangeKeyExpiresAt) || exchangeKeyExpiresAt <= now ||
      exchangeKeyExpiresAt - now > 5 * 60 * 1000) {
    return reject("exchange_key_expired_or_too_long");
  }

  const issuedAt = new Date(now).toISOString();
  const expiresAt = new Date(now + SESSION_POLICY.absoluteLifetimeSeconds * 1000).toISOString();
  return {
    accepted: true,
    plan: Object.freeze({
      authUserId,
      personId,
      authProvider,
      issuedAt,
      expiresAt,
      lastSeenAt: issuedAt,
      mfaVerifiedAt: new Date(Date.parse(mfaVerifiedAt)).toISOString(),
      exchangeKeyHash,
      requiresAtomicSessionAuditExchangeConsume: true,
      cookieMayBeIssuedOnlyAfterAtomicCommit: true
    })
  };
}
