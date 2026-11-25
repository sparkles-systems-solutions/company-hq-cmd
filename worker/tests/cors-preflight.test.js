import test from "node:test";
import assert from "node:assert/strict";
import worker from "../src/index.js";

const ALLOWED_ORIGIN = "https://cmd.example";

test("CORS preflight for allowed origin currently permits content-type only", async () => {
  const request = new Request("https://api.example/api/change", {
    method: "OPTIONS",
    headers: {
      Origin: ALLOWED_ORIGIN,
      "Access-Control-Request-Method": "POST",
      "Access-Control-Request-Headers": "content-type, x-cmd-csrf"
    }
  });

  const response = await worker.fetch(request, { ALLOWED_ORIGIN });
  assert.equal(response.status, 204);
  assert.equal(response.headers.get("access-control-allow-origin"), ALLOWED_ORIGIN);
  assert.equal(response.headers.get("access-control-allow-methods"), "GET, POST, OPTIONS");

  const allowedHeaders = (response.headers.get("access-control-allow-headers") || "")
    .split(",").map((value) => value.trim().toLowerCase());
  assert.deepEqual(allowedHeaders, ["content-type"]);
  assert.equal(allowedHeaders.includes("x-cmd-csrf"), false,
    "CSRF header is intentionally not enabled until a separately approved integration change");
});

test("CORS preflight rejects an origin that is not configured", async () => {
  const request = new Request("https://api.example/api/change", {
    method: "OPTIONS",
    headers: { Origin: "https://attacker.example" }
  });
  const response = await worker.fetch(request, { ALLOWED_ORIGIN });
  assert.equal(response.status, 403);
  assert.equal(response.headers.get("access-control-allow-origin"), null);
});

test("CORS preflight fails closed when allowed origin is not configured", async () => {
  const request = new Request("https://api.example/api/change", {
    method: "OPTIONS",
    headers: { Origin: ALLOWED_ORIGIN }
  });
  const response = await worker.fetch(request, {});
  assert.equal(response.status, 403);
});
