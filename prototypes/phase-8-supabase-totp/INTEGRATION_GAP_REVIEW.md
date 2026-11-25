# Phase 8 — Isolated integration gap review

**Status:** static source review plus isolated Miniflare D1 and Worker contract tests. No runtime session wiring, production database writes, deployment, or real identity activity.

## Scope reviewed

- `worker/src/index.js`
- `worker/src/session-lifecycle.js`
- `worker/src/request-security.js`
- `worker/src/supabase-request-auth.js`
- Existing Phase 8 README and session/request-boundary notes
- Session lifecycle enforcement integration design
- Disposable Miniflare D1 batch atomicity and concurrent-claim tests
- Session lifecycle policy boundary tests
- Current Worker CORS preflight contract tests
- Exact migration `migrations/0005_authorization_schema.sql`
- Disposable D1 last-seen refresh contract tests

## Findings

### 1. Session lifecycle policy is not enforced by the current Worker handler

The current `authenticate()` query checks that a session is not revoked, its absolute expiry is in the future, and its human account/person are active. It does not yet enforce the Phase 8 idle timeout, maximum issued-to-expiry lifetime, future timestamp/order checks, or last-seen refresh throttle from `session-lifecycle.js`.

**Verified schema:** `migrations/0005_authorization_schema.sql` defines `auth_sessions` with `issued_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP`, `expires_at TEXT NOT NULL`, nullable `last_seen_at TEXT`, nullable `revoked_at TEXT`, nullable `revoke_reason TEXT`, and nullable `mfa_verified_at TEXT`. The table also has `CHECK (expires_at > issued_at)`. The migration uses SQLite `CURRENT_TIMESTAMP` defaults (UTC text in the standard SQLite format) and the existing integration fixture also writes `datetime('now', ...)`; the lifecycle refresh tests use canonical UTC ISO-8601 text. Lexical ordering is safe only when values use one normalized UTC representation. The current schema does not itself enforce a single timestamp representation for every writer.

**Test evidence (pure helper only):** `session-lifecycle-boundaries.test.js` covers exact absolute-expiry rejection, the idle-timeout boundary, future `last_seen_at`, the ten-minute MFA freshness boundary, and the five-minute last-seen refresh threshold. These tests exercise the pure policy helper; they do not prove that `authenticate()` or any Worker route invokes it.

**New isolated D1 test evidence:** `d1-session-lifecycle-refresh.test.js` uses a disposable Miniflare D1 database and a test table mirroring the verified `auth_sessions` columns. It verifies the five-minute refresh threshold, NULL `last_seen_at` fallback to `issued_at`, refusal to refresh revoked/expired sessions, monotonic last-seen behavior under competing refreshes, preservation of fixed `issued_at`/`expires_at`, and comparisons across SQLite `CURRENT_TIMESTAMP` and ISO-8601 UTC strings using SQLite `julianday()`. These tests exercise a proposed SQL contract only; they do not update a live D1 database and do not integrate refresh into `authenticate()`.

**Additional fail-closed contract:** `evaluateLastSeenRefreshResult()` accepts only a D1 result reporting exactly one changed row. Zero/multiple changed rows, missing result metadata, and database errors are classified as denials. Unit tests cover these outcomes. The helper is not yet called by the Worker handler.

**Required before session integration:** adopt one explicit UTC representation for all new writes; use timezone-safe timestamp comparisons for legacy SQLite text; map D1 fields into the pure lifecycle evaluator; reject invalid/idle/expired sessions; update `last_seen_at` only when the throttle permits; preserve fixed `expires_at`. Make the read/refresh behavior safe under concurrent requests and deny the request if refresh persistence fails or the conditional update unexpectedly affects no row.

### 2. Supabase bearer verification is not connected to CMD session exchange

`authenticateSupabaseBearer()` verifies an AAL2 bearer and resolves an existing human mapping, but it intentionally does not create a CMD session or cookie. The Worker handler still authenticates only its existing CMD session cookie.

**Required before session integration:** define the first-factor sign-in method and verified identifier; then design a one-time server-side exchange that creates an opaque CMD session, stores only its hash, and never exposes raw session tokens in logs or D1.

### 3. Session creation/rotation and audit atomicity remain unimplemented

The current audit helper performs an individual insert. No session issuance or rotation transaction/batch is implemented in this prototype. The current request handler fails closed with a service-unavailable response when its authentication/authorization path throws, but transaction-level guarantees for future session creation, rotation, revocation, and audit writes have not been implemented.

**Test evidence (isolated only):**
- The existing Miniflare D1 batch tests verify that paired session/audit inserts commit together and that a later constraint failure rolls back the earlier insert.
- A Miniflare D1 concurrency test submits two compare-and-set rotation claims against one active synthetic session and asserts exactly one winner. It deliberately does not create a replacement session or audit event, and is not a complete rotation implementation.
- The new last-seen tests verify conditional refresh behavior only; they do not implement session creation or rotation.
- These are pinned Miniflare/disposable database simulations only. They do not verify remote Cloudflare D1 behavior, production concurrency, or an integrated CMD session-exchange route.

