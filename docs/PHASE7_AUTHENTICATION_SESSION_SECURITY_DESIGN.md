# Phase 7 — Authentication & Session Security Design

**Status:** Design only. No authentication code, provider integration, database migration, credential, secret, DNS setting, deployment or live account change is included in this phase.

**Repository context reviewed:** `migrations/0005_authorization_schema.sql`, `worker/src/index.js`, `worker/src/authorization.js`, `docs/ROLES_AND_PERMISSIONS.md`, and the current repository README.

## 1. Objective and scope

Design a secure sign-in and session lifecycle for the CMD's only human member: the Founder / CEO. Virtual AI role records must never become login identities.

Phase 7 covers:
- Human identity proofing and sign-in.
- Strong second-factor authentication.
- Short-lived, revocable server-side sessions.
- Secure browser cookie handling.
- Session rotation, logout, expiry and revocation.
- Login abuse prevention and recovery.
- Authentication audit events and security monitoring.
- Worker route protections and security test requirements.

This phase does not implement business CRUD, virtual-role activation, share links, approval execution, or production deployment.

## 2. Current verified baseline and gaps

### Existing schema in migration 0005

- `auth_users`: maps a person to an `email_otp`, `oidc` or `webauthn` provider subject; account states include pending/active/locked/suspended/disabled; MFA is required by default.
- `auth_sessions`: stores a unique session-token hash, issue/expiry timestamps, revocation fields, MFA verification timestamp, IP hash and user-agent summary.
- Database trigger: an auth identity can only be created for an active human person.
- Database trigger: a session can only be created for an active auth account.
- The current authorization Worker validates a session cookie against the stored hash and checks active account/person status.

### Missing implementation

- No login, OTP challenge, password, OIDC callback, WebAuthn registration, TOTP enrollment, recovery-code, session-issuance, session-rotation or logout endpoints.
- No schema tables for OTP challenges, MFA factors, TOTP secrets, WebAuthn credentials, or recovery codes.
- No trusted authentication provider has been selected or configured.
- No account bootstrap or recovery procedure has been approved.
- Current `/api/me` is a read-only identity check; it is not a complete authentication system.

**Important:** The presence of an `auth_provider` enum value or session table does not mean the related authentication method has been implemented.

## 3. Recommended CEO authentication policy

### Primary identity

Use one verified CEO identity and one approved email address. The actual address must be supplied and verified by the CEO during a controlled setup; never store a guessed or placeholder address as a live identity.

Select a managed identity provider that supports secure OIDC Authorization Code flow with PKCE, verified email, MFA/passkeys and account recovery. The provider must be chosen after review of pricing, data residency, account ownership, availability, recovery and security controls. No provider is selected in this design.

Do not implement a home-grown password store or email delivery service as the first option.

### Second factor

Preferred order:
1. **Passkey / WebAuthn** on a CEO-controlled device, where supported.
2. **TOTP authenticator app** as an independently enrolled second factor.
3. Recovery codes stored offline by the CEO.

Email OTP may be used as an account verification or controlled fallback step, but should not be treated as a strong independent second factor when it relies on the same mailbox used for primary identity.

Do not permit email-only login for the CEO account once MFA enrollment is required.

### Enrollment rule

- First-time bootstrap must be a one-time, controlled setup.
- Verify ownership of the chosen identity before linking it to the CEO's human person record.
- Enroll at least one strong MFA factor and generate recovery codes.
- Display recovery codes once only; store only salted/hashed verifiers.
- Require a fresh authentication step before adding/removing factors or changing recovery settings.
- Notify the CEO through a separate trusted channel when factors or account recovery settings change.
- No self-service registration for public visitors.

## 4. Sign-in sequence

1. Browser opens the CMD sign-in page over HTTPS.
2. Worker creates a short-lived, single-use authentication state/nonce and binds it to the browser using a secure, short-lived cookie.
3. Browser is redirected to the approved identity provider using OIDC Authorization Code + PKCE.
4. Provider authenticates the CEO and returns to the exact allowlisted callback URL.
5. Worker validates state, nonce, issuer, audience, signature, expiry and PKCE verifier; validates verified email and provider subject.
6. Worker maps the provider subject to the one active human `auth_users` record and active CEO person. Never accept person ID, role ID or permission claims from browser input.
7. Worker requires the enrolled second factor or provider-verified phishing-resistant MFA according to the configured assurance policy.
8. On success, Worker generates a cryptographically random opaque session token, stores only its SHA-256 hash in `auth_sessions`, and sets the raw token in a secure cookie.
9. Worker records successful authentication and returns only minimal identity information.
10. Every protected API request revalidates session, account, person and current authorization state server-side.

