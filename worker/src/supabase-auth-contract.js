/**
 * CMD Phase 8 prototype: post-verification Supabase JWT claim gate.
 *
 * IMPORTANT: accepts claims ONLY after a trusted JWT verifier has checked
 * signature, issuer, audience, expiry and trusted JWKS key. This module does
 * not decode or verify JWTs and must never receive untrusted claims.
 */

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function validateSupabaseAal2Claims(claims, {
  issuer,
  nowSeconds = Math.floor(Date.now() / 1000),
  clockSkewSeconds = 30
} = {}) {
  if (!claims || typeof claims !== "object" || Array.isArray(claims)) {
    return { valid: false, reason: "invalid_claims" };
  }
  if (typeof issuer !== "string" || !issuer.startsWith("https://")) {
    return { valid: false, reason: "invalid_expected_issuer" };
  }
  if (claims.iss !== issuer) return { valid: false, reason: "issuer_mismatch" };
  if (claims.aud !== "authenticated" || claims.role !== "authenticated") {
    return { valid: false, reason: "audience_or_role_mismatch" };
  }
  if (typeof claims.sub !== "string" || !UUID_PATTERN.test(claims.sub)) {
    return { valid: false, reason: "invalid_subject" };
  }
  if (typeof claims.session_id !== "string" || !UUID_PATTERN.test(claims.session_id)) {
    return { valid: false, reason: "invalid_session_id" };
  }
  if (!Number.isInteger(claims.exp) || claims.exp <= nowSeconds - clockSkewSeconds) {
    return { valid: false, reason: "expired_token" };
  }
  if (!Number.isInteger(claims.iat) || claims.iat > nowSeconds + clockSkewSeconds || claims.iat > claims.exp) {
    return { valid: false, reason: "invalid_issued_at" };
  }
  if (claims.aal !== "aal2") return { valid: false, reason: "mfa_aal2_required" };
  return {
    valid: true,
    subject: claims.sub,
    providerSessionId: claims.session_id,
    assuranceLevel: "aal2",
    email: typeof claims.email === "string" ? claims.email : null
  };
}
