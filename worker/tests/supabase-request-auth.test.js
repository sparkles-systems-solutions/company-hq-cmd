import test from "node:test";
import assert from "node:assert/strict";
import { authenticateSupabaseBearer } from "../src/supabase-request-auth.js";

const token = "x".repeat(40);
const verified = {
  valid: true,
  subject: "123e4567-e89b-42d3-a456-426614174000",
  providerSessionId: "123e4567-e89b-42d3-a456-426614174001",
  assuranceLevel: "aal2"
};

function request(value) {
  return new Request("https://cmd.example/api/prototype", {
    headers: value ? { Authorization: value } : {}
  });
}
function db(row) {
  return {
    prepare() {
      return { bind() { return { first: async () => row }; } };
    }
  };
}
const activeHuman = {
  auth_user_id: "auth-1", person_id: "person-1",
  person_type: "human", display_name: "Prototype CEO"
};

test("accepts verified AAL2 bearer mapped to active human identity", async () => {
  const result = await authenticateSupabaseBearer(request("Bearer " + token), {}, {
    db: db(activeHuman), authProvider: "oidc",
    verifyToken: async value => {
      assert.equal(value, token);
      return verified;
    }
  });
  assert.equal(result.authenticated, true);
  assert.equal(result.identity.personId, "person-1");
  assert.equal(result.providerSessionId, verified.providerSessionId);
});

test("rejects missing, malformed and oversized bearer tokens before verification", async () => {
  let called = false;
  const verifyToken = async () => { called = true; return verified; };
  for (const value of [null, "Basic abc", "Bearer short", "Bearer " + "x".repeat(17000)]) {
    const result = await authenticateSupabaseBearer(request(value), {}, {
      db: db(activeHuman), authProvider: "oidc", verifyToken
    });
    assert.equal(result.authenticated, false);
    assert.equal(result.status, 401);
  }
  assert.equal(called, false);
});

test("rejects AAL1 and invalid tokens", async () => {
  const result = await authenticateSupabaseBearer(request("Bearer " + token), {}, {
    db: db(activeHuman), authProvider: "oidc",
    verifyToken: async () => ({ valid: false, reason: "jwt_verification_failed" })
  });
  assert.deepEqual(result, {
    authenticated: false, status: 401, reason: "jwt_verification_failed"
  });
});

test("rejects unknown identity mapping and fails closed on D1 errors", async () => {
  const missing = await authenticateSupabaseBearer(request("Bearer " + token), {}, {
    db: db(null), authProvider: "oidc", verifyToken: async () => verified
  });
  assert.equal(missing.status, 403);

  const unavailable = await authenticateSupabaseBearer(request("Bearer " + token), {}, {
    db: { prepare() { throw new Error("db down"); } },
    authProvider: "oidc", verifyToken: async () => verified
  });
  assert.deepEqual(unavailable, {
    authenticated: false, status: 503, reason: "identity_lookup_unavailable"
  });
});
