# CMD Authorization Model & API Enforcement Design

**Company:** Sparkles Systems & Solutions  
**System:** Company HQ — Central Management Dashboard  
**Phase:** 3 — Authorization Model & API Enforcement Design  
**Version:** 1.0  
**Date:** 2026-11-24  
**Status:** Design specification only — not deployed

## 1. Objective and scope

Translate the approved role permission and data access matrix into an enforceable server-side authorization model for the future Cloudflare Worker API and Cloudflare D1 database.

This document is a design artifact. It does not create credentials, grant access, activate virtual roles, deploy a Worker, or apply a D1 migration.

Company membership policy:
- The Founder / CEO is the only human member.
- All other 41 positions are virtual AI roles.
- Virtual AI roles are not separate autonomous agents and do not have independent legal, financial, or operational authority.
- Virtual actors can never receive approval or execution permissions in this design.

## 2. Security architecture

### 2.1 Trust boundaries

1. GitHub Pages frontend: untrusted public client; no secrets and no trusted authorization decisions.
2. Cloudflare Worker API: enforcement point for authentication, authorization, validation, rate limits, and audit events.
3. Cloudflare D1: source of truth for users, active assignments, permissions, scopes, approvals, share grants, and audit records.
4. Cloudflare secrets: signing keys and integration secrets; never committed to GitHub or shipped to browser code.
5. External systems: no access unless a separate integration is approved, scoped, and tested.

### 2.2 Mandatory principles

- Deny by default.
- Authenticate every protected request.
- Authorize every request at action, module, resource, field, and environment level.
- Read current role assignments and revocation state server-side; do not trust role names or permissions supplied by the browser.
- No permission is inferred from UI visibility, URL secrecy, CORS, or a client-side claim.
- Virtual roles are prohibited from approve and execute, regardless of seeded permission rows.
- CEO-only actions require a verified human CEO identity, active session, MFA/step-up confirmation, explicit intent, and audit evidence.
- An approval record is not an execution command. A separate controlled executor must re-check approval and safeguards.
- Use parameterized SQL, strict input validation, response minimization, and security event logging.
- Fail closed when authorization data is missing, malformed, stale, or unavailable.

## 3. Canonical permission model

### 3.1 Actions

| Action key | Meaning | Virtual role |
|---|---|---|
| read | View authorized records | Allowed when scoped |
| draft | Create a non-authoritative draft | Allowed when scoped |
| propose | Submit a proposed change/request | Allowed when scoped |
| test | Run permitted tests in isolated test environment | Allowed when scoped |
| approve | Record a formal decision | Denied |
| execute | Perform an external, financial, production, destructive, or irreversible operation | Denied |

### 3.2 Modules

Use stable keys from the approved matrix:
EXEC, HR, PMO, QA, FIN, OPS, SEC, DOC, REL, SHARE.

The server must maintain a single canonical registry. Unknown module/action keys are denied.

### 3.3 Decision contract

Every authorization decision should produce:
- allowed: boolean
- reason_code: stable internal code, e.g. ALLOW_SCOPED_ROLE_PERMISSION, DENY_NO_SESSION, DENY_ROLE_INACTIVE, DENY_PERMISSION_MISSING, DENY_SCOPE_MISMATCH, DENY_VIRTUAL_PRIVILEGED_ACTION, DENY_APPROVAL_REQUIRED
- actor_id
- role_id where applicable
- module
- action
- resource_type and resource_id where applicable
- environment
- policy_version

Do not return detailed internal policy reasons to untrusted clients. Log them internally with request correlation ID.

## 4. Proposed D1 data model

The following tables are proposed for a future migration after implementation review. Names are logical design names; no SQL migration is included in this phase.

### 4.1 auth_users

Purpose: human login identities only.

Suggested fields:
- id primary key
- person_id unique foreign key to people
- login_identifier unique, normalized
- password_hash (only if password login is selected)
- status (pending, active, locked, disabled)
- mfa_required boolean
- created_at, updated_at, last_login_at

Constraints:
- Only a human person record may map to a login identity in the current single-human company model.
- Virtual role records must not receive passwords or login identities.
- Never store plaintext passwords, OTP codes, TOTP seeds in readable form, or recovery codes in logs.
- Prefer a managed identity provider if selected after threat review; this schema is not a commitment to build password authentication.

