# Phase 8 — Session lifecycle request-pipeline test contract

**Status:** design and test contract only. No Worker route integration, D1 write, cookie/session issuance, Supabase project, identity activation, or production behavior is introduced by this document.

## 1. Purpose and verified baseline

This contract defines observable ordering and fail-closed behavior for a future cookie-authenticated protected request. It is intended to be implemented first as isolated tests with synthetic identities and disposable Miniflare D1, before any protected route is wired.

The current source review verified:

- `worker/src/index.js` currently authenticates a CMD cookie by hashing it and selecting a session joined to `auth_users` and `people`.
- The current query filters `revoked_at IS NULL`, `expires_at > CURRENT_TIMESTAMP`, active auth account, and active person, and the handler rejects non-human identities.
- The query does not select `issued_at` or `last_seen_at`; it does not call `evaluateSessionLifecycle()`.
- `worker/src/session-lifecycle.js` provides pure lifecycle and MFA freshness helpers.
- `migrations/0005_authorization_schema.sql` defines `issued_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP`, `expires_at TEXT NOT NULL`, nullable `last_seen_at TEXT`, nullable `revoked_at TEXT`, and nullable `mfa_verified_at TEXT`. It includes `CHECK (expires_at > issued_at)` and an index on `(auth_user_id, expires_at, revoked_at)`.
- The schema permits NULL `last_seen_at`; the lifecycle helper's intended fallback is `issued_at`. A future row mapper must implement that fallback explicitly.
- The current Worker exposes only health and identity endpoints. No protected business-data route is implemented.

These facts describe the current prototype, not a completed security integration.

## 2. Required observable pipeline

A future protected request must produce the following ordered stages:

1. **Route gate:** match a known route and allowed method. Unknown routes must not reach authentication-dependent business handlers.
2. **Cookie parsing:** read only the named opaque session cookie; never accept a session token from query parameters or request JSON.
3. **Token lookup:** hash the opaque token server-side and query the session plus mapped identity.
4. **Identity gate:** require an existing, active human person and active auth account. Missing, virtual, suspended, disabled, or unmapped identities stop here.
5. **Lifecycle mapping:** map database fields to `issuedAt`, `expiresAt`, `lastSeenAt` (NULL falls back to `issuedAt`), and `revokedAt`. No browser-supplied timestamps may be used.
6. **Lifecycle evaluation:** capture one server-side `now` value and call `evaluateSessionLifecycle()`. Reject malformed/future/inconsistent timestamps, revocation, idle timeout, absolute expiry, and excessive lifetime.
7. **Refresh gate:** only a valid session may reach the conditional last-seen refresh decision. A refresh write is permitted only when the five-minute throttle says it is due.
8. **Refresh result gate:** when a refresh is attempted, accept only a D1 result reporting exactly one changed row. D1 error, missing result metadata, zero rows, or unexpected multiple rows must not proceed to authorization. If a safe re-read/re-evaluation is selected instead of immediate denial, it must be explicitly implemented and tested; it must never assume the original session remains valid.
9. **Actor construction:** construct the actor exclusively from verified database rows. Carry the same captured `now` value through MFA freshness evaluation.
10. **Authorization:** call role, permission, and scope checks only after all prior gates succeed. Route policy must be server-defined; request-body role/module/action/scope values are never authoritative.
11. **Protected data:** access protected business data only after authorization succeeds.

No lifecycle failure may fall through to role assignments, permission rules, scope grants, or protected data reads.

## 3. Pipeline event-trace test matrix

Implement a fake/spy D1 adapter or equivalent test seam that records stage calls. Tests must assert both the response decision and the exact absence/presence/order of downstream operations.

