import test from "node:test";
import assert from "node:assert/strict";
import {
  parseCookies,
  isValidPermissionRequest,
  requiresFreshMfa,
  evaluateRolePolicy
} from "../src/authorization.js";

test("cookie parser handles multiple cookies and ignores malformed parts", () => {
  assert.deepEqual(
    { ...parseCookies("a=1; __Host-cmd_session=opaque-token; malformed; b=two") },
    { a: "1", "__Host-cmd_session": "opaque-token", b: "two" }
  );
});

test("permission request rejects unknown modules and actions", () => {
  assert.equal(isValidPermissionRequest({
    module: "PMO", action: "read", scopeType: "project", scopeId: "p-1"
  }), true);
  assert.equal(isValidPermissionRequest({
    module: "ROOT", action: "execute", scopeType: "company", scopeId: null
  }), false);
  assert.equal(isValidPermissionRequest({
    module: "PMO", action: "read", scopeType: "project", scopeId: null
  }), false);
});

test("company scope requires null scope id", () => {
  assert.equal(isValidPermissionRequest({
    module: "EXEC", action: "read", scopeType: "company", scopeId: null
  }), true);
  assert.equal(isValidPermissionRequest({
    module: "EXEC", action: "read", scopeType: "company", scopeId: "all"
  }), false);
});

test("fresh MFA is required for privileged actions and modules", () => {
  assert.equal(requiresFreshMfa({ module: "PMO", action: "read" }), false);
  assert.equal(requiresFreshMfa({ module: "FIN", action: "read" }), true);
  assert.equal(requiresFreshMfa({ module: "PMO", action: "execute" }), true);
});

test("virtual actor can never approve or execute", () => {
  assert.equal(evaluateRolePolicy({
    personType: "virtual", action: "approve", hasExplicitDeny: false, hasScopedAllow: true
  }).allowed, false);
  assert.equal(evaluateRolePolicy({
    personType: "virtual", action: "execute", hasExplicitDeny: false, hasScopedAllow: true
  }).allowed, false);
});

test("explicit deny overrides scoped allow", () => {
  assert.deepEqual(evaluateRolePolicy({
    personType: "human", action: "read", hasExplicitDeny: true, hasScopedAllow: true
  }), { allowed: false, reason: "explicit_deny" });
});

test("missing scoped allow is denied", () => {
  assert.deepEqual(evaluateRolePolicy({
    personType: "human", action: "draft", hasExplicitDeny: false, hasScopedAllow: false
  }), { allowed: false, reason: "no_matching_scoped_allow" });
});

test("matching scoped allow is accepted by policy evaluator", () => {
  assert.deepEqual(evaluateRolePolicy({
    personType: "human", action: "read", hasExplicitDeny: false, hasScopedAllow: true
  }), { allowed: true, reason: "scoped_allow" });
});
