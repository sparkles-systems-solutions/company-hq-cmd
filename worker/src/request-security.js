const SAFE_METHODS = new Set(["GET", "HEAD", "OPTIONS"]);
const CSRF_COOKIE = "__Host-cmd_csrf";
const CSRF_HEADER = "x-cmd-csrf";

function constantTimeEqual(left, right) {
  if (typeof left !== "string" || typeof right !== "string" || left.length !== right.length) {
    return false;
  }
  let mismatch = 0;
  for (let i = 0; i < left.length; i += 1) {
    mismatch |= left.charCodeAt(i) ^ right.charCodeAt(i);
  }
  return mismatch === 0;
}

function cookieValue(header, name) {
  for (const part of (header || "").split(";")) {
    const index = part.indexOf("=");
    if (index < 0) continue;
    if (part.slice(0, index).trim() === name) {
      return part.slice(index + 1).trim();
    }
  }
  return null;
}

/**
 * Browser mutation guard for cookie-authenticated routes.
 * Call only after route matching and before reading/mutating business data.
 * This does not issue or validate an authenticated session.
 */
export function validateBrowserMutation(request, { allowedOrigin } = {}) {
  if (!request || typeof request.method !== "string") {
    return { allowed: false, status: 400, reason: "invalid_request" };
  }
  if (SAFE_METHODS.has(request.method.toUpperCase())) {
    return { allowed: true, reason: "safe_method" };
  }
  if (typeof allowedOrigin !== "string" || !allowedOrigin) {
    return { allowed: false, status: 503, reason: "origin_policy_not_configured" };
  }

  const origin = request.headers.get("Origin");
  if (origin !== allowedOrigin) {
    return { allowed: false, status: 403, reason: "origin_mismatch" };
  }

  const fetchSite = request.headers.get("Sec-Fetch-Site");
  if (fetchSite && fetchSite !== "same-origin") {
    return { allowed: false, status: 403, reason: "cross_site_request_denied" };
  }

  const contentType = request.headers.get("Content-Type") || "";
  if (!/^application\/json(?:\s*;|$)/i.test(contentType)) {
    return { allowed: false, status: 415, reason: "json_content_type_required" };
  }

  const cookieToken = cookieValue(request.headers.get("Cookie"), CSRF_COOKIE);
  const headerToken = request.headers.get(CSRF_HEADER);
  if (!cookieToken || cookieToken.length < 32 || cookieToken.length > 256 ||
      !constantTimeEqual(cookieToken, headerToken)) {
    return { allowed: false, status: 403, reason: "csrf_token_invalid" };
  }

  return { allowed: true, reason: "origin_and_csrf_valid" };
}
