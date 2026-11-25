import { verifySupabaseAccessToken } from "./supabase-jwt-verifier.js";
import { resolveSupabaseHumanIdentity } from "./supabase-identity-mapping.js";

/**
 * Isolated request-boundary adapter.
 * Validates a bearer token and resolves its pre-provisioned human mapping.
 * It deliberately does not create CMD sessions or set cookies.
 */
export async function authenticateSupabaseBearer(request, env, {
  db,
  authProvider,
  verifyToken = verifySupabaseAccessToken
} = {}) {
  const authorization = request?.headers?.get?.("Authorization") || "";
  const match = /^Bearer ([A-Za-z0-9._~-]+)$/i.exec(authorization);
  if (!match || match[1].length < 20 || match[1].length > 16_384) {
    return { authenticated: false, status: 401, reason: "missing_or_invalid_bearer_token" };
  }

  let verified;
  try {
    verified = await verifyToken(match[1], env);
  } catch {
    return { authenticated: false, status: 401, reason: "token_verification_failed" };
  }
  if (!verified?.valid || verified.assuranceLevel !== "aal2") {
    return { authenticated: false, status: 401, reason: verified?.reason || "aal2_required" };
  }

  let mapped;
  try {
    mapped = await resolveSupabaseHumanIdentity(db, verified, { authProvider });
  } catch {
    return { authenticated: false, status: 503, reason: "identity_lookup_unavailable" };
  }
  if (!mapped.matched) {
    return { authenticated: false, status: 403, reason: mapped.reason };
  }

  return {
    authenticated: true,
    status: 200,
    identity: mapped.identity,
    providerSessionId: verified.providerSessionId
  };
}