A callback failure must not create a session. Unknown provider subjects, unverified email, missing MFA, invalid state/nonce, expired codes, disabled users and database errors must fail closed.

## 5. Session and cookie policy

Recommended initial policy for CEO browser sessions (final values must be confirmed in implementation review):

| Control | Initial design |
|---|---|
| Session token | 32+ bytes from a cryptographically secure random generator |
| Database storage | SHA-256 token hash only; never store raw token |
| Cookie name | `__Host-cmd_session` |
| Cookie flags | Secure; HttpOnly; SameSite=Strict; Path=/; no Domain |
| Idle timeout | 30 minutes |
| Absolute lifetime | 12 hours |
| MFA freshness | 10 minutes for privileged/sensitive operations |
| Rotation | On authentication, re-authentication, MFA step-up and privilege change |
| Logout | Revoke current server-side session and clear cookie |
| Global logout | Revoke all active sessions for the CEO account |
| Concurrent sessions | Permit only a small CEO-controlled number; show/revoke active sessions |

Session expiry must be enforced by the Worker and D1, not only by frontend timers. Store timestamps consistently in UTC. Avoid updating session activity on every static asset request; update it only on authenticated API activity with bounded write frequency.

If the CEO changes password/provider security settings, loses a device, or reports compromise, revoke all sessions and require fresh authentication.

## 6. CSRF, CORS and browser protections

Because the session is cookie-based:
- Require CSRF protection for every state-changing request. Use a synchronizer token or a carefully implemented double-submit token bound to the session, plus strict Origin/Referer validation.
- Reject missing or untrusted Origin on browser write requests.
- Keep CORS allowlist exact; never reflect arbitrary origins.
- Never use wildcard origins with credentialed requests.
- Require JSON content type and strict request size/schema validation.
- GET/HEAD must not mutate state.
- Keep all auth responses `Cache-Control: no-store`.
- Use HTTPS only and HSTS at the deployed edge.
- Keep frontend free of secrets and never put session tokens in localStorage, sessionStorage, URLs, or logs.

SameSite is defense-in-depth, not a replacement for CSRF validation.

## 7. Rate limiting and abuse protection

Apply limits at the edge and in the authentication workflow:
- Per-IP and per-identity limits for login initiation, OTP sends, callback failures, MFA attempts and recovery.
- Progressive delay and temporary challenge lockout after repeated failures.
- Generic user-facing errors that do not disclose whether an email/account exists.
- OTP expiry, single-use consumption, resend cooldown and maximum attempts.
- Never log OTP values, recovery codes, raw session tokens, OIDC authorization codes, TOTP seeds or full identity tokens.
- Alert the CEO about unusual login patterns and factor changes.
- Avoid permanent lockout from attacker-triggered failures; recovery must require strong identity verification.

Exact numeric limits must be tuned after a threat-model review and testing. Do not rely solely on IP-based limits.

## 8. Account recovery and emergency response

Recovery is a high-risk process because the CEO is the only human member.

- Recovery codes are generated during enrollment and stored offline by the CEO.
- Recovery code use is single-use and audited.
- Lost authenticator/passkey recovery requires independent identity verification through the selected provider and a documented CEO-controlled recovery procedure.
- Recovery must not be performed solely through an email link to the same mailbox if that mailbox is the only identity factor.
- Factor reset requires fresh strong verification, notification, and revocation of existing sessions.
- A suspected compromise triggers global session revocation, provider account review, API secret rotation if implicated, audit preservation and incident notes.
- No support operator or virtual AI role can bypass recovery checks or reset the CEO's MFA.

Emergency break-glass access is **not** to be created as a hidden static password or permanent bypass. If a break-glass mechanism is later justified, it requires a separate design, offline custody, strict expiry, alerting and CEO approval.

## 9. Audit event requirements

Record at minimum:
- Authentication initiated / succeeded / failed.
- OIDC state, nonce, issuer, audience or callback validation failure (without recording secrets).
- MFA challenge and verification success/failure.
- Factor enrolled, removed or reset.
- Recovery code generated or used.
- Session created, rotated, expired, revoked and global logout.
- Account locked, suspended or re-enabled.
- Rate-limit or suspicious-login events.

