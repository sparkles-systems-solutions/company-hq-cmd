# CMD Authentication Integration — Technical Implementation Plan

**Status:** Design and sequencing only — NOT implementation authorization  
**Authentication:** Supabase Auth Email + Password (verified email), followed by TOTP; CMD access requires AAL2  
**Authority:** CEO is the sole human approver. AI roles are virtual contributors and cannot approve risk, access, or release.

## 1. Purpose and boundaries

This plan turns the Phase 8 contracts into an ordered implementation path. It does not authorize creation of a Supabase project, credentials or secrets; real user activation or TOTP enrollment; remote D1 provisioning or writes; Worker/staging/production deployment; PR readiness conversion or merge.

Until the relevant gate is separately approved, use synthetic identities, local keys, mocks, and disposable databases only.

## 2. Existing baseline and gaps

Existing isolated components cover JWT signature/claims verification, TOTP step-up, exact provider-subject identity mapping, browser request-security checks, lifecycle policy helpers, a pure session-exchange planner, a dependency-injected pipeline test seam, and disposable D1 atomicity/concurrency tests.

They are not yet wired into a complete runtime login pipeline. There is no implemented one-time exchange-key endpoint, atomic combined exchange transaction, CMD cookie issuance, logout route, or protected business-data route. The current pipeline seam is not runtime enforcement.

## 3. Ordered implementation stages

### Stage 0 — Governance and environment authorization (blocking)

Deliver a completed CEO non-production approval record: named project and owner, region, cost ceiling, expiry/cleanup date, allowed actions, redirect/origin allowlist, approved secret manager, and named custodians.

**Exit:** explicit CEO approval for the named isolated project and exact setup scope, plus accepted custody/cleanup controls.

**No-go:** blank approval record, unclear billing, shared production account, missing expiry, unapproved custodian, or ambiguous scope.

### Stage 1 — Provider adapter wiring (isolated only)

Implement Supabase SDK Email + Password PKCE flow in a non-production-only adapter. Require provider-confirmed email. For AAL1, require TOTP challenge and verification; proceed only at AAL2. Normalize provider errors and never log passwords or tokens.

Verify JWT signature, exact issuer, audience, expiry, algorithm allowlist, key rotation, AAL2, UUID subject/session identifiers, and exact active-human mapping. Never trust user_metadata, browser-provided roles, person IDs, permissions, or scopes. Keep service-role/signing secrets out of browser code and Git.

**Tests:** verified/unverified email; wrong password; rate limit; AAL1; absent/multiple TOTP factors; failed/expired challenge; AAL2 success; provider outage; key rotation; issuer/audience mismatch; tampering; secret redaction.

**Exit:** approved isolated test identity completes provider authentication and TOTP. It still cannot obtain a CMD session until Stage 2 is separately approved and implemented.

### Stage 2 — One-time exchange-key lifecycle

**Proposed API contracts (not implemented routes):**
- POST /api/auth/exchange-key — accepts an authenticated AAL2 provider session plus browser mutation guard; returns a cryptographically random, short-lived, one-time exchange key.
- POST /api/auth/session — accepts the exchange key and required Origin/CSRF context; consumes it once and attempts the atomic CMD session commit.

Both are POST-only, JSON-only, same-origin browser operations, no-store, rate-limited, and return generic external errors.

Generate the key with a cryptographically secure random source. Maximum lifetime: five minutes. Persist only its SHA-256 hash. Bind it to the verified provider subject/session and intended browser context where practical. Never log or persist the raw key. Reject replay, expiry, malformed values, identity mismatch, and duplicate consumption.

**Target atomic D1 sequence:**
1. Revalidate exchange-key hash, expiry, and unconsumed state.
2. Revalidate exact active-human mapping and approved Email + Password identity.
3. Revalidate provider JWT trust and AAL2; enforce MFA freshness.
4. Insert CMD session with fixed issued_at/expires_at, last_seen_at, and mfa_verified_at.
5. Consume the exchange key using compare-and-set conditions (unconsumed and unexpired).
6. Insert the security audit event.
7. Commit all required statements together or none of them.

This is a target contract, not evidence that remote D1 semantics have been verified. Confirm exact Cloudflare D1 batch/transaction behavior, constraint rollback, affected-row metadata, timestamp handling, and concurrent consumption in a separately approved non-production environment before relying on it.

