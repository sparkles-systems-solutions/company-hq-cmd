# Phase 8 — Session exchange and atomicity design

**Status:** design-only artifact for the isolated prototype. No session exchange route, token issuance, D1 write, cookie, Supabase project, or live identity is created by this document.

## 1. Security boundary

The future exchange endpoint may accept only a Supabase access token presented over HTTPS. The Worker must verify the JWT signature against the configured trusted JWKS and validate issuer, audience, expiry, authenticated role, UUID subject/session identifiers, and AAL2. It must then resolve the exact provider subject to one pre-provisioned, active human identity.

The endpoint must not:
- accept a user/person/role identifier from the request body as an identity assertion;
- map identities by email fallback;
- create CMD people, auth users, role assignments, or permissions;
- accept anonymous or AAL1 tokens;
- issue a CMD session unless the separately approved session-exchange implementation gates are met; the CEO's design-only first-factor choice (Email + Password with verified email, plus TOTP) is recorded, but it does not authorize endpoint implementation;
- log, return, persist, or otherwise expose the raw CMD session token except in the one Set-Cookie response.

## 2. One-time exchange sequence

1. Enforce HTTPS, exact configured Origin, expected method/content type, request size limits, and browser mutation protections.
2. Verify the Supabase bearer token and AAL2 claim using the existing isolated verifier.
3. Resolve the exact provider subject to an active, pre-provisioned human identity.
4. Apply rate limits to the provider subject, mapped human, source network, and endpoint. Avoid revealing whether a subject or account exists in public error messages.
5. Generate a cryptographically random opaque CMD session token (minimum 256 bits of entropy). Compute its SHA-256 hash immediately.
6. Construct fixed timestamps: issued-at = server time; absolute expiry = issued-at + 12 hours; initial last-seen = issued-at; MFA verified-at = the server-verified step-up time. Do not trust client-supplied timestamps.
7. Insert the session hash and a corresponding audit event as one atomic database unit.
8. Only after the database unit succeeds, return the raw token once in a Secure, HttpOnly, host-only cookie with Path=/ and SameSite=Strict. Use no-store response headers.
9. If any validation or persistence step fails, issue no cookie and do not return token material.

The first-factor method is recorded for design-only use: Email + Password with verified email, plus TOTP. This sequence is not permission to implement the exchange endpoint; that requires separate explicit approval after the integration/security gates are reviewed.

## 3. D1 atomicity contract

Session creation and its audit event are a single logical operation:
- both records commit, or neither record is committed;
- no success cookie is sent unless the complete operation is confirmed;
- audit failure is an authentication failure, not a warning;
- retries must not create duplicate active sessions for one exchange attempt;
- request IDs and a server-generated exchange nonce/idempotency key must be unique and must not contain bearer/session secrets.

Session rotation follows the same contract: create the replacement session, revoke the old session, and write both audit events in one atomic unit. If any statement fails, the operation must not leave a replacement active while the old session remains active, or revoke the old session without a usable replacement. The exact D1 API/batch semantics must be verified against the project's pinned Miniflare version and current Cloudflare D1 behavior before implementation; do not assume a partial sequence is transactional.

If the chosen database API cannot provide the required atomicity, stop and redesign rather than emulate it with unprotected sequential writes.

## 4. Session token and cookie handling

- Generate at least 32 random bytes with a cryptographically secure runtime API.
- Encode with base64url without padding.
- Store only SHA-256(token), never the raw token.
- Compare only hashes derived server-side; do not accept a token hash from the client.
- Cookie: `__Host-cmd_session`; Secure; HttpOnly; Path=/; SameSite=Strict; no Domain attribute.
- Cookie Max-Age must not exceed the remaining fixed absolute lifetime.
- Clear the cookie on logout/revocation using the same cookie attributes and an expired value.
- Do not place tokens in URLs, response JSON, audit metadata, exception text, analytics, or logs.
- Return generic failure messages with a request ID; keep detailed internal reasons in controlled audit metadata without credentials or PII.

## 5. Rotation, revocation, and concurrency

- Reauthentication must rotate to a new random token and hash.
- Rotation must revoke the prior session and create the replacement atomically.
- Concurrent rotation attempts must not both succeed. Use a conditional update or equivalent compare-and-set condition on the old session's active state, and verify affected-row counts.
- Current-session logout revokes only the current session.
- Global logout revokes all active sessions for the mapped human and writes an auditable event.
- Administrative revocation must require a server-defined, separately authorized policy; it is not part of this isolated exchange design.
- Revoked sessions remain unusable even if a stale cookie is replayed.

## 6. Lifecycle enforcement