Each event should include a unique event/request ID, UTC timestamp, actor (when known), event category, outcome, safe reason code and minimal metadata. Do not store raw IP addresses unless a reviewed retention/privacy design requires them; use a keyed hash or minimized network metadata. Audit write failure must fail closed for session creation, factor changes and other security-critical state transitions.

## 10. Schema changes required before implementation

Migration 0005 is a foundation, not a complete authentication schema. Prepare a separate additive migration (proposed `0006_authentication_factors_and_challenges.sql`) only after the provider and factor design are approved. Candidate tables:

- `auth_challenges`: challenge ID, auth user, purpose, provider, challenge hash/state hash, created/expiry/consumed timestamps, attempt count and safe status. Store no plaintext OTP or raw authorization code.
- `auth_mfa_factors`: factor ID, auth user, factor type (TOTP/WebAuthn), label, status, created/verified/last-used/revoked timestamps.
- `auth_recovery_codes`: per-code salted/hashed verifier, status, created/used timestamps; never store plaintext codes.
- `auth_webauthn_credentials`: credential ID, public key, sign counter, transports, relying-party ID and metadata; private keys remain with the authenticator.
- `auth_security_events` or a carefully extended append-only audit schema for auth-specific event details.

For TOTP, encrypt the secret at rest using a managed secret/key service; never store the seed in plaintext in D1. A keyed HMAC or approved password-hashing construction should protect short numeric challenge verifiers against offline guessing. Challenge consumption must be atomic and single-use.

Before writing migration 0006, inspect actual D1 SQLite compatibility and define retention/deletion requirements. Do not add a password column unless a password-based provider is explicitly selected and independently reviewed.

## 11. Worker endpoints proposed (not implemented)

| Endpoint | Purpose | Method |
|---|---|---|
| `/api/auth/start` | Start OIDC flow and create state/nonce/PKCE context | POST |
| `/api/auth/callback` | Validate provider callback and create session after MFA policy | GET |
| `/api/auth/mfa/challenge` | Begin step-up or enrollment challenge | POST |
| `/api/auth/mfa/verify` | Verify enrolled factor and refresh MFA timestamp | POST |
| `/api/auth/logout` | Revoke current session and clear cookie | POST |
| `/api/auth/logout-all` | Revoke all account sessions after fresh re-authentication | POST |
| `/api/auth/sessions` | List limited current session metadata | GET |
| `/api/auth/sessions/revoke` | Revoke a selected session after fresh re-authentication | POST |
| `/api/auth/recovery` | Controlled recovery workflow | POST |

All routes must use server-owned policy and strict request validation. The list is a design proposal, not a claim that these routes exist.

## 12. Security acceptance checklist

- [ ] One active human CEO identity only; virtual identities cannot authenticate.
- [ ] OIDC Authorization Code + PKCE, state and nonce validation.
- [ ] Exact issuer, audience, signature, expiry and verified-email checks.
- [ ] Strong MFA required; email-only login blocked.
- [ ] Passkey/WebAuthn and/or TOTP enrollment verified; recovery codes single-use.
- [ ] OTP/challenge expiry, resend cooldown, atomic single-use and attempt limits.
- [ ] Raw tokens, OTPs, recovery codes and TOTP secrets never appear in logs or plaintext D1.
- [ ] Session hash lookup, idle/absolute expiry, rotation, revocation and global logout tested.
- [ ] Cookie flags and HTTPS behavior verified in browser.
- [ ] CSRF, Origin, CORS and content-type protections tested.
- [ ] Rate limits tested across identity and network dimensions.
- [ ] Account recovery and lost-device incident tabletop completed.
- [ ] Audit success/failure paths tested; audit failure blocks critical state changes.
- [ ] No login, session, factor or recovery endpoints exposed before security review.
- [ ] Dedicated disposable remote Cloudflare D1 compatibility tests pass.
- [ ] Independent security review and explicit CEO approval before staging.

## 13. Phase 7 completion definition

Phase 7 design is complete when the CEO approves the identity provider, primary identity, MFA method, recovery procedure and initial session policy. Implementation should then proceed in a disposable development environment, with a separately reviewed migration and automated security tests.

**No authentication code, credential, provider configuration, migration, deployment or production change is authorized by this design document.**
