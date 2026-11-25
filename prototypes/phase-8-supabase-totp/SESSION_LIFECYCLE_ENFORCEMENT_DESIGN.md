# Phase 8 — Session lifecycle enforcement integration design

**Status:** design-only. This document does not modify Worker authentication, execute D1 statements, issue cookies, create sessions, or enable any production behavior. It is an implementation contract for a later, separately reviewed change.

## 1. Current implementation boundary

The current `worker/src/session-lifecycle.js` exports pure helpers:
- `evaluateSessionLifecycle(session, now)`
- `calculateSessionExpiry(issuedAt)`
- `shouldRefreshLastSeen(lastSeenAt, now)`
- `isMfaFresh(verifiedAt, now)`

The current `authenticate()` function in `worker/src/index.js` does not call these helpers. Its SQL currently selects session ID, auth user ID, expiry, and MFA timestamp; it filters revoked and absolutely expired rows in SQL, and checks that the linked user and person are active humans. It does not load or enforce `issued_at` or `last_seen_at`.

The session lifecycle policy remains:
- Idle timeout: 30 minutes
- Fixed absolute lifetime: 12 hours from issue time
- Fresh MFA window: 10 minutes for routes that require it
- Last-seen refresh throttle: 5 minutes

## 2. Required field mapping

The existing migration history is described as containing these `auth_sessions` columns: `issued_at`, `expires_at`, `last_seen_at`, `revoked_at`, `revoke_reason`, and `mfa_verified_at`. Before implementation, fetch and inspect the exact migration file and confirm its actual table/column names, types, defaults, and indexes on the target branch. Do not infer schema from this design note.

| Lifecycle helper property | Expected D1 column | Required handling |
|---|---|---|
| `issuedAt` | `issued_at` | Required; server-generated at session creation |
| `expiresAt` | `expires_at` | Required; fixed at issue time + 12 hours |
| `lastSeenAt` | `last_seen_at` | Required; initialize to issue time |
| `revokedAt` | `revoked_at` | Null means not revoked; non-null rejects |
| MFA verified timestamp | `mfa_verified_at` | Server-verified step-up timestamp only |

The query must alias these columns into the helper's camel-case input object. Missing or malformed required timestamps must fail closed. No client-provided timestamps are accepted.

## 3. Required request pipeline

For every future cookie-authenticated protected route, the order must be:

1. Validate request shape and route method.
2. Parse the opaque session cookie and hash the token server-side.
3. Load the session joined to its mapped auth user/person, including all lifecycle timestamps and active/human status.
4. Reject missing, revoked, inactive, virtual, or otherwise unmapped identities.
5. Call `evaluateSessionLifecycle()` with the row timestamps and a single server-captured `now` value.
6. If invalid, deny before role lookup, permission evaluation, or business-data access. Record a minimal denial audit event without token material.
7. If valid, conditionally refresh `last_seen_at` only when the throttle permits.
8. Build the authenticated actor using the verified person/session and MFA timestamp.
9. Apply the server-defined route permission policy; enforce `isMfaFresh()` for operations requiring fresh MFA.
10. Only then access protected business data.

A lifecycle denial must never fall through to authorization. A D1 error during the session read or required refresh must fail closed (service unavailable), not be treated as an anonymous or valid session.

## 4. Last-seen refresh and concurrency contract

A refresh is activity metadata only. It must never extend `expires_at` or change `issued_at`.

- Capture one UTC server timestamp per request and pass the corresponding epoch milliseconds to the helper.
- If `shouldRefreshLastSeen(lastSeenAt, now)` is false, do not write.
- If true, perform one conditional update that only affects the same session while it remains unrevoked and unexpired.
- The database update must be monotonic: a slower request must not overwrite a newer `last_seen_at` with an earlier value.
- Use a consistent, sortable UTC representation and verify SQLite comparison behavior against the actual stored column format. Do not compare mixed timestamp formats lexicographically.
- The update must not touch `expires_at`, `issued_at`, `mfa_verified_at`, or revoke fields.
- If the conditional update affects no row, re-read/re-evaluate once or deny safely; never assume the session is still active.
- Concurrent requests that both pass the initial read must not cause last-seen time to move backwards.
- Keep the 5-minute throttle to avoid a D1 write on every request.

