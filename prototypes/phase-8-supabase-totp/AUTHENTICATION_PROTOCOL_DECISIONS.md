# CMD Authentication Protocol Decisions — Canonical Reconciliation Record

**Status: RECOMMENDATION RECORDED — CEO DECISIONS PENDING**  
**Scope:** isolated design only. This document does not authorize implementation, project creation, credentials, remote D1, deployment, real-user activation, or PR merge.

## 1. Decisions already made (do not reopen)

- Identity provider: Supabase Auth.
- First factor: Email + Password.
- Sign-in identifier: provider-confirmed email address.
- Second factor: TOTP.
- CMD access requires provider-verified AAL2.
- Exact provider subject UUID maps to one pre-provisioned active human CMD identity. No email fallback, auto-provisioning, browser-supplied role, or virtual actor.
- No production deployment, real-user activation, live D1 changes, or PR merge is authorized.

## 2. Canonical session-exchange recommendation

**Recommend one direct, single-request bearer-token exchange** rather than the two-step exchange-key proposal.

### Proposed sequence (not implemented)

1. Browser completes Supabase PKCE Email + Password sign-in and TOTP step-up; it proceeds only with an AAL2 access token.
2. Browser sends one same-origin HTTPS POST /api/auth/session with the Supabase access token in the Authorization: Bearer header and JSON content type. Do not place tokens in URL, body, browser storage, or logs.
3. Worker enforces exact configured Origin, rejects cross-site Fetch Metadata, checks approved content type and request size, applies rate limits, and verifies JWT signature/JWKS, issuer, audience, expiry, algorithm, AAL2, verified email and UUID claims.
4. Worker maps the exact sub to one active, pre-provisioned human; rechecks required identity and MFA freshness using server-trusted facts.
5. Worker generates a cryptographically random opaque CMD session token (at least 256 bits), stores only its SHA-256 hash, and atomically writes the session plus required success audit event.
6. Only after confirmed commit, Worker returns the raw CMD token once in Set-Cookie; response is Cache-Control: no-store. No token appears in JSON, logs, audit metadata, URLs, or analytics.
7. Any failed gate or atomic write means no success cookie and no usable session.

### Rationale and trade-off

The direct exchange matches the current isolated bearer verifier and request-auth adapter, avoids introducing a second persisted one-time secret, expiry/consumption state, replay race, extra endpoint, and extra atomicity dependency. A browser-supplied bearer token is explicitly attached rather than ambiently attached by the browser, so the exchange endpoint's primary browser boundary is exact Origin + Fetch Metadata + strict CORS + bearer/JWT verification + rate limiting; it does not need to create a separate exchange-key cookie solely to defend against classic cookie-CSRF.

The two-step exchange-key design offers an explicit one-time browser-bound handoff, but adds state and another consume/replay lifecycle. It is not recommended unless a documented threat analysis demonstrates a concrete requirement that the direct bearer exchange cannot satisfy.

**Important:** the direct exchange remains a recommendation, not an approved implementation decision. Existing pure planner currently expects an exchange-key hash; it must not be treated as proof that the direct protocol is implemented. Any future code change must reconcile or replace that planner and its tests only after the protocol decision is approved.

## 3. Cookie and CSRF policy recommendation

### CMD session cookie

Recommend:
- Name: __Host-cmd_session
- Secure; HttpOnly; Path=/; SameSite=Lax
- No Domain attribute.
- Opaque random token only; store SHA-256 hash server-side.
- Max-Age never exceeds remaining fixed 12-hour absolute lifetime.
- Clear with matching attributes on logout/revocation.

**Why Lax:** the PKCE callback completes before CMD session issuance, but normal users may enter the app through an external top-level link/deep link. Lax is the pragmatic compatibility default while still withholding the cookie on cross-site subresource and unsafe cross-site POST contexts. Exact Origin, Fetch Metadata and CSRF checks remain mandatory for unsafe cookie-authenticated requests. Strict is a valid harder policy if the client navigation model is tested and the CEO accepts first-navigation/deep-link friction.

### Unsafe cookie-authenticated requests