| Scenario | Expected last reached stage | Required downstream absence |
|---|---|---|
| Missing or malformed cookie | Cookie parsing | No session lookup, role lookup, or data read |
| No matching session | Token lookup | No lifecycle/role/data access |
| Inactive account/person or virtual person | Identity gate | No role lookup or data read |
| NULL `last_seen_at`, valid issue time | Lifecycle evaluation with fallback | Normal pipeline may continue |
| Malformed lifecycle timestamp | Lifecycle evaluation | No refresh, role lookup, or data read |
| Revoked session | Lifecycle evaluation / identity rejection | No role lookup or data read |
| Idle timeout | Lifecycle evaluation | No refresh, role lookup, or data read |
| Absolute expiry | Lifecycle evaluation | No refresh, role lookup, or data read |
| Excessive lifetime | Lifecycle evaluation | No refresh, role lookup, or data read |
| Future issue/last-seen timestamp | Lifecycle evaluation | No refresh, role lookup, or data read |
| Valid session, refresh not due | Refresh gate | No D1 refresh write; authorization may proceed |
| Valid session, refresh due, one row changed | Refresh result gate | Authorization may proceed |
| Refresh D1 error | Refresh result gate | No role lookup or data read |
| Refresh returns zero rows | Refresh result gate or tested revalidation | No authorization unless a fresh re-read proves validity |
| Refresh result metadata missing | Refresh result gate | No role lookup or data read |
| Role/permission denied | Authorization | No protected data read |
| Authorization allowed | Authorization | Protected data read may occur after this point only |

## 4. Audit and response assertions

- Lifecycle denials use bounded reason codes; do not include raw cookies, bearer tokens, token hashes, TOTP values, MFA secrets, or full database rows.
- A denial audit failure must not turn a denial into an allow. The request remains denied; the system may return a service-unavailable response if audit persistence is a mandatory control.
- Responses must not disclose whether a particular user account exists. Keep externally visible authentication failures generic where practical; retain bounded internal reason codes in controlled audit metadata.
- Do not write high-volume `last_seen_at` refresh events to the audit table by default. Prefer metrics or sampled operational telemetry if required.
- Tests must inspect both audit rows and response bodies for credential-material leakage.

## 5. Timestamp and refresh constraints

- Use one captured server timestamp for lifecycle and MFA decisions within a request.
- `issued_at` and `expires_at` are immutable during activity refresh. Absolute expiry remains fixed at issue time plus the configured 12-hour maximum.
- A NULL `last_seen_at` uses `issued_at` for evaluation; do not silently treat it as current activity.
- The current schema stores timestamps as TEXT and permits different SQLite timestamp text formats. Do not use lexical string ordering across mixed formats.
- Existing isolated tests exercise a candidate `julianday()` SQL contract in Miniflare. They do not establish remote Cloudflare D1 behavior or production concurrency guarantees.
- Any final refresh SQL must be tested for monotonicity, active/unexpired predicates, exact changed-row semantics, and preservation of fixed timestamps.

## 6. MFA and authorization constraints

- MFA freshness is ten minutes and must use the same captured `now` as the lifecycle decision.
- A general authenticated session is not proof of a fresh TOTP step-up.
- Only server-owned `mfa_verified_at` can satisfy freshness. Client-supplied values are ignored.
- Fresh MFA is enforced only where the server-defined route policy requires it; the authorization helper's existing sensitive-module and privileged-action policy must not be weakened.
- Virtual AI roles must never approve or execute, regardless of any browser-supplied claims.

## 7. Test execution and acceptance gates

Before integration is proposed:

1. Add synthetic unit tests for database-row-to-helper mapping, including NULL last-seen fallback and malformed values.
2. Add pipeline-order tests for every denial row in the matrix.
3. Add refresh error/zero-row/missing-metadata tests and prove no authorization query follows.
4. Add audit failure and credential-leakage assertions.
5. Add an authorization-to-data ordering test proving protected data access occurs only after an allow decision.
6. Run the complete Worker test suite and CI; inspect the actual run result and commit SHA.
7. Update the integration gap review with exactly what is tested and what remains unverified.

## 8. Explicitly out of scope

This contract does not authorize or implement:

- Selecting or inferring the first-factor sign-in method.
- Supabase login, callback, or session-exchange routes.
- Session or CSRF token issuance, cookie setting, or TOTP enrollment.
- Live D1 migrations or writes, production Supabase configuration, credentials, or real user activation.
- Worker deployment, PR merge, or production security-setting changes.

The first-factor sign-in method and verified sign-in identifier remain a CEO decision. The previously approved boundary remains: isolated synthetic prototype work only.