**Failure rule:** no usable CMD session and no cookie if any required condition or atomic commit fails. Retries must not create duplicate sessions. If audit is a required part of the security record, audit failure fails closed.

### Stage 3 — Cookie delivery and browser CSRF/CORS

Only after Stage 2 confirms commit may the Worker issue the opaque CMD session cookie.

**Cookie target:** __Host-cmd_session; Secure; HttpOnly; Path=/; no Domain; SameSite=Lax or stricter if compatible with the approved navigation model. Store only a hash of a high-entropy opaque session token in D1. Do not store provider access/refresh tokens in localStorage.

Issue a separate CSRF value without exposing the session cookie to JavaScript. Require the matching CSRF header for unsafe browser requests; validate exact Origin and Fetch Metadata; require JSON content type; reject cross-site mutations. Allow only exact approved origins and the exact CSRF header in CORS. Never use wildcard credentialed CORS.

**Ordering:** D1 commit → set session cookie and CSRF response material → success response. If commit fails, issue no cookie. If response delivery fails after commit, the session must remain safely revocable/expirable and retry must not create duplicates.

**Tests:** cookie attributes; missing/invalid Origin; cross-site Fetch Metadata; missing/mismatched CSRF; wrong content type; disallowed origin; preflight allow-header; no wildcard credentials; no-store; token leakage.

### Stage 4 — Runtime lifecycle, logout, revocation, rotation

Integrate lifecycle checks into every authenticated request:
- idle timeout: 30 minutes;
- fixed absolute lifetime: 12 hours;
- MFA freshness: 10 minutes for operations requiring fresh MFA;
- last-seen write throttle: 5 minutes;
- last-seen refresh must never extend absolute expiry.

Implement current-session lookup/revocation, logout and cookie clearing, logout-all, compare-and-set rotation, revoke reasons, and security audit events. Fail closed on missing D1 metadata, zero/multiple affected rows, malformed timestamps, revoked sessions, and database errors.

The pipeline test seam is not runtime enforcement. Integrate only after route and D1 semantics review. Re-read session state before protected operations and document the remaining race window. If immediate revocation is required, use a DB-enforced/transactional guard spanning authorization and protected data, or obtain explicit acceptance of a bounded-revocation model.

### Stage 5 — Route RBAC and data scopes

For every route define method, authentication, AAL/MFA freshness, module, action, role/permission, data scope, field projection, and audit behavior. Deny by default.

Resolve authorization inputs server-side. Never trust browser-supplied role, person ID, department, tenant, filters, or field lists. Apply row scope and field projection before returning data. Keep CEO-only approval/execution boundaries explicit.

No-login dashboard sharing remains a separate capability: CEO approval per share, one dashboard, explicit field/filter allowlist, read-only GET, expiry, revocation, audit, and prohibition on sensitive patient, credential, identity-document, or financial data. A share link is not a login or general API token.

### Stage 6 — Remote D1 and operational controls

Only after separate explicit CEO approval for a named non-production database: verify migration replay, schema compatibility, batch atomicity/rollback, concurrent exchange consumption, rotation, affected-row metadata, timestamp comparisons, backup/restore, cleanup, rate limits, monitoring, and secret/log redaction.

Do not apply migrations or write to live D1 under the current authorization.

### Stage 7 — Integrated UAT and independent security review

Test supported browsers and failure paths. Review session fixation, CSRF, replay, account linking, privilege escalation, race conditions, audit integrity, secret handling, data leakage, recovery, and accessibility.

Record exact commit SHA, environment, test identity type, date, test evidence, failures, and limitations. Distinguish local mocks, disposable D1, approved remote non-production, staging, and production. Local CI success does not prove remote D1 or production readiness.

### Stage 8 — Release decisions

Each requires a separate CEO decision: accept integrated non-production UAT/security findings; authorize staging and rollback; authorize PR #2 to leave draft and merge; authorize production configuration/deployment; authorize real-user activation and handover.

No gate implies another. Until the relevant decisions are recorded, keep PR #2 draft/open/unmerged and do not deploy.

## 4. Proposed API contract summary

