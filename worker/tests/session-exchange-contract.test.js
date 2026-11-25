import test from "node:test";
import assert from "node:assert/strict";
import { planCmdSessionExchange } from "../src/session-exchange-contract.js";

const NOW = Date.parse("2026-11-25T12:00:00.000Z");
const UUID_AUTH = "123e4567-e89b-42d3-a456-426614174000";
const UUID_PERSON = "123e4567-e89b-42d3-a456-426614174001";
const HASH = "a".repeat(64);
const valid = (overrides = {}) => ({
  jwtSignatureVerified: true,
  issuerAudienceExpiryVerified: true,
  assuranceLevel: "aal2",
  authProvider: "email_password",
  emailVerified: true,
  mfaVerifiedAt: new Date(NOW - 60_000).toISOString(),
  activeHuman: true,
  authUserId: UUID_AUTH,
  personId: UUID_PERSON,
  exchangeKeyHash: HASH,
  exchangeKeyExpiresAt: NOW + 60_000,
  exchangeKeyConsumed: false,
  browserMutationValidated: true,
  now: NOW,
  ...overrides
});

test("valid trusted AAL2 email/password human produces a non-secret plan only", () => {
  const result = planCmdSessionExchange(valid());
  assert.equal(result.accepted, true);
  assert.equal(result.plan.authUserId, UUID_AUTH);
  assert.equal(result.plan.personId, UUID_PERSON);
  assert.equal(Date.parse(result.plan.expiresAt) - Date.parse(result.plan.issuedAt), 12 * 60 * 60 * 1000);
  assert.equal(result.plan.requiresAtomicSessionAuditExchangeConsume, true);
  assert.equal(result.plan.cookieMayBeIssuedOnlyAfterAtomicCommit, true);
  assert.equal("sessionToken" in result.plan, false);
  assert.equal("cookie" in result.plan, false);
  assert.equal("accessToken" in result.plan, false);
});

const rejected = [
  ["unverified JWT signature", { jwtSignatureVerified: false }, "trusted_provider_token_required"],
  ["unverified issuer/audience/expiry", { issuerAudienceExpiryVerified: false }, "trusted_provider_token_required"],
  ["AAL1", { assuranceLevel: "aal1" }, "mfa_aal2_required"],
  ["unapproved provider", { authProvider: "request_selected" }, "approved_auth_provider_required"],
  ["unverified email", { emailVerified: false }, "verified_email_required"],
  ["inactive or virtual identity", { activeHuman: false }, "active_human_identity_required"],
  ["malformed auth user id", { authUserId: "not-a-uuid" }, "invalid_mapped_identity"],
  ["malformed person id", { personId: "not-a-uuid" }, "invalid_mapped_identity"],
  ["stale MFA", { mfaVerifiedAt: new Date(NOW - 10 * 60_000 - 1).toISOString() }, "fresh_mfa_required"],
  ["missing browser mutation validation", { browserMutationValidated: false }, "browser_mutation_guard_required"],
  ["raw or malformed exchange key", { exchangeKeyHash: "raw-key" }, "invalid_exchange_key_hash"],
  ["replayed exchange key", { exchangeKeyConsumed: true }, "exchange_key_unavailable"],
  ["expired exchange key", { exchangeKeyExpiresAt: NOW }, "exchange_key_expired_or_too_long"],
  ["exchange key lifetime too long", { exchangeKeyExpiresAt: NOW + 5 * 60_000 + 1 }, "exchange_key_expired_or_too_long"]
];

for (const [name, override, reason] of rejected) {
  test("rejects " + name, () => {
    assert.deepEqual(planCmdSessionExchange(valid(override)), { accepted: false, reason });
  });
}

test("does not trust client-supplied identity or role fields", () => {
  const result = planCmdSessionExchange(valid({
    requestBody: { personId: "attacker", role: "CEO", scope: ["*"] }
  }));
  assert.equal(result.accepted, true);
  assert.equal(result.plan.personId, UUID_PERSON);
  assert.equal("role" in result.plan, false);
  assert.equal("scope" in result.plan, false);
});

test("does not consume exchange key, write D1, or create token/cookie", () => {
  let writes = 0;
  const result = planCmdSessionExchange(valid({ onConsume: () => { writes += 1; } }));
  assert.equal(result.accepted, true);
  assert.equal(writes, 0);
});