### 4.2 auth_sessions

Purpose: server-side session lifecycle.

Suggested fields:
- id primary key
- user_id foreign key
- session_token_hash unique
- created_at, expires_at, last_seen_at
- revoked_at, revocation_reason
- mfa_verified_at
- created_ip_hash and bounded user-agent metadata where justified

Controls:
- Generate opaque high-entropy session tokens; store only a cryptographic hash.
- Cookie flags: HttpOnly, Secure, SameSite=Lax or stricter where compatible, bounded lifetime.
- Rotate session after login and MFA completion.
- Revoke on logout, password reset, account lock, suspected compromise, or privilege change.
- Apply idle and absolute expiry.
- Never accept session IDs from localStorage or query parameters.

### 4.3 permissions

Purpose: canonical action catalogue.

Suggested fields:
- id primary key
- module_key
- action_key
- description
- unique (module_key, action_key)

### 4.4 role_permissions

Purpose: role-to-permission assignments.

Suggested fields:
- id primary key
- role_id foreign key to roles
- permission_id foreign key to permissions
- effect (allow, deny)
- environment (development, staging, production, any)
- created_at
- unique (role_id, permission_id, environment)

Controls:
- No virtual role may have an allow row for approve or execute.
- Explicit deny overrides allow.
- Absence of an allow row means deny.
- CEO approval authority should be derived from verified human CEO identity and a separate policy guard, not from a virtual role permission row.

### 4.5 role_scope_grants

Purpose: restrict allowed actions to specific resources.

Suggested fields:
- id primary key
- role_assignment_id foreign key
- module_key
- scope_type (company, department, project, resource)
- scope_id nullable only for company scope
- valid_from, expires_at, revoked_at
- granted_by_person_id foreign key to people
- created_at

Controls:
- Prefer project/resource scopes over company-wide grants.
- Require a CEO-authored grant for any confidential scope.
- Check scope on every list, detail, search, export, and mutation request.
- Do not let client input widen scope.
- Ensure SQL query itself is constrained by authorized scope; do not fetch all rows and filter only in frontend.

### 4.6 approval_records

The existing approvals table is the starting point. Extend or replace it only through a reviewed migration. Required semantics:
- requester, human approver, subject type/id, exact action, environment, requested scope, rationale
- status (pending, approved, rejected, expired, withdrawn, consumed)
- requested and decision timestamps
- approval expiry
- immutable approval snapshot/hash
- execution reference and consumed timestamp, if an approved action is executed

Controls:
- Approver must be the active human CEO.
- Virtual actors cannot approve.
- Approval binds to one exact action, resource, environment, and payload hash; changed payload requires a new approval.
- Prevent replay and double execution.
- Reject expired, revoked, consumed, or mismatched approvals.
- Approval does not itself run the action.

### 4.7 dashboard_share_tokens

Purpose: secure no-login, read-only dashboard access.

Suggested fields:
- id primary key
- token_hash unique
- dashboard_id
- allowed_fields_json
- filter_scope_json
- created_by_person_id (human CEO)
- created_at, expires_at, revoked_at
- optional allowed_ip_ranges_json only if network restrictions are feasible
- last_used_at, use_count

Controls:
- Generate high-entropy token server-side; store hash only; reveal raw token once.
- Read-only; no create/update/delete/approve/execute/export by default.
- One dashboard and explicit field/filter scope only.
- Short expiry; initial recommendation: no more than 7 days.
- Immediate revocation and rotation.
- Rate limit, audit every use/failure/revocation, no raw token in logs.
- Use Cache-Control: no-store, Referrer-Policy: no-referrer, no third-party analytics, and X-Robots-Tag: noindex, nofollow.
- Add VPN/internal IP restrictions where feasible, but never treat IP restriction as the only security control.
- Never expose patient data, sensitive personal data, bank/financial account details, credentials, or restricted security records.
- If field-level filtering and token revocation cannot be enforced, disable the feature.

### 4.8 audit_logs

The existing audit_logs table is a starting point. Add or ensure:
- actor type and ID
- action, module, resource type/ID
- decision and reason code
- request/correlation ID
- environment
- timestamp
- safe metadata (no credentials, session tokens, raw share tokens, OTPs, or sensitive payloads)