| Endpoint | Method | Purpose | Required controls |
|---|---|---|---|
| /api/auth/exchange-key | POST | Create one-time exchange key | verified AAL2 provider session, Origin/CSRF, rate limit, no-store |
| /api/auth/session | POST | Consume key and create CMD session atomically | revalidation, single-use CAS, active-human mapping, audit atomicity |
| /api/auth/logout | POST | Revoke current session and clear cookie | authenticated session, CSRF/Origin, audit |
| /api/auth/logout-all | POST | Revoke all sessions for active human | fresh MFA, CSRF/Origin, audit |
| /api/me | GET | Minimal current identity/session context | cookie verification, lifecycle, server-side identity |

These are proposed contracts, not currently implemented routes.

## 5. Acceptance matrix

| Area | Minimum evidence |
|---|---|
| Provider trust | signature, issuer, audience, expiry, algorithm and key-rotation tests |
| First factor | verified Email + Password contract; no password/token logging |
| TOTP | AAL1 denied; verified TOTP factor; AAL2 required |
| Identity | exact UUID subject mapped to one active human; no email fallback/auto-provision |
| Exchange | random key, hash-only persistence, five-minute maximum, single-use CAS, replay denied |
| Atomicity | session + exchange consumption + audit all commit or all roll back |
| Cookie | __Host- constraints, Secure, HttpOnly, Path=/, no Domain |
| CSRF/CORS | exact Origin, Fetch Metadata, CSRF header, JSON-only mutations, narrow CORS |
| Lifecycle | 30-minute idle, fixed 12-hour absolute, 10-minute MFA freshness, 5-minute refresh throttle |
| Revocation | logout, logout-all, rotation, concurrent race and audit-failure tests |
| Authorization | deny-by-default route policy, row scope, field projection, CEO-only actions |
| Audit | no raw credentials/tokens; failure semantics tested |
| Operations | approved secrets, backup/restore, monitoring, rate limits, rollback, cleanup |
| Governance | separate CEO approvals for project, remote D1, staging, merge, production, real users |

## 6. No-go conditions

Do not issue a CMD session if provider trust/AAL2 is unverified; email is unverified; identity mapping is missing, ambiguous, inactive, or non-human; TOTP is absent, unverified, or stale; exchange key is malformed, expired, replayed, consumed, or bound to another identity; atomic session/exchange/audit commit cannot be proven; Origin/CSRF/CORS fails; lifecycle/revocation state is unavailable; required audit fails; or environment/secrets/database fall outside approved scope.

## 7. Responsibility model

- **CEO (sole human):** approves scope, risk acceptance, project creation, credentials/custody, remote D1, staging, merge, production, and real-user activation.
- **Virtual security architect/reviewer:** drafts threat models and reviews controls; cannot approve risk.
- **Virtual backend engineer:** implements only approved scope; cannot provision unapproved resources.
- **Virtual QA engineer:** prepares synthetic tests and reports evidence; cannot alone certify production readiness.
- **Virtual release manager:** prepares release/rollback evidence; cannot merge or deploy without CEO approval.

AI roles are virtual work assignments, not human employees or independent approvers.

## 8. Evidence and change control

Retain exact commit SHA, changed files, test commands/results, CI run association, environment classification, synthetic/real identity designation, unresolved risks, and approval record for every gated action. Never describe documentation or local contract tests as live integration. Never claim a CI run tested later documentation-only commits.

## 9. Current authorization

**Authorized:** documentation, architecture review, synthetic/local tests, and isolated code changes that do not create external resources, use real identities/secrets, write remote D1, deploy, or merge.

**Not authorized:** non-production Supabase project creation; secret generation or custody activation; live provider sign-in; real TOTP enrollment; remote D1 provisioning/writes; Worker deployment; staging/production; real-user activation; PR readiness conversion; PR merge.

The next blocking decision is completion and explicit CEO approval of a named non-production Supabase project and secret-custody record. Until then, work remains at the design/local-test boundary.

## Canonical protocol decision dependency

Before implementation, review [AUTHENTICATION_PROTOCOL_DECISIONS.md](./AUTHENTICATION_PROTOCOL_DECISIONS.md). It contains the recommended direct bearer-token exchange, cookie SameSite policy, CSRF/CORS contract, audit atomicity requirement, and explicit CEO decision fields. These recommendations supersede neither the existing implementation nor the CEO approval gates until explicitly accepted. In particular, the current two-step exchange-key planner remains only a test contract and is not evidence of an implemented route.