**Still required before session integration:** define atomic D1 operations for session creation/rotation/revocation and corresponding audit events; test audit insert failures, partial failures, replay/race conditions, and rollback/compensation behavior using disposable D1. Verify the chosen atomicity semantics against the target Cloudflare D1 environment before relying on them.

### 4. Browser mutation guard remains a standalone utility

`validateBrowserMutation()` checks configured Origin, optional Fetch Metadata, JSON content type, and a matching double-submit CSRF cookie/header. It is not wired into mutation routes and does not issue CSRF tokens. The current CORS allow-header list in `worker/src/index.js` does not yet include `x-cmd-csrf`, so a future browser client using that header would need a deliberate CORS update and preflight tests.

**Test evidence (current behavior only):** `cors-preflight.test.js` verifies that configured origins receive a 204 preflight response, unconfigured/mismatched origins fail closed, and the current allow-header list contains `content-type` but not `x-cmd-csrf`. This deliberately records the present integration gap; it does not enable the CSRF header or establish that browser mutations are ready.

**Required before browser session integration:** add a dedicated token-issuance design, wire the guard before every cookie-authenticated mutation, deliberately align CORS allow-headers with the CSRF header, and test same-origin and cross-origin browser preflight/mutation cases. No CORS behavior has been broadened in this safe test-only increment.

## Decisions and blockers

- Supabase remains the selected identity provider.
- TOTP remains the selected second factor.
- First-factor sign-in method and verified sign-in identifier remain undecided. No first-factor method is inferred or implemented.
- No real Supabase project, account, credential, identity, or TOTP factor is created.
- No migration is added or applied.
- No Worker route integration, deployment, live D1 change, production configuration, or PR merge is authorized by this review.

## Next safe work

Continue isolated tests and design review only. The first-factor decision is required before a real sign-in/session-exchange prototype can be built. Any staging or production work requires separate CEO approval.


### 5. Request-pipeline test contract added

Added `prototypes/phase-8-supabase-totp/SESSION_PIPELINE_TEST_CONTRACT.md` as a design/test-only artifact. It defines the required ordered stages from route/cookie handling through identity, lifecycle evaluation, conditional refresh, actor construction, authorization, and protected data access.

The contract adds an event-trace matrix for missing/malformed cookies, inactive or virtual identities, malformed/revoked/idle/expired sessions, NULL last-seen fallback, refresh-not-due, refresh success/failure/zero-row/missing metadata, authorization denial, and authorized data access. It requires proof that lifecycle failures never trigger role/permission/scope queries or protected data reads, and that refresh failures remain fail-closed.

The contract also records audit leakage checks, same-request timestamp consistency for MFA, fixed absolute expiry, and the current schema's nullable `last_seen_at` behavior. This is a specification only: no pipeline adapter, Worker integration, D1 mutation, cookie issuance, or protected business route has been implemented. The new scenarios are not yet test evidence and remain acceptance gates for a later isolated code change.

### 6. Isolated pre-authorization session recheck contract

The dependency-injected session-pipeline-contract.js now reloads the session immediately before authorization, verifies that the session ID and person ID have not changed, rechecks that the mapped identity is still an active human, and reevaluates lifecycle and fresh-MFA policy using the request's captured timestamp. This catches a revocation or identity/session replacement that occurs after the initial lookup (including after a last-seen refresh) but before authorization. The test suite includes a concurrent-revocation fixture and a session-identity-replacement fixture; both assert that authorization and protected-data access are not reached.

**Important limitation:** this is an isolated test contract, not production Worker integration. A re-read narrows but does not eliminate the race between the final session check, authorization queries, and protected-data read. Strict immediate revocation semantics require a transaction or equivalent database-enforced guard spanning the relevant authorization/data operation, or an explicitly accepted bounded-revocation model. The consistency/atomicity behavior must be validated against the actual target Cloudflare D1 environment before choosing that model. No live D1, Worker route, or production behavior has changed.
Additional isolated recheck tests now cover a second session lookup failure, identity becoming inactive between reads, identity recheck errors, person-ID replacement, and MFA freshness expiring between the initial read and the pre-authorization recheck. Each asserts that authorization and protected-data access are not reached. These are dependency-injected synthetic contract tests only; they do not establish transactional revocation guarantees or production route behavior.

### 7. Browser mutation-guard adversarial unit coverage

Expanded `request-security.test.js` with synthetic boundary cases for short/oversized CSRF cookie values, absent Fetch Metadata compatibility, multiple non-JSON content types, missing origin policy, and case-insensitive safe HTTP methods. The Worker package syntax-check command now checks every source JavaScript module rather than only the main handler and authorization module. These checks validate the standalone guard only; the guard remains unwired to mutation routes, and CORS still intentionally does not allow the CSRF header until a separately reviewed browser integration change.


### 8. Consolidated browser-boundary test batch

The standalone browser mutation guard now has additional synthetic tests for malformed/short/oversized CSRF values, missing Fetch Metadata compatibility, multiple non-JSON content types, missing origin configuration, and case-insensitive safe methods. The package syntax-check script now checks every JavaScript source module. The CORS contract remains intentionally unchanged: `x-cmd-csrf` is not enabled and no mutation route is wired. CI must run against the consolidated branch head before these additions are marked verified.