Audit sensitive reads, all denied privileged actions, role/permission changes, approvals, token lifecycle events, and mutations. Restrict audit-log read access to CEO and specifically approved security review workflows. Do not expose update/delete endpoints for audit records.

## 5. API authorization pipeline

Every protected Worker route must run the following pipeline in order:

1. Parse request and assign a server-generated correlation ID.
2. Apply request size, method, content-type, and rate limits.
3. Authenticate session or a specific dashboard-share token route.
4. Check session/token expiry, revocation, and account status.
5. Load active person and current role assignments from D1.
6. Reject inactive, pending, suspended, expired, or unassigned virtual members.
7. Resolve canonical module/action from server route configuration, never from a trusted client role claim.
8. Check role permission and environment.
9. Check resource ownership and record-level scope in the database query.
10. Apply field-level redaction before serialization.
11. For privileged actions, verify active human CEO identity, recent MFA, explicit approval, payload binding, and one-time consumption.
12. Perform only the permitted operation.
13. Write audit event with safe metadata.
14. Return minimal response and security headers.

Any uncertainty or dependency failure returns a deny result. Authorization service failure must not fall back to permissive behavior.

## 6. Worker middleware — illustrative pseudocode

This is a design sketch, not production-ready code or a deployed Worker.

~~~ts
async function authorize(request, route, env) {
  const requestId = crypto.randomUUID();

  const actor = await authenticateRequest(request, env);
  if (!actor) return deny("DENY_NO_SESSION", requestId);

  if (actor.kind === "share_token") {
    if (route.module !== "SHARE" || route.action !== "read") {
      return deny("DENY_SHARE_READ_ONLY", requestId);
    }
    return authorizeShareScope(actor, route, env, requestId);
  }

  const current = await loadCurrentAssignments(actor.personId, env.DB);
  if (!current.active) return deny("DENY_ROLE_INACTIVE", requestId);

  const moduleKey = route.module;
  const actionKey = route.action;

  if (actor.personType === "virtual" &&
      (actionKey === "approve" || actionKey === "execute")) {
    return deny("DENY_VIRTUAL_PRIVILEGED_ACTION", requestId);
  }

  const grant = await findRolePermissionAndScope(
    current.assignments, moduleKey, actionKey, route.resource, env.DB
  );
  if (!grant.allowed) return deny(grant.reason, requestId);

  if (actionKey === "approve" || actionKey === "execute") {
    if (!isActiveHumanCEO(actor) || !await hasRecentMfa(actor, env.DB)) {
      return deny("DENY_CEO_STEP_UP_REQUIRED", requestId);
    }
    if (!await verifyExactApproval(request, route, actor, env.DB)) {
      return deny("DENY_APPROVAL_REQUIRED", requestId);
    }
  }

  await writeAuditDecision(actor, route, "allow", requestId, env.DB);
  return { allowed: true, actor, requestId };
}
~~~

Implementation requirements:
- All functions above require explicit schema, error handling, unit tests, and review.
- Do not trust actor, role, scope, approved, or environment values sent by the browser.
- Route configuration must map each HTTP method/path to a fixed module/action/resource resolver.
- List endpoints must constrain SQL with the authorized scope before returning rows.
- Avoid generic endpoints that accept arbitrary table names or SQL fragments.

## 7. CEO approval and execution protocol

For sensitive action:
1. Virtual role or CEO prepares a proposal.
2. Worker stores a pending approval request with exact action, target, environment, scope, payload hash, rationale, and expiry.
3. CEO opens the request in authenticated session and completes MFA/step-up verification.
4. CEO approves or rejects the exact snapshot.
5. If approved, a separate execution endpoint re-authenticates CEO, re-checks the approval, verifies payload hash and expiry, then requires explicit confirmation.
6. The executor consumes the approval once and writes audit events.
7. Any payload/resource/environment change invalidates the approval.
8. Production or destructive operations still require backup/rollback and human operational safeguards.

No virtual role may trigger the executor, even if it prepared the request.

## 8. No-login dashboard share flow

