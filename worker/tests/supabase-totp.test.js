import test from "node:test";
import assert from "node:assert/strict";
import { verifyTotpForAal2 } from "../src/supabase-totp.js";

function mockSupabase({ aal = [{ currentLevel: "aal1", nextLevel: "aal2" }, { currentLevel: "aal2", nextLevel: "aal2" }], factors = [{ id: "totp-factor-1", status: "verified" }], challengeError = null, verifyError = null, listError = null } = {}) {
  const calls = [];
  return {
    calls,
    auth: { mfa: {
      async getAuthenticatorAssuranceLevel() { calls.push("aal"); return { data: aal.shift(), error: null }; },
      async listFactors() { calls.push("listFactors"); return { data: { totp: factors }, error: listError }; },
      async challenge(args) { calls.push(["challenge", args]); return { data: { id: "challenge-1" }, error: challengeError }; },
      async verify(args) { calls.push(["verify", args]); return { data: {}, error: verifyError }; }
    } }
  };
}

test("requires a six-digit TOTP code", async () => {
  const client = mockSupabase();
  assert.deepEqual(await verifyTotpForAal2(client, "12345"), { ok: false, reason: "invalid_totp_format" });
  assert.equal(client.calls.length, 0);
});

test("accepts an already AAL2 session without another challenge", async () => {
  const client = mockSupabase({ aal: [{ currentLevel: "aal2", nextLevel: "aal2" }] });
  assert.deepEqual(await verifyTotpForAal2(client, "123456"), { ok: true, assuranceLevel: "aal2", alreadyVerified: true });
  assert.deepEqual(client.calls, ["aal"]);
});

test("runs challenge and verify and confirms AAL2 after success", async () => {
  const client = mockSupabase();
  assert.deepEqual(await verifyTotpForAal2(client, "123456"), { ok: true, assuranceLevel: "aal2", alreadyVerified: false });
  assert.deepEqual(client.calls, [
    "aal", "listFactors",
    ["challenge", { factorId: "totp-factor-1" }],
    ["verify", { factorId: "totp-factor-1", challengeId: "challenge-1", code: "123456" }],
    "aal"
  ]);
});

test("rejects when no verified TOTP factor exists", async () => {
  const client = mockSupabase({ factors: [{ id: "pending-factor", status: "unverified" }] });
  assert.deepEqual(await verifyTotpForAal2(client, "123456"), { ok: false, reason: "verified_totp_factor_required" });
});

test("fails closed when multiple verified TOTP factors need selection", async () => {
  const client = mockSupabase({ factors: [
    { id: "factor-1", status: "verified" }, { id: "factor-2", status: "verified" }
  ] });
  assert.deepEqual(await verifyTotpForAal2(client, "123456"), { ok: false, reason: "multiple_totp_factors_require_selection" });
});

test("does not accept a successful verify response unless AAL2 is confirmed", async () => {
  const client = mockSupabase({ aal: [
    { currentLevel: "aal1", nextLevel: "aal2" },
    { currentLevel: "aal1", nextLevel: "aal2" }
  ] });
  assert.deepEqual(await verifyTotpForAal2(client, "123456"), { ok: false, reason: "aal2_confirmation_failed" });
});

test("fails closed on provider challenge and verify errors", async () => {
  const challengeClient = mockSupabase({ challengeError: new Error("failed") });
  assert.deepEqual(await verifyTotpForAal2(challengeClient, "123456"), { ok: false, reason: "totp_challenge_failed" });
  const verifyClient = mockSupabase({ verifyError: new Error("failed") });
  assert.deepEqual(await verifyTotpForAal2(verifyClient, "123456"), { ok: false, reason: "totp_verification_failed" });
});

test("password reset does not bypass TOTP while the session remains AAL1", async () => {
  const client = mockSupabase({
    aal: [
      { currentLevel: "aal1", nextLevel: "aal2" },
      { currentLevel: "aal2", nextLevel: "aal2" }
    ]
  });
  const result = await verifyTotpForAal2(client, "654321");
  assert.deepEqual(result, { ok: true, assuranceLevel: "aal2", alreadyVerified: false });
  assert.equal(client.calls.some((call) => Array.isArray(call) && call[0] === "challenge"), true);
  assert.equal(client.calls.some((call) => Array.isArray(call) && call[0] === "verify"), true);
});
