import test from "node:test";
import assert from "node:assert/strict";
import { validateSupabaseAal2Claims } from "../src/supabase-auth-contract.js";

const ISSUER = "https://example-project.supabase.co/auth/v1";
const NOW = 1_800_000_000;
const VALID = {
  iss: ISSUER, aud: "authenticated", role: "authenticated",
  sub: "123e4567-e89b-42d3-a456-426614174000",
  session_id: "123e4567-e89b-42d3-a456-426614174001",
  iat: NOW - 60, exp: NOW + 300, aal: "aal2",
  email: "prototype@example.invalid"
};

test("accepts a correctly shaped, unexpired AAL2 claim set", () => {
  assert.deepEqual(validateSupabaseAal2Claims(VALID, { issuer: ISSUER, nowSeconds: NOW }), {
    valid: true, subject: VALID.sub, providerSessionId: VALID.session_id,
    assuranceLevel: "aal2", email: VALID.email
  });
});

test("rejects AAL1", () => {
  assert.equal(validateSupabaseAal2Claims({ ...VALID, aal: "aal1" }, { issuer: ISSUER, nowSeconds: NOW }).reason, "mfa_aal2_required");
});

test("rejects issuer and audience substitution", () => {
  assert.equal(validateSupabaseAal2Claims(VALID, { issuer: "https://attacker.invalid/auth/v1", nowSeconds: NOW }).reason, "issuer_mismatch");
  assert.equal(validateSupabaseAal2Claims({ ...VALID, aud: "anon" }, { issuer: ISSUER, nowSeconds: NOW }).reason, "audience_or_role_mismatch");
});

test("rejects malformed identity identifiers", () => {
  assert.equal(validateSupabaseAal2Claims({ ...VALID, sub: "virtual-role-id" }, { issuer: ISSUER, nowSeconds: NOW }).reason, "invalid_subject");
  assert.equal(validateSupabaseAal2Claims({ ...VALID, session_id: "not-a-uuid" }, { issuer: ISSUER, nowSeconds: NOW }).reason, "invalid_session_id");
});

test("rejects expired or future-issued tokens", () => {
  assert.equal(validateSupabaseAal2Claims({ ...VALID, exp: NOW - 100 }, { issuer: ISSUER, nowSeconds: NOW }).reason, "expired_token");
  assert.equal(validateSupabaseAal2Claims({ ...VALID, iat: NOW + 1000 }, { issuer: ISSUER, nowSeconds: NOW }).reason, "invalid_issued_at");
});

test("rejects missing, array, or non-object claims", () => {
  assert.equal(validateSupabaseAal2Claims(null, { issuer: ISSUER, nowSeconds: NOW }).reason, "invalid_claims");
  assert.equal(validateSupabaseAal2Claims([], { issuer: ISSUER, nowSeconds: NOW }).reason, "invalid_claims");
});

test("rejects an invalid configured issuer", () => {
  assert.equal(validateSupabaseAal2Claims(VALID, { issuer: "http://localhost", nowSeconds: NOW }).reason, "invalid_expected_issuer");
});
