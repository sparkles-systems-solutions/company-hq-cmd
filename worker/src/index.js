import {
  parseCookies,
  isValidPermissionRequest,
  requiresFreshMfa,
  evaluateRolePolicy,
  sha256Hex
} from "./authorization.js";

const SESSION_COOKIE = "__Host-cmd_session";
const MFA_MAX_AGE_SECONDS = 10 * 60;

function json(data, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store, max-age=0",
      "x-content-type-options": "nosniff",
      "referrer-policy": "no-referrer",
      "x-frame-options": "DENY",
      "content-security-policy": "default-src 'none'; frame-ancestors 'none'",
      ...extraHeaders
    }
  });
}

function corsHeaders(request, env) {
  const origin = request.headers.get("Origin");
  const allowed = env.ALLOWED_ORIGIN;
  if (!origin || !allowed || origin !== allowed) return {};
  return {
    "access-control-allow-origin": allowed,
    "access-control-allow-credentials": "true",
    "access-control-allow-headers": "content-type",
    "access-control-allow-methods": "GET, POST, OPTIONS",
    "vary": "Origin"
  };
}

async function audit(db, { actorId = null, action, entityType, entityId = null, requestId, metadata = {} }) {
  await db.prepare(
    "INSERT INTO audit_logs (id, actor_id, action, entity_type, entity_id, request_id, metadata_json) VALUES (?, ?, ?, ?, ?, ?, ?)"
  ).bind(
    crypto.randomUUID(), actorId, action, entityType, entityId,
    requestId, JSON.stringify(metadata)
  ).run();
}

async function authenticate(request, env, requestId) {
  const rawToken = parseCookies(request.headers.get("Cookie") || "")[SESSION_COOKIE];
  if (!rawToken || rawToken.length < 32 || rawToken.length > 512) {
    return { ok: false, status: 401, reason: "missing_or_invalid_session" };
  }

  const tokenHash = await sha256Hex(rawToken);
  const row = await env.DB.prepare(`
    SELECT s.id AS session_id, s.auth_user_id, s.expires_at, s.mfa_verified_at,
           u.person_id, p.person_type, p.status AS person_status,
           u.account_status, p.display_name
      FROM auth_sessions s
      JOIN auth_users u ON u.id = s.auth_user_id
      JOIN people p ON p.id = u.person_id
     WHERE s.session_token_hash = ?
       AND s.revoked_at IS NULL
       AND s.expires_at > CURRENT_TIMESTAMP
       AND u.account_status = 'active'
       AND p.status = 'active'
  `).bind(tokenHash).first();

  if (!row || row.person_type !== "human") {
    await audit(env.DB, {
      action: "auth.session_denied", entityType: "auth_session",
      requestId, metadata: { reason: "session_not_active_or_human" }
    });
    return { ok: false, status: 401, reason: "invalid_session" };
  }

  return {
    ok: true,
    actor: {
      personId: row.person_id,
      personType: row.person_type,
      displayName: row.display_name,
      sessionId: row.session_id,
      mfaVerifiedAt: row.mfa_verified_at
    }
  };
}

function isFreshMfa(value) {
  if (!value) return false;
  const normalized = value.includes("T") ? value : value.replace(" ", "T");
  const hasTimezone = /(?:Z|[+-]\d{2}:?\d{2})$/i.test(normalized);
  const timestamp = Date.parse(normalized + (hasTimezone ? "" : "Z"));
  return Number.isFinite(timestamp) &&
    timestamp <= Date.now() + 30_000 &&
    Date.now() - timestamp <= MFA_MAX_AGE_SECONDS * 1000;
}

/**
 * Resolve authorization from current D1 rows. Caller must supply a server-defined
 * permission request; never pass request-body role/module/action/scope values here.
 */
