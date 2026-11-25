# CMD Phase 8 — Pre-integration Technical Readiness Review

**Review type:** Static source and design consistency review  
**Status:** Findings recorded; no runtime changes made  
**Branch:** prototype/phase-8-supabase-totp  
**Scope:** Current Worker entry point, isolated auth/session helpers, request-security contract, and session-exchange/pipeline design documents  
**Authorization boundary:** Synthetic/local design work only. No provider project, secrets, real identity, remote D1, deployment, or merge.

## 1. Executive result

**Decision: NOT READY for authentication integration.**

The repository contains useful isolated verification helpers and extensive test contracts, but the live Worker request path is still an authorization foundation rather than a Supabase-to-CMD authentication pipeline. The new Batch 10 plan is a sequencing document, not implementation evidence.

The most important blockers are:
1. The Worker entry point does not wire the Supabase JWT verifier, TOTP adapter, browser mutation guard, session lifecycle helper, or session-pipeline contract.
2. The current cookie-authentication query does not load or enforce the full lifecycle fields (issued-at and last-seen/idle timeout).
3. No session-exchange, cookie-issuance, logout, or protected business-data routes exist.
4. CSRF is not integrated; current CORS preflight allows only content-type.
5. The existing exchange design document and Batch 10 plan describe different exchange protocols and need one canonical contract before implementation.
6. D1 batch tests are disposable Miniflare evidence only; remote D1 semantics remain unverified and separately gated.

## 2. Source-grounded findings

### F-01 — Supabase trust chain is not wired into Worker request handling
**Severity:** Critical blocker

The current `worker/src/index.js` imports authorization helpers only. Its request handler does not import or invoke the Supabase JWT verifier, TOTP adapter, request-auth adapter, or identity-mapping adapter. The Supabase components remain isolated modules and tests.

**Required before integration:** a reviewed route-level trust chain that verifies signature/issuer/audience/expiry/AAL2, confirms verified Email + Password identity, maps the exact provider subject to an existing active human, and fails closed before any CMD session is considered.

### F-02 — Runtime session lifecycle is not enforced
**Severity:** Critical blocker

The current `authenticate()` query in `worker/src/index.js` checks session hash, non-revoked state, absolute `expires_at`, active auth account, and active human person. It does not select `issued_at` or `last_seen_at`, and it does not call `evaluateSessionLifecycle()`. Therefore the documented 30-minute idle timeout and full timestamp-order/lifetime checks are not enforced by this handler.

**Required before integration:** map all lifecycle columns from D1; apply one captured server-side timestamp; handle NULL last-seen using issued-at; reject malformed/future/inconsistent timestamps; implement conditional monotonic refresh and exact changed-row handling; keep absolute expiry fixed.

### F-03 — Existing authorization is not exposed through protected business routes
**Severity:** Critical blocker

The Worker currently exposes health and identity endpoints; other paths return 404. `authorizeActor()` exists as an exported helper, but there are no protected business-data handlers demonstrating route-defined policy, scope enforcement, field projection, or authorization-before-data ordering.

**Required before integration:** route inventory and server-owned policy definitions; deny-by-default behavior; tests proving no protected-data read occurs before an allow decision; no request-body authority over role/module/action/scope.

### F-04 — CSRF guard is not wired and CORS is incomplete for the proposed CSRF header
**Severity:** Critical blocker

The standalone request-security helper is not imported by the current Worker handler. The current `corsHeaders()` allow-header list contains only `content-type`; it does not allow the proposed `x-cmd-csrf` header. Thus the current browser mutation path is not ready for the proposed CSRF contract.

**Required before integration:** define CSRF issuance/validation as one coherent browser protocol; wire exact Origin, Fetch Metadata, content-type, and CSRF checks to every unsafe route; update CORS only for exact approved origins and the exact chosen header; test preflight and credential behavior together.

### F-05 — Session exchange protocol needs canonicalization
**Severity:** High design blocker

The older `SESSION_EXCHANGE_ATOMICITY_DESIGN.md` describes a direct exchange from a verified Supabase bearer token to a CMD session, with session + audit as one atomic unit. The Batch 10 plan introduces a two-step one-time exchange-key protocol (`/api/auth/exchange-key`, then `/api/auth/session`) where session creation, exchange-key consumption, and audit must commit atomically.

These are not the same API contract. Both are designs, not implemented routes.

**Required before implementation:** choose and document one canonical protocol, including the threat it addresses, key binding, lifetime, replay/idempotency behavior, endpoint sequence, and exact atomic database unit. Update older documents so they cannot be read as an alternative implementation instruction.

