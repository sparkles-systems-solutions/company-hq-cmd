/**
 * Isolated contract for Supabase email/password sign-in responses.
 *
 * The Supabase Auth SDK performs password verification. CMD must never
 * receive/store the password or infer email verification from user_metadata.
 * This helper accepts only the trusted Auth SDK response object and does not
 * verify JWTs, issue CMD sessions, or grant permissions.
 */
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function validateSupabaseEmailPasswordSignIn(authResponse) {
  if (!authResponse || typeof authResponse !== "object" || Array.isArray(authResponse)) {
    return { accepted: false, reason: "invalid_auth_response" };
  }
  if (authResponse.error) {
    return { accepted: false, reason: "provider_sign_in_failed" };
  }

  const user = authResponse.data?.user;
  const session = authResponse.data?.session;
  if (!user || typeof user !== "object" || !UUID_PATTERN.test(user.id || "")) {
    return { accepted: false, reason: "invalid_provider_user" };
  }
  if (typeof user.email !== "string" || user.email.trim().length === 0) {
    return { accepted: false, reason: "verified_email_required" };
  }

  // Supabase Auth's trusted user response exposes email_confirmed_at.
  // Do not trust a browser-supplied flag or user_metadata value.
  const confirmedAt = user.email_confirmed_at ?? user.confirmed_at;
  if (typeof confirmedAt !== "string" || confirmedAt.trim().length === 0) {
    return { accepted: false, reason: "verified_email_required" };
  }
  if (!session || typeof session.access_token !== "string" || session.access_token.length === 0) {
    return { accepted: false, reason: "provider_session_missing" };
  }

  // Never return the password, access token, refresh token, or full provider object.
  return {
    accepted: true,
    providerSubject: user.id,
    email: user.email,
    emailVerified: true,
    requiresAal2: true
  };
}
