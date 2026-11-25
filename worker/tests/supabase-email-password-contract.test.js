import test from "node:test";
import assert from "node:assert/strict";
import { validateSupabaseEmailPasswordSignIn } from "../src/supabase-email-password-contract.js";
import { validateSupabaseAal2Claims } from "../src/supabase-auth-contract.js";

const ISSUER = "https://example-project.supabase.co/auth/v1";
const USER_ID = "123e4567-e89b-42d3-a456-426614174000";
const SESSION_ID = "123e4567-e89b-42d3-a456-426614174001";
const NOW = 1_800_000_000;

function response(overrides = {}) {
  return {
    data: {
      user: {
        id: USER_ID,
        email: "prototype@example.invalid",
        email_confirmed_at: "2026-11-25T00:00:00.000Z",
        ...overrides.user
      },
      session: { access_token: "synthetic-access-token", refresh_token: "synthetic-refresh-token" }
    },
    error: null
  };
}

test("accepts trusted Supabase email/password result only with confirmed email and session", () => {
  const result = validateSupabaseEmailPasswordSignIn(response());
  assert.deepEqual(result, {
    accepted: true,
    providerSubject: USER_ID,
    email: "prototype@example.invalid",
    emailVerified: true,
    requiresAal2: true
  });
  assert.equal("access_token" in result, false);
  assert.equal("refresh_token" in result, false);
});

test("rejects unverified email even when user_metadata claims it is verified", () => {
  const result = validateSupabaseEmailPasswordSignIn(response({
    user: {
      email_confirmed_at: null,
      user_metadata: { email_verified: true }
    }
  }));
  assert.deepEqual(result, { accepted: false, reason: "verified_email_required" });
});

test("rejects missing email and malformed provider subject", () => {
  assert.equal(validateSupabaseEmailPasswordSignIn(response({ user: { email: "" } })).reason,
    "verified_email_required");
  assert.equal(validateSupabaseEmailPasswordSignIn(response({ user: { id: "not-a-uuid" } })).reason,
    "invalid_provider_user");
});

test("rejects provider errors and missing provider session without leaking details", () => {
  assert.deepEqual(validateSupabaseEmailPasswordSignIn({ error: new Error("sensitive provider detail") }),
    { accepted: false, reason: "provider_sign_in_failed" });
  const missingSession = response();
  missingSession.data.session = null;
  assert.deepEqual(validateSupabaseEmailPasswordSignIn(missingSession),
    { accepted: false, reason: "provider_session_missing" });
});

test("confirmed email and password sign-in are not sufficient: AAL1 remains denied", () => {
  const signIn = validateSupabaseEmailPasswordSignIn(response());
  assert.equal(signIn.accepted, true);
  const claims = {
    iss: ISSUER, aud: "authenticated", role: "authenticated",
    sub: USER_ID, session_id: SESSION_ID,
    iat: NOW - 60, exp: NOW + 300, aal: "aal1"
  };
  assert.deepEqual(validateSupabaseAal2Claims(claims, { issuer: ISSUER, nowSeconds: NOW }),
    { valid: false, reason: "mfa_aal2_required" });
});

test("only a separately verified AAL2 token passes the second gate", () => {
  const claims = {
    iss: ISSUER, aud: "authenticated", role: "authenticated",
    sub: USER_ID, session_id: SESSION_ID,
    iat: NOW - 60, exp: NOW + 300, aal: "aal2"
  };
  assert.equal(validateSupabaseAal2Claims(claims, { issuer: ISSUER, nowSeconds: NOW }).valid, true);
});