### F-06 — Cookie SameSite policy is inconsistent across documents
**Severity:** Medium design blocker

The existing exchange atomicity document specifies `SameSite=Strict`; the Batch 10 plan allows `Lax` or stricter depending on navigation compatibility. Cookie attributes must not be left to implementation discretion.

**Required before implementation:** select one policy based on the actual CMD navigation and callback architecture, document the reason, and use it consistently in plan, API contract, UAT, and tests. Retain `__Host-`, Secure, HttpOnly, Path=/, and no Domain.

### F-07 — Atomic D1 evidence is local/disposable only
**Severity:** Critical external-verification blocker

The existing Miniflare tests provide useful disposable database tests for batch rollback, rotation claims, and idempotency primitives. They do not establish current remote Cloudflare D1 transaction semantics, affected-row behavior, or production concurrency guarantees.

**Required before relying on it:** only after separate CEO approval for a named non-production database, verify the exact combined transaction sequence, injected failure rollback, concurrent exchange consumption, audit failure rollback, and final database state. Do not perform this against live/production D1 under current authorization.

### F-08 — Audit writes and authentication transaction boundaries are separate today
**Severity:** High integration blocker

The current Worker audit helper performs its own D1 `INSERT ... .run()`. That helper is not an atomic session-creation transaction and must not be reused as if it makes session + exchange consumption + audit atomic.

**Required before integration:** design a transaction/batch API that includes all required writes in one confirmed atomic unit; define behavior when audit persistence fails; avoid raw credentials, token values, or sensitive data in audit metadata.

### F-09 — Existing /api/me is not proof of a complete login
**Severity:** High clarity/security boundary

The current `/api/me` endpoint expects an already-issued CMD session cookie and checks its database mapping. It does not perform Supabase sign-in, TOTP, session exchange, or cookie issuance. Its current response must not be described as end-to-end authentication.

**Required before integration:** preserve this distinction in UI/API documentation and tests until the full login pipeline exists.

## 3. Design reconciliation required

Before any runtime integration, update the design set so there is exactly one approved answer for:
- one-step bearer-token exchange versus two-step one-time exchange key;
- exchange-key generation, hash-only storage, identity/browser binding, expiry, consumption, replay and idempotency;
- atomic D1 write set and post-commit cookie issuance;
- SameSite policy;
- CSRF token issuance, cookie/header relationship, and CORS allowlist;
- audit-failure semantics and exact request lifecycle.

No choice is made by this review. These decisions should be recorded in the canonical contract and reviewed before implementation authorization.

## 4. Recommended order after approvals

1. Resolve F-05/F-06 and publish one canonical session-exchange and cookie contract.
2. Complete Stage 0 governance: named non-production project, owner, region, cost ceiling, expiry, secret manager, custodians, redirect/origin allowlist, and explicit permitted actions.
3. After separate approval, wire provider SDK/verified-email/TOTP flow using approved non-production synthetic test identities.
4. Implement and test the chosen one-time exchange and atomic session/exchange/audit operation.
5. Wire cookie, CSRF, Origin, Fetch Metadata, and exact CORS policy together.
6. Integrate runtime lifecycle, logout, revocation, and rotation.
7. Implement protected route policy, data scopes, and field projection.
8. Perform approved remote non-production D1 verification, integrated UAT, independent security review, and separately approved release gates.

## 5. Acceptance evidence required

- Worker handler imports and invokes each required component on the actual route path.
- Request-level tests demonstrate trust-gate and lifecycle ordering, not just isolated helper behavior.
- Negative tests prove no cookie/session/data access after any failed gate.
- Atomicity tests inspect final session, exchange-key, and audit rows after every injected failure and replay/concurrency case.
- Browser tests prove CSRF/CORS behavior end to end.
- Route tests prove deny-by-default, exact scope, and field projection.
- CI run is tied to the exact code commit tested; later documentation commits are not represented as code-tested.
- Remote D1 and deployment claims are made only with evidence from their explicitly approved environments.

## 6. Current authorization and disposition

**Permitted now:** documentation, source review, synthetic/local tests, and low-risk isolated code work that does not create external resources, use real credentials/identities, write remote D1, deploy, or merge.

**Not authorized:** Supabase project creation, secret generation/custody activation, live provider sign-in, real TOTP enrollment, remote D1 provisioning/writes, Worker deployment, staging/production, real-user activation, PR readiness conversion, or PR merge.

**Disposition:** keep PR #2 draft/open/unmerged. Do not begin runtime authentication integration until the design reconciliation is complete and the relevant CEO approvals are separately recorded.
