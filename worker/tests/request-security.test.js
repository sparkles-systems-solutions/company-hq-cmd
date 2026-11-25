import test from "node:test";
import assert from "node:assert/strict";
import { validateBrowserMutation } from "../src/request-security.js";

const ORIGIN = "https://cmd.example";
const TOKEN = "a".repeat(48);
function req(method, headers = {}) {
  return new Request(ORIGIN + "/api/change", { method, headers });
}
const validHeaders = {
  Origin: ORIGIN,
  "Sec-Fetch-Site": "same-origin",
  "Content-Type": "application/json",
  Cookie: "__Host-cmd_csrf=" + TOKEN,
  "x-cmd-csrf": TOKEN
};

test("allows safe methods without CSRF token", () => {
  assert.deepEqual(validateBrowserMutation(req("GET"), { allowedOrigin: ORIGIN }),
    { allowed: true, reason: "safe_method" });
});

test("allows same-origin JSON mutation with matching double-submit token", () => {
  assert.deepEqual(validateBrowserMutation(req("POST", validHeaders), { allowedOrigin: ORIGIN }),
    { allowed: true, reason: "origin_and_csrf_valid" });
});

test("rejects missing policy, missing origin and cross-origin requests", () => {
  assert.equal(validateBrowserMutation(req("POST", validHeaders), {}).status, 503);
  assert.equal(validateBrowserMutation(req("POST", {
    ...validHeaders, Origin: "https://evil.example"
  }), { allowedOrigin: ORIGIN }).reason, "origin_mismatch");
  const noOrigin = { ...validHeaders };
  delete noOrigin.Origin;
  assert.equal(validateBrowserMutation(req("POST", noOrigin), { allowedOrigin: ORIGIN }).status, 403);
});

test("rejects cross-site fetch metadata and non-JSON content types", () => {
  assert.equal(validateBrowserMutation(req("POST", {
    ...validHeaders, "Sec-Fetch-Site": "cross-site"
  }), { allowedOrigin: ORIGIN }).reason, "cross_site_request_denied");
  assert.equal(validateBrowserMutation(req("POST", {
    ...validHeaders, "Content-Type": "text/plain"
  }), { allowedOrigin: ORIGIN }).status, 415);
});

test("rejects missing, short or mismatched CSRF tokens", () => {
  for (const headers of [
    { ...validHeaders, "x-cmd-csrf": "b".repeat(48) },
    { ...validHeaders, Cookie: "" },
    { ...validHeaders, "x-cmd-csrf": "" }
  ]) {
    assert.equal(validateBrowserMutation(req("POST", headers), { allowedOrigin: ORIGIN }).reason,
      "csrf_token_invalid");
  }
});
