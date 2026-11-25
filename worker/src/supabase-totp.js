/**
 * Client-side Supabase TOTP step-up adapter.
 * The caller must already have completed the configured first factor.
 * This module never returns or logs the TOTP seed, QR code, or code.
 */

export async function verifyTotpForAal2(supabase, code) {
  if (!supabase?.auth?.mfa) {
    return { ok: false, reason: "supabase_mfa_client_unavailable" };
  }
  if (typeof code !== "string" || !/^\d{6}$/.test(code)) {
    return { ok: false, reason: "invalid_totp_format" };
  }

  const aal = await supabase.auth.mfa.getAuthenticatorAssuranceLevel();
  if (aal.error) return { ok: false, reason: "aal_check_failed" };
  if (aal.data?.currentLevel === "aal2" && aal.data?.nextLevel === "aal2") {
    return { ok: true, assuranceLevel: "aal2", alreadyVerified: true };
  }
  if (aal.data?.nextLevel !== "aal2") {
    return { ok: false, reason: "aal2_not_required_or_factor_not_enrolled" };
  }

  const listed = await supabase.auth.mfa.listFactors();
  if (listed.error) return { ok: false, reason: "factor_list_failed" };
  const factors = (listed.data?.totp || []).filter((factor) =>
    factor?.status === "verified" && typeof factor.id === "string" && factor.id.length > 0
  );
  if (factors.length !== 1) {
    return {
      ok: false,
      reason: factors.length === 0 ? "verified_totp_factor_required" : "multiple_totp_factors_require_selection"
    };
  }

  const factorId = factors[0].id;
  const challenge = await supabase.auth.mfa.challenge({ factorId });
  if (challenge.error || typeof challenge.data?.id !== "string") {
    return { ok: false, reason: "totp_challenge_failed" };
  }

  const verified = await supabase.auth.mfa.verify({
    factorId,
    challengeId: challenge.data.id,
    code
  });
  if (verified.error) return { ok: false, reason: "totp_verification_failed" };

  const confirmed = await supabase.auth.mfa.getAuthenticatorAssuranceLevel();
  if (confirmed.error ||
      confirmed.data?.currentLevel !== "aal2" ||
      confirmed.data?.nextLevel !== "aal2") {
    return { ok: false, reason: "aal2_confirmation_failed" };
  }

  return { ok: true, assuranceLevel: "aal2", alreadyVerified: false };
}