1. CEO chooses one dashboard, filters, and allowed fields.
2. Worker validates the dashboard is eligible for sharing and contains no restricted data.
3. CEO confirms scope, expiry, and optional network restrictions.
4. Worker generates token, stores only hash and metadata, and displays the raw link once.
5. Share endpoint validates token hash, expiry, revocation, and rate limits on every request.
6. Worker returns only the pre-approved dashboard projection.
7. Every use and failure is audited without raw token.
8. CEO can revoke immediately; revocation takes effect on the next request.

Do not put share tokens into analytics, referrer headers, browser storage, public issue comments, or source code.

## 9. Automated security test plan

Before any live access, implement and pass at least these tests:

| Test ID | Scenario | Expected result |
|---|---|---|
| AUTH-001 | No session calls protected API | 401 / deny |
| AUTH-002 | Expired session | 401 / deny |
| AUTH-003 | Revoked session | 401 / deny |
| AUTH-004 | Pending virtual member attempts read | 403 / deny |
| AUTH-005 | Active virtual role reads an assigned project | Allow only scoped fields |
| AUTH-006 | Virtual role reads unrelated project | 403 / empty scoped result |
| AUTH-007 | Virtual role attempts approve | 403 / deny and audit |
| AUTH-008 | Virtual role attempts execute | 403 / deny and audit |
| AUTH-009 | Browser forges role_id or scope | Ignore forged values; authorize from D1 |
| AUTH-010 | Role permission absent | 403 / deny |
| AUTH-011 | Explicit deny conflicts with allow | Deny |
| AUTH-012 | Expired/revoked role assignment | 403 / deny |
| AUTH-013 | CEO approval without recent MFA | Deny |
| AUTH-014 | Approval payload differs from request | Deny |
| AUTH-015 | Approval replay / second execution | Deny |
| AUTH-016 | Expired or revoked share token | 401 / deny |
| AUTH-017 | Share token requests write/export | 403 / deny |
| AUTH-018 | Share token requests field outside allowlist | Field omitted / deny |
| AUTH-019 | Share token accesses unrelated dashboard | 403 / deny |
| AUTH-020 | Share token brute-force attempts | Rate limited and audited |
| AUTH-021 | Audit metadata contains secret/token | Test must fail; secret redacted |
| AUTH-022 | D1 unavailable during authorization | Fail closed |
| AUTH-023 | SQL injection payload in filter/resource | Rejected; parameterized query |
| AUTH-024 | CORS/preflight or hidden UI bypass attempt | No authorization bypass |
| AUTH-025 | User role is disabled during active session | Next request denied after current-state check |

Testing must include positive and negative cases, scope boundary tests, race/replay tests, and audit verification. A passing test suite is necessary but not sufficient for production readiness.

## 10. Operational security and deployment gates

Before staging:
- Review schema and migrations.
- Implement Worker middleware and route map.
- Configure separate development/staging environments.
- Store signing keys only as Cloudflare secrets.
- Configure logging that excludes credentials and sensitive payloads.
- Add rate limits and abuse monitoring.
- Implement backups and verify restoration.
- Run automated tests and security review.

Before production:
- CEO explicitly approves production deployment.
- MFA and account recovery are tested.
- Permission review and role activation are recorded.
- External human security/legal/accounting review is completed where required.
- D1 migration is rehearsed against a staging copy.
- Rollback plan and recovery point are verified.
- Monitoring and incident response are ready.
- No-login share remains disabled until all share controls are implemented and tested.

## 11. Current implementation status

| Item | Status |
|---|---|
| Permission matrix | Documented |
| Authorization architecture | Documented in this file |
| Proposed D1 permission schema | Designed, not migrated |
| Worker middleware | Not implemented |
| Auth/session implementation | Not implemented |
| Approval enforcement | Not implemented |
| Dashboard share-token endpoint | Not implemented |
| Automated security tests | Test plan documented; tests not executed |
| Live access grants | None verified |
| Production deployment | Not performed |

All virtual role records must remain pending. Do not mark onboarding permission review or operational activation complete based solely on this design document.

## 12. Next phase

**Phase 4 — Authorization Schema & Migration Draft**

Prepare a new additive D1 migration for the permission catalogue, role permissions, scoped grants, session/share token metadata, and approval enhancements. Review it for compatibility with migrations 0001–0004, then test against a disposable local/staging D1 database before any live database application.