Recommend retaining the existing double-submit contract:
- Cookie: __Host-cmd_csrf, Secure, Path=/, SameSite=Lax, no Domain, not HttpOnly (the browser client must read it).
- Header: X-CMD-CSRF (case-insensitive on HTTP).
- Generate at least 32 cryptographically random bytes; use a high-entropy URL-safe representation.
- Require exact cookie/header equality using constant-time comparison; reject missing, malformed, too-short, or oversized values.
- Require exact configured Origin, reject cross-site Fetch Metadata when present, require JSON for mutation routes, and use exact allowlisted credentialed CORS origins only.
- Never accept wildcard credentialed CORS. Preflight must explicitly allow content-type, x-cmd-csrf only for approved origins.
- Safe methods do not mutate state; all state-changing methods must pass the mutation guard before data access or writes.

The CSRF cookie is intentionally readable by same-origin JavaScript; the session cookie remains HttpOnly. XSS can defeat browser CSRF protections, so CSP, output encoding, dependency hygiene and no third-party scripts remain required.

### Bearer exchange exception

The proposed direct POST /api/auth/session is bearer-authenticated before CMD cookie issuance. It must enforce exact Origin, Fetch Metadata, JSON, CORS and rate limits, but should not require a CSRF double-submit cookie that has not yet been issued. This exception applies only to that bearer-token exchange endpoint, not to subsequent cookie-authenticated mutation routes.

## 4. Audit and D1 atomicity contract

For direct session exchange, the required logical write set is:
1. Insert the new session hash and fixed lifecycle timestamps.
2. Insert the corresponding success audit event.

Both commit or neither commits. Do not return a cookie until success is confirmed. Audit failure is authentication failure. Any retry/idempotency mechanism must prevent duplicate active sessions without persisting raw provider/CMD tokens. Rotation must atomically create replacement session, revoke prior session, and write required audit events. If the selected D1 API cannot guarantee the contract, stop and redesign.

Current evidence is limited to disposable Miniflare/SQLite tests of separate batch rollback, idempotency and compare-and-set primitives. It does not prove the combined future exchange transaction or remote Cloudflare D1 semantics. A separately approved non-production environment is required to verify the actual API, affected-row metadata, concurrency and timestamp behavior before relying on it.

## 5. Runtime enforcement remains a separate implementation gate

The current Worker entry point does not wire Supabase verification, TOTP, identity mapping, request-security guard, lifecycle helper, or pipeline seam. Current authentication does not enforce the full idle lifecycle. Protected business routes, exchange, logout, logout-all, cookie issuance and runtime CSRF enforcement are absent. The current CORS allow-header is only content-type.

Do not interpret this document as evidence those controls exist. Before implementation, reconcile the planner/tests to the approved exchange protocol, wire lifecycle checks in the request path, integrate CSRF issuance/validation, update CORS and test preflight, and enforce route-specific RBAC/data scopes.

## 6. CEO decisions required

The following recommendations require explicit CEO acceptance before implementation:

| Decision | Recommendation | CEO decision |
|---|---|---|
| Exchange protocol | One direct bearer-token POST /api/auth/session; no exchange-key endpoint | PENDING |
| Session cookie SameSite | Lax | PENDING |
| CSRF cookie SameSite | Lax; readable by same-origin JS | PENDING |
| Unsafe-request CSRF | Double-submit __Host-cmd_csrf + X-CMD-CSRF, exact Origin and Fetch Metadata | PENDING |
| Bearer exchange CSRF treatment | No double-submit token on this endpoint; strict Origin/Fetch Metadata/CORS and bearer verification | PENDING |
| Audit atomicity | Session + success audit in one atomic D1 unit; fail closed | PENDING |

CEO approval record:
- Decision: APPROVED / REJECTED / RETURN FOR CHANGES
- Approved protocol:
- Approved cookie and CSRF policy:
- Conditions / restrictions:
- CEO authorization through approved company process:
- Decision date:

A generic “go ahead” for isolated design work is not approval of these security decisions or implementation scope.

## 7. Unchanged approval boundaries

This reconciliation does not authorize:
- Creating or configuring a Supabase project or account.
- Generating, requesting, storing or transmitting real credentials/secrets.
- Real-user activation, real TOTP enrollment or live email delivery.
- Remote/live D1 provisioning, migrations, or writes.
- Worker deployment (including staging).
- Session-exchange implementation, cookie issuance, or runtime auth integration.
- PR readiness conversion or merge.
- Production deployment.

Each remains subject to its own explicit approval gate. Until the decisions above are recorded and the relevant scope is separately approved, status remains **NOT READY for runtime authentication integration**.