Every authenticated request must apply the existing pure lifecycle policy before authorization:
- idle timeout: 30 minutes;
- fixed absolute lifetime: 12 hours;
- MFA freshness: 10 minutes for operations requiring fresh MFA;
- last-seen refresh throttle: 5 minutes.

The absolute expiry must never slide. A last-seen update must be conditional on the session still being active and must not overwrite a newer timestamp with an older one. Invalid timestamp order, future timestamps, revoked sessions, idle expiry, and absolute expiry fail closed.

The existing helper is not yet integrated into `worker/src/index.js`; this document does not change that status.

## 7. Failure and test matrix

All tests must use synthetic identities and a disposable local D1/Miniflare database. No real Supabase credentials, user accounts, TOTP factors, or live D1 are permitted.

| Scenario | Expected result |
|---|---|
| Valid verified AAL2 token + active exact identity mapping | Exchange may proceed only after first-factor decision |
| Invalid signature, issuer, audience, expiry, subject, or AAL | Reject; no session and no cookie |
| Anonymous/AAL1 token | Reject; no session and no cookie |
| Missing, inactive, virtual, or ambiguous identity mapping | Reject; no account auto-creation |
| Session insert fails | No audit success and no cookie |
| Audit insert fails | Session insert is rolled back; no cookie |
| Session and audit batch succeeds | One active session hash and matching audit event; cookie emitted only after success |
| Duplicate exchange idempotency key | No duplicate active session |
| Two concurrent rotations of same old session | At most one succeeds |
| Rotation audit failure | No partial rotation state |
| Replay of revoked token | Reject |
| Token present in logs, JSON, audit metadata, or D1 raw columns | Test failure |
| Idle/absolute expiry or invalid timestamp order | Reject before authorization |
| Last-seen refresh race | Timestamp never moves backwards; fixed expiry unchanged |

Tests must inspect final database state after each injected failure. A test that merely observes an exception is insufficient to prove atomicity. Include assertions for both the session row and audit row.

## 8. Implementation gates

Before coding a real exchange:
1. CEO separately approves the session-exchange implementation scope after reviewing the recorded Email + Password / verified-email / TOTP decision.
2. Verify the pinned Miniflare and current D1 atomic batch behavior with a deliberate mid-batch failure in disposable D1.
3. Define and test rate-limit storage and lockout behavior.
4. Define CSRF token issuance and CORS preflight contract for the browser client.
5. Integrate lifecycle checks into the Worker and add request-level tests.
6. Complete security review of failure, retry, concurrency, cookie, and logging behavior.

Separate explicit CEO approval is required for any real Supabase project/configuration, credentials, live D1 migration or write, Worker deployment, real user activation, real TOTP enrollment, or PR merge.

## 9. CEO first-factor decision and current isolated planner

The CEO decision is now recorded: first factor is Supabase Auth Email + Password with a verified email address; TOTP is the required second factor. This supersedes the earlier undecided-first-factor wording in sections 1, 2, and 8. The decision is design-only and does not authorize a live provider project or an exchange endpoint.

Added `worker/src/session-exchange-contract.js` and `worker/tests/session-exchange-contract.test.js`. The helper is a pure planner that accepts only already-verified upstream facts (JWT signature and issuer/audience/expiry checks, AAL2, verified email, exact active-human mapping, fresh MFA, and server-validated browser mutation context). It requires a short-lived server-generated exchange-key hash and rejects consumed, expired, malformed, or overlong keys. It returns only a non-secret plan with fixed 12-hour expiry and atomic-commit requirements.

The planner does **not** verify a JWT, consume the key, query or write D1, create a CMD session token, set a cookie, or connect to a Worker route. The plan's flags are requirements, not proof that an atomic operation has happened.

## 10. Cookie and exchange integration constraints

When a separately approved implementation is eventually designed, use a host-only `__Host-cmd_session` cookie with `Secure; HttpOnly; Path=/; SameSite=Strict` and no `Domain`. Do not store provider or CMD tokens in localStorage/sessionStorage or return them in JSON. The raw opaque CMD token may appear only in the one Set-Cookie response after the atomic database operation is confirmed. All exchange responses must be `Cache-Control: no-store` and use a restrictive Referrer-Policy.

The one-time exchange-key consumption, session-hash insert, and success audit event must be one atomic D1 unit. A unique constraint/conditional consume must ensure exactly one winner under concurrent replay. A retry with the same key must not create a second active session. If any statement including audit fails, no cookie may be returned and the entire logical operation must roll back. Existing Miniflare tests cover analogous batch rollback/idempotency primitives only; the planner itself does not consume a key and no remote D1 guarantee is claimed.

The current browser mutation guard remains unwired, and current CORS preflight permits only `content-type`, not `x-cmd-csrf`. No browser exchange is ready until CSRF token issuance, guard wiring, and exact CORS allow-header behavior are implemented and tested together.

