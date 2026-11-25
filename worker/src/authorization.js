/**
 * CMD authorization primitives.
 * No browser-supplied role or permission values are accepted.
 */

export const ACTIONS = new Set(["read", "draft", "propose", "test", "approve", "execute"]);
export const MODULES = new Set(["EXEC", "HR", "PMO", "QA", "FIN", "OPS", "SEC", "DOC", "REL", "SHARE"]);
const PRIVILEGED_MODULES = new Set(["HR", "FIN", "SEC", "REL", "SHARE"]);

export function parseCookies(header = "") {
  const result = Object.create(null);
  for (const part of header.split(";")) {
    const index = part.indexOf("=");
    if (index < 1) continue;
    const key = part.slice(0, index).trim();
    const value = part.slice(index + 1).trim();
    if (!Object.hasOwn(result, key)) result[key] = value;
  }
  return result;
}

export function isValidPermissionRequest(request) {
  return Boolean(
    request &&
    MODULES.has(request.module) &&
    ACTIONS.has(request.action) &&
    ["company", "department", "project", "record"].includes(request.scopeType) &&
    (request.scopeType === "company"
      ? request.scopeId === null
      : typeof request.scopeId === "string" && request.scopeId.trim().length > 0)
  );
}

export function requiresFreshMfa(request) {
  return request.action === "approve" ||
    request.action === "execute" ||
    PRIVILEGED_MODULES.has(request.module);
}

export function evaluateRolePolicy({ personType, action, hasExplicitDeny, hasScopedAllow }) {
  if (personType === "virtual" && (action === "approve" || action === "execute")) {
    return { allowed: false, reason: "virtual_privileged_action_denied" };
  }
  if (hasExplicitDeny) return { allowed: false, reason: "explicit_deny" };
  if (!hasScopedAllow) return { allowed: false, reason: "no_matching_scoped_allow" };
  return { allowed: true, reason: "scoped_allow" };
}

export async function sha256Hex(value) {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