**Design candidate only:** use a conditional SQL update with active/revoked/absolute-expiry predicates and a monotonic timestamp expression based on SQLite date functions (for example, comparing `julianday(last_seen_at)` and `julianday(?)`). Final SQL must be tested against the actual D1 column type and timestamp representation before adoption. Do not copy this concept into production without that verification.

## 5. MFA freshness

The session row's `mfa_verified_at` is server-owned. For a permission request requiring fresh MFA:
- call `isMfaFresh()` using the same captured `now`;
- reject missing, malformed, too-old, or materially future timestamps;
- do not treat a general authenticated session as proof of recent step-up;
- do not accept an MFA timestamp supplied in request JSON or headers.

The current `index.js` contains a separate `isFreshMfa()` implementation. Before integration, consolidate the duplicate policy into the tested helper to avoid policy drift, and add tests proving the authorization path uses the same timestamp captured during authentication.

## 6. Audit behavior

Audit events must be minimal and must not contain raw cookie values, bearer tokens, token hashes, TOTP codes, secrets, or unnecessary personal data.

Suggested event keys:
- `auth.session_lifecycle_denied` with a bounded reason such as `idle_timeout`, `absolute_expiry`, `invalid_timestamps`, or `revoked`;
- `auth.session_last_seen_refreshed` only if the system's audit policy requires refresh events (prefer metrics over high-volume audit rows);
- existing authorization allow/deny events remain separate.

If a required denial audit write fails, the protected request still remains denied. Do not turn an audit failure into an allow. Define retention and volume controls before adding high-frequency refresh events.

## 7. Required tests before integration

All tests must use synthetic rows and disposable Miniflare D1; no live D1 or real identity data.

### Helper and mapping tests
- Valid row maps to valid lifecycle input.
- Null/malformed `issued_at`, `expires_at`, or `last_seen_at` denies.
- Revoked session denies before role/permission queries.
- Idle and absolute expiry deny before role/permission queries.
- Future issue/last-seen timestamps and invalid timestamp order deny.
- Fixed expiry remains byte-for-byte unchanged after refresh.
- MFA missing/stale/future timestamps deny only for routes that require fresh MFA.

### D1 refresh tests
- A request within the 5-minute window performs no update.
- A request at/after the threshold attempts a conditional update.
- Revoked or expired session cannot be refreshed.
- Two concurrent refreshes cannot move `last_seen_at` backwards.
- A delayed older refresh cannot overwrite a newer timestamp.
- D1 update error fails closed.
- A zero-row conditional update triggers safe revalidation/denial.
- The update never changes `issued_at` or `expires_at`.

### Pipeline-order tests
Use a spy/fake D1 adapter to assert that lifecycle denial occurs before role assignments, permission rules, scope grants, and protected data reads. Confirm there is no authorization query after lifecycle failure.

### Audit tests
- Denial reason is recorded without credential material.
- Audit write failure never results in access being allowed.
- No raw session token, token hash, or MFA secret appears in audit rows or response bodies.

## 8. Implementation gates

Before any Worker integration:
1. Inspect the exact migration on the target branch and confirm actual column names/types/indexes.
2. Confirm the timestamp representation and SQLite comparison semantics using disposable D1.
3. Implement the pure row-to-lifecycle mapping and request-pipeline integration in a separate isolated code change.
4. Add D1 refresh concurrency and pipeline-order tests described above.
5. Run full CI and inspect every test result.
6. Update the integration gap review with tested facts and remaining limitations.

The existing approval boundary remains unchanged: no production deployment, live D1 writes/migrations, real Supabase project or credentials, real user activation, real TOTP enrollment, or PR merge without separate explicit CEO approval. The first-factor choice is now recorded as Email + Password with verified email; TOTP is the second factor. A real sign-in/session-exchange flow remains blocked pending separate approval for the non-production provider environment and the integration scope.
