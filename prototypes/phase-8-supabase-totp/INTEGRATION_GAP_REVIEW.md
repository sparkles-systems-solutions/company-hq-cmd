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

**New isolated D1 test evidence:** `d1-session-lifecycle-refresh.test.js` uses a disposable Miniflare D1 database and a test table mirroring the verified `auth_sessions` columns. It verifies the five-minute refresh threshold, refusal to refresh revoked/expired sessions, monotonic last-seen behavior under competing refreshes, and preservation of fixed `issued_at`/`expires_at`. It does not update a live D1 database and does not integrate refresh into `authenticate()`.

**Required before session integration:** normalize all session timestamps to one explicit UTC representation at write time; map D1 fields into the pure lifecycle evaluator; reject invalid/idle/expired sessions; update `last_seen_at` only when the throttle permits; preserve fixed `expires_at`. Make the read/refresh behavior safe under concurrent requests and fail closed if refresh persistence fails or the conditional update unexpectedly affects no row.

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