export async function authorizeActor(db, actor, permissionRequest, requestId) {
  if (!isValidPermissionRequest(permissionRequest)) {
    await audit(db, {
      actorId: actor.personId, action: "auth.invalid_policy_request",
      entityType: "authorization", requestId
    });
    return { allowed: false, status: 400, reason: "invalid_permission_request" };
  }

  if (actor.personType === "virtual" &&
      (permissionRequest.action === "approve" || permissionRequest.action === "execute")) {
    await audit(db, {
      actorId: actor.personId, action: "auth.virtual_privileged_denied",
      entityType: "authorization", requestId,
      metadata: { module: permissionRequest.module, action: permissionRequest.action }
    });
    return { allowed: false, status: 403, reason: "virtual_privileged_action_denied" };
  }

  if (requiresFreshMfa(permissionRequest) && !isFreshMfa(actor.mfaVerifiedAt)) {
    await audit(db, {
      actorId: actor.personId, action: "auth.mfa_required",
      entityType: "authorization", requestId,
      metadata: { module: permissionRequest.module, action: permissionRequest.action }
    });
    return { allowed: false, status: 403, reason: "fresh_mfa_required" };
  }

  const assignments = await db.prepare(`
    SELECT ra.id AS assignment_id, ra.role_id
      FROM role_assignments ra
      JOIN people p ON p.id = ra.person_id
     WHERE ra.person_id = ?
       AND p.status = 'active'
       AND (ra.expires_at IS NULL OR ra.expires_at > CURRENT_TIMESTAMP)
  `).bind(actor.personId).all();

  const rows = assignments.results || [];
  if (!rows.length) {
    await audit(db, {
      actorId: actor.personId, action: "auth.no_active_role",
      entityType: "authorization", requestId
    });
    return { allowed: false, status: 403, reason: "no_active_role" };
  }

  const roleIds = rows.map((r) => r.role_id);
  const placeholders = roleIds.map(() => "?").join(",");
  const policyRows = await db.prepare(`
    SELECT effect
      FROM role_permission_rules
     WHERE role_id IN (${placeholders})
       AND module_key = ?
       AND action_key = ?
  `).bind(...roleIds, permissionRequest.module, permissionRequest.action).all();

  const hasDeny = (policyRows.results || []).some((p) => p.effect === "deny");

  // Bind the permission rule to the exact same role assignment that owns the scope grant.
  // This prevents permission on one role being combined with another role's scope.
  const scopedAllow = await db.prepare(`
    SELECT 1
      FROM role_scope_grants g
      JOIN role_assignments ra ON ra.id = g.role_assignment_id
      JOIN role_permission_rules pr
        ON pr.role_id = ra.role_id
       AND pr.module_key = g.module_key
       AND pr.action_key = ?
       AND pr.effect = 'allow'
     WHERE ra.person_id = ?
       AND ra.role_id IN (${placeholders})
       AND (ra.expires_at IS NULL OR ra.expires_at > CURRENT_TIMESTAMP)
       AND g.module_key = ?
       AND g.grant_status = 'active'
       AND (g.expires_at IS NULL OR g.expires_at > CURRENT_TIMESTAMP)
       AND (
         (g.scope_type = 'company' AND g.scope_id IS NULL)
         OR (g.scope_type = ? AND g.scope_id = ?)
       )
     LIMIT 1
  `).bind(
    permissionRequest.action, actor.personId, ...roleIds,
    permissionRequest.module, permissionRequest.scopeType, permissionRequest.scopeId
  ).first();

  const decision = evaluateRolePolicy({
    personType: actor.personType,
    action: permissionRequest.action,
    hasExplicitDeny: hasDeny,
    hasScopedAllow: Boolean(scopedAllow)
  });

  await audit(db, {
    actorId: actor.personId,
    action: decision.allowed ? "auth.access_allowed" : "auth.access_denied",
    entityType: "authorization",
    entityId: permissionRequest.scopeId,
    requestId,
    metadata: {
      module: permissionRequest.module,
      action: permissionRequest.action,
      scopeType: permissionRequest.scopeType,
      reason: decision.reason
    }
  });

  return decision.allowed
    ? { allowed: true, status: 200, reason: decision.reason }
    : { allowed: false, status: 403, reason: decision.reason };
}

export default {
  async fetch(request, env) {
    const requestId = crypto.randomUUID();
    const headers = corsHeaders(request, env);
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      if (!headers["access-control-allow-origin"]) return json({ error: "origin_not_allowed" }, 403);
      return new Response(null, { status: 204, headers });
    }

    if (url.pathname === "/api/health" && request.method === "GET") {
      return json({ status: "ok", service: "cmd-api", mode: "authorization-foundation" }, 200, headers);
    }

    if (url.pathname === "/api/me" && request.method === "GET") {
      if (!env.DB) return json({ error: "service_unavailable" }, 503, headers);
      try {
        const auth = await authenticate(request, env, requestId);
        if (!auth.ok) return json({ error: auth.reason, requestId }, auth.status, headers);
        return json({
          actor: {
            id: auth.actor.personId,
            type: auth.actor.personType,
            displayName: auth.actor.displayName
          },
          note: "Identity verified. Module access is checked separately per server-defined route policy."
        }, 200, headers);
      } catch {
        return json({ error: "authorization_service_unavailable", requestId }, 503, headers);
      }
    }

    return json({ error: "not_found", requestId }, 404, headers);
  }
};