### 9. Session exchange atomicity adversarial tests

Expanded the disposable Miniflare D1 atomicity suite with two synthetic cases. First, a rotation batch inserts a replacement session, revokes the old session, and then deliberately fails the audit insert; final-state assertions require the old session to remain active, the replacement to be absent, and no audit row to persist. Second, a unique exchange idempotency key is exercised by replaying the same key; the duplicate batch must roll back its candidate session and audit rows, leaving exactly one session, one audit event, and one exchange record. These are pinned Miniflare in-memory tests only; they do not implement session exchange or prove remote Cloudflare D1 semantics.

### 10. No-login dashboard share security contract

Added `SHARE_LINK_SECURITY_CONTRACT.md` defining the bearer-link threat model, CEO approval binding, token entropy/hash-only storage, seven-day maximum expiry, revocation, read-only dashboard and field allowlists, no-store/referrer controls, rate limiting, audit constraints, and acceptance tests. This is a design contract only: no schema, endpoint, token, dashboard data connection, or public share was created. Each concrete share still requires CEO approval of its exact dashboard, fields/filters, audience, expiry, and any network restrictions.


### 11. Authorization denial and audit-failure coverage

Expanded `authorization.test.js` to cover no active role assignments, virtual actors attempting approve/execute despite a scoped allow, privileged-module fresh-MFA denial, denial-audit persistence failure, and malformed server policy rejection before role/scope queries. These tests exercise `authorizeActor()` with a synthetic D1-style binding; they do not add or connect business API routes.

### 12. CMD integration readiness and UAT handover

Added `CMD_INTEGRATION_READINESS.md` to record the current API surface (`/api/health`, `/api/me`, CORS preflight, and 404 for other paths), mandatory server-owned route policy requirements, and blockers before protected route or no-login share integration. Added `PHASE8_UAT_AND_HANDOVER_CHECKLIST.md` to separate CI-backed synthetic tests from integrated UAT and deployment gates. The checklist explicitly marks end-to-end sign-in, session exchange, runtime lifecycle enforcement, route-level RBAC, share implementation, remote D1 verification, and staging/production as not completed.


### 13. CEO-selected email/password first-factor contract

The CEO selected Supabase Auth Email + Password with a verified email address as the first factor and TOTP as the second factor. This is design-only approval. Added `supabase-email-password-contract.js` to validate a trusted Supabase Auth SDK response: UUID subject, non-empty email, explicit `email_confirmed_at`, and a returned provider session. It returns only a minimal result and does not return access/refresh tokens, verify JWT signatures, issue CMD sessions, or authorize access. Email verification is not inferred from `user_metadata` or a browser-supplied flag.

Added synthetic tests for confirmed/unconfirmed email, provider errors, malformed subject, missing session, token non-disclosure, and the rule that a confirmed email/password response with AAL1 is still denied by the AAL2 claim gate.

### 14. Email/password identity provider mapping and password-reset boundary

The trusted server-side identity mapping allowlist now includes `email_password`; the request cannot select this provider value. Synthetic tests verify exact subject mapping to an existing active human identity and fail-closed behavior for AAL1, invalid claims, unknown provider values, and missing mappings.

Added a TOTP test proving that an AAL1 session still requires a TOTP challenge and successful post-challenge AAL2 confirmation. Password reset itself is not implemented; it must never be treated as TOTP recovery or as an MFA bypass.

**CI evidence:** GitHub Actions run [#130](https://github.com/sparkles-systems-solutions/company-hq-cmd/actions/runs/45575739849) completed successfully for code commit `0cc7567391fbc0de557b14ebf3c9f0c5eff1d013`. The worker-tests job passed syntax check, unit tests, and disposable SQLite migration/safety checks. Subsequent changes to the UAT and gap-review documents are documentation-only.

### 15. Session exchange planner — isolated contract only

The CEO's first-factor decision is recorded as Supabase Email + Password with verified email; TOTP remains the second factor. Added `session-exchange-contract.js` and synthetic tests. The planner requires already-verified JWT signature/issuer/audience/expiry, AAL2, the approved server-selected provider, verified email, an exact active-human UUID mapping, fresh MFA, browser mutation validation, and a short-lived SHA-256 exchange-key hash. It rejects replayed/expired/malformed keys and never accepts request-selected person/role/scope as authority.

The helper returns a non-secret plan only. It does not verify provider tokens, consume an exchange key, access D1, issue a CMD token/cookie, or connect to a Worker route. Existing Miniflare D1 tests verify separate atomic batch/idempotency primitives using disposable data; they do not prove that a future combined exchange is atomic on remote Cloudflare D1.

Cookie contract remains `__Host-cmd_session; Secure; HttpOnly; Path=/; SameSite=Strict; no Domain`; raw tokens must never be stored in browser storage, JSON, logs, or audit metadata. A future implementation must atomically consume the exchange key, insert the session hash, and persist the audit event before setting the cookie. Current CSRF guard is unwired and CORS does not allow `x-cmd-csrf`; this remains a hard browser integration blocker.

