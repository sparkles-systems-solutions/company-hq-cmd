import test from "node:test";
import assert from "node:assert/strict";
import { generateKeyPair, exportJWK, SignJWT, createLocalJWKSet } from "jose";
import { verifySupabaseAccessToken } from "../src/supabase-jwt-verifier.js";

const NOW = 1_800_000_000;
const PROJECT_URL = "https://example-project.supabase.co";
const ISSUER = PROJECT_URL + "/auth/v1";
const ENV = { SUPABASE_URL: PROJECT_URL };
const BASE_CLAIMS = {
  aud: "authenticated",
  role: "authenticated",
  sub: "123e4567-e89b-42d3-a456-426614174000",
  session_id: "123e4567-e89b-42d3-a456-426614174001",
  aal: "aal2",
  email: "prototype@example.invalid",
  is_anonymous: false
};

async function fixture(overrides = {}, tokenOverrides = {}) {
  const { publicKey, privateKey } = await generateKeyPair("ES256");
  const jwk = await exportJWK(publicKey);
  jwk.kid = "prototype-key-1";
  jwk.alg = "ES256";
  jwk.use = "sig";
  const jwks = createLocalJWKSet({ keys: [jwk] });
  const token = await new SignJWT({ ...BASE_CLAIMS, ...overrides })
    .setProtectedHeader({ alg: "ES256", kid: "prototype-key-1", typ: "JWT" })
    .setIssuer(ISSUER)
    .setAudience("authenticated")
    .setSubject((overrides.sub || BASE_CLAIMS.sub))
    .setIssuedAt(NOW - 30)
    .setExpirationTime(NOW + 300)
    .setJti("123e4567-e89b-42d3-a456-426614174002")
    .sign(privateKey);
  return { token, jwks };
}

test("verifies valid signed Supabase AAL2 access token", async () => {
  const { token, jwks } = await fixture();
  const result = await verifySupabaseAccessToken(token, ENV, { jwks, nowSeconds: NOW });
  assert.equal(result.valid, true);
  assert.equal(result.assuranceLevel, "aal2");
  assert.equal(result.subject, BASE_CLAIMS.sub);
});

test("rejects correctly signed AAL1 token", async () => {
  const { token, jwks } = await fixture({ aal: "aal1" });
  const result = await verifySupabaseAccessToken(token, ENV, { jwks, nowSeconds: NOW });
  assert.deepEqual(result, { valid: false, reason: "mfa_aal2_required" });
});

test("rejects tampered and incorrectly signed tokens", async () => {
  const { token, jwks } = await fixture();
  const [header, payload, signature] = token.split(".");
  const decodedPayload = JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
  decodedPayload.sub = "223e4567-e89b-42d3-a456-426614174000";
  const tamperedPayload = Buffer.from(JSON.stringify(decodedPayload)).toString("base64url");
  const tampered = [header, tamperedPayload, signature].join(".");
  const result = await verifySupabaseAccessToken(tampered, ENV, { jwks, nowSeconds: NOW });
  assert.equal(result.valid, false);
  assert.equal(result.reason, "jwt_verification_failed");
});

test("rejects anonymous identities", async () => {
  const { token, jwks } = await fixture({ is_anonymous: true });
  const result = await verifySupabaseAccessToken(token, ENV, { jwks, nowSeconds: NOW });
  assert.deepEqual(result, { valid: false, reason: "anonymous_identity_denied" });
});

test("rejects invalid Supabase URL and missing configuration", async () => {
  assert.equal((await verifySupabaseAccessToken("a".repeat(30), {}, {})).reason, "supabase_url_not_configured");
  assert.equal((await verifySupabaseAccessToken("a".repeat(30), { SUPABASE_URL: "http://example-project.supabase.co" })).reason, "invalid_supabase_project_url");
  assert.equal((await verifySupabaseAccessToken("a".repeat(30), { SUPABASE_URL: "https://attacker.example" })).reason, "invalid_supabase_project_url");
});

test("rejects malformed token input", async () => {
  assert.equal((await verifySupabaseAccessToken("", ENV)).reason, "invalid_token");
  assert.equal((await verifySupabaseAccessToken("x".repeat(17000), ENV)).reason, "invalid_token");
});

test("rejects expired signed tokens", async () => {
  const { publicKey, privateKey } = await generateKeyPair("ES256");
  const jwk = await exportJWK(publicKey);
  jwk.kid = "prototype-key-1";
  jwk.alg = "ES256";
  jwk.use = "sig";
  const jwks = createLocalJWKSet({ keys: [jwk] });
  const expired = await new SignJWT(BASE_CLAIMS)
    .setProtectedHeader({ alg: "ES256", kid: "prototype-key-1" })
    .setIssuer(ISSUER)
    .setAudience("authenticated")
    .setSubject(BASE_CLAIMS.sub)
    .setIssuedAt(NOW - 600)
    .setExpirationTime(NOW - 60)
    .sign(privateKey);
  const result = await verifySupabaseAccessToken(expired, ENV, { jwks, nowSeconds: NOW });
  assert.deepEqual(result, { valid: false, reason: "jwt_verification_failed" });
});

test("rejects tokens signed by an untrusted key", async () => {
  const { token } = await fixture();
  const { publicKey } = await generateKeyPair("ES256");
  const jwk = await exportJWK(publicKey);
  jwk.kid = "different-key";
  jwk.alg = "ES256";
  const result = await verifySupabaseAccessToken(token, ENV, {
    jwks: createLocalJWKSet({ keys: [jwk] }),
    nowSeconds: NOW
  });
  assert.deepEqual(result, { valid: false, reason: "jwt_verification_failed" });
});
