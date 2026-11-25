import test from "node:test";
import assert from "node:assert/strict";
import { resolveSupabaseHumanIdentity } from "../src/supabase-identity-mapping.js";

const claims = {
  valid: true,
  subject: "123e4567-e89b-42d3-a456-426614174000",
  assuranceLevel: "aal2"
};

function dbReturning(row, capture = {}) {
  return {
    prepare(sql) {
      capture.sql = sql;
      return {
        bind(...values) {
          capture.values = values;
          return { first: async () => row };
        }
      };
    }
  };
}

test("maps verified AAL2 email/password Supabase subject to active human CMD identity", async () => {
  const capture = {};
  const result = await resolveSupabaseHumanIdentity(dbReturning({
    auth_user_id: "auth-1", person_id: "person-1", account_status: "active",
    person_type: "human", person_status: "active", display_name: "Prototype CEO"
  }, capture), claims, { authProvider: "email_password" });
  assert.equal(result.matched, true);
  assert.deepEqual(capture.values, ["email_password", claims.subject]);
  assert.ok(capture.sql.includes("p.person_type = 'human'"));
  assert.ok(capture.sql.includes("p.status = 'active'"));
});

test("rejects unverified claims, AAL1 and request-controlled provider values before querying", async () => {
  let queried = false;
  const db = { prepare() { queried = true; throw new Error("must not query"); } };
  assert.equal((await resolveSupabaseHumanIdentity(db, { ...claims, valid: false }, { authProvider: "email_password" })).reason,
    "untrusted_or_incomplete_identity");
  assert.equal((await resolveSupabaseHumanIdentity(db, { ...claims, assuranceLevel: "aal1" }, { authProvider: "email_password" })).matched, false);
  assert.equal((await resolveSupabaseHumanIdentity(db, claims, { authProvider: "admin" })).matched, false);
  assert.equal(queried, false);
});

test("denies missing active human mapping", async () => {
  assert.deepEqual(await resolveSupabaseHumanIdentity(dbReturning(null), claims, { authProvider: "email_password" }),
    { matched: false, reason: "no_active_human_identity_mapping" });
});

test("fails closed when identity store is unavailable", async () => {
  assert.deepEqual(await resolveSupabaseHumanIdentity(null, claims, { authProvider: "email_password" }),
    { matched: false, reason: "identity_store_unavailable" });
});
