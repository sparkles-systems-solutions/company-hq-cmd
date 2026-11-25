import { createRemoteJWKSet, jwtVerify } from "jose";
import { validateSupabaseAal2Claims } from "./supabase-auth-contract.js";

const jwksCache = new Map();
const ALLOWED_ALGORITHMS = ["ES256", "RS256", "EdDSA"];

function resolveSupabaseProject(env) {
  if (typeof env?.SUPABASE_URL !== "string") {
    throw new Error("supabase_url_not_configured");
  }
  const url = new URL(env.SUPABASE_URL);
  if (
    url.protocol !== "https:" ||
    url.username ||
    url.password ||
    url.search ||
    url.hash ||
    url.pathname !== "/" ||
    !/^[a-z0-9-]+\.supabase\.co$/i.test(url.hostname)
  ) {
    throw new Error("invalid_supabase_project_url");
  }
  const issuer = url.origin + "/auth/v1";
  return {
    issuer,
    jwksUrl: new URL(issuer + "/.well-known/jwks.json")
  };
}

function getRemoteJwks(jwksUrl) {
  const key = jwksUrl.href;
  if (!jwksCache.has(key)) {
    jwksCache.set(key, createRemoteJWKSet(jwksUrl));
  }
  return jwksCache.get(key);
}

/**
 * Verify a Supabase Auth access token with the project's asymmetric JWKS.
 * Fails closed for legacy symmetric signing configurations: those require a
 * separately reviewed Auth-server introspection path, not a shared secret here.
 */
export async function verifySupabaseAccessToken(token, env, options = {}) {
  if (typeof token !== "string" || token.length < 20 || token.length > 16_384) {
    return { valid: false, reason: "invalid_token" };
  }

  let project;
  try {
    project = resolveSupabaseProject(env);
  } catch (error) {
    return { valid: false, reason: error.message };
  }

  try {
    const jwks = options.jwks || getRemoteJwks(project.jwksUrl);
    const verified = await jwtVerify(token, jwks, {
      issuer: project.issuer,
      audience: "authenticated",
      algorithms: ALLOWED_ALGORITHMS,
      clockTolerance: 30
    });
    const checked = validateSupabaseAal2Claims(verified.payload, {
      issuer: project.issuer,
      nowSeconds: options.nowSeconds ?? Math.floor(Date.now() / 1000),
      clockSkewSeconds: 30
    });
    if (!checked.valid) return checked;
    if (verified.payload.is_anonymous === true) {
      return { valid: false, reason: "anonymous_identity_denied" };
    }
    return checked;
  } catch {
    return { valid: false, reason: "jwt_verification_failed" };
  }
}
