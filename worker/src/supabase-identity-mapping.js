/**
 * Resolve a cryptographically verified Supabase subject to a pre-provisioned
 * CMD human identity. This is deliberately not a login/session issuer.
 *
 * authProvider must be selected by trusted server configuration and must match
 * the existing CMD auth_users catalogue. Never derive it from request input.
 */
const ALLOWED_AUTH_PROVIDERS = new Set(["email_otp", "oidc", "webauthn"]);

export async function resolveSupabaseHumanIdentity(db, verifiedClaims, {
  authProvider
} = {}) {
  if (!db || typeof db.prepare !== "function") {
    return { matched: false, reason: "identity_store_unavailable" };
  }
  if (!verifiedClaims || verifiedClaims.valid !== true ||
      verifiedClaims.assuranceLevel !== "aal2" ||
      typeof verifiedClaims.subject !== "string" ||
      !ALLOWED_AUTH_PROVIDERS.has(authProvider)) {
    return { matched: false, reason: "untrusted_or_incomplete_identity" };
  }

  const row = await db.prepare(`
    SELECT u.id AS auth_user_id, u.person_id, u.account_status,
           p.person_type, p.status AS person_status, p.display_name
      FROM auth_users u
      JOIN people p ON p.id = u.person_id
     WHERE u.auth_provider = ?
       AND u.provider_subject = ?
       AND u.account_status = 'active'
       AND p.person_type = 'human'
       AND p.status = 'active'
     LIMIT 1
  `).bind(authProvider, verifiedClaims.subject).first();

  if (!row) return { matched: false, reason: "no_active_human_identity_mapping" };
  return {
    matched: true,
    identity: {
      authUserId: row.auth_user_id,
      personId: row.person_id,
      personType: row.person_type,
      displayName: row.display_name
    }
  };
}
