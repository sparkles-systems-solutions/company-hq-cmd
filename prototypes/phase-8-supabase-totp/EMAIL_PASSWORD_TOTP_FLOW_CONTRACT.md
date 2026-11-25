# Email + Password + TOTP — Isolated Flow Contract

**Decision source:** CEO_EMAIL_PASSWORD_TOTP_DECISION.md
**Scope:** local/synthetic prototype design and tests only.
**Not implemented:** live Supabase sign-in, real user, TOTP enrollment, CMD session issuance, Worker route wiring, remote D1, deployment.

## Trust boundaries

- Supabase Auth alone verifies email/password credentials and owns password storage.
- The browser may call the Supabase Auth SDK email/password sign-in flow; CMD must not proxy, persist, or log the password.
- A trusted Supabase Auth SDK user response must confirm email_confirmed_at. Do not trust browser-supplied verification flags or user_metadata.
- The access token is not trusted until the Worker verifies its signature, trusted issuer, audience, expiry, and key through the configured JWKS verifier.
- A verified email/password result is not sufficient for CMD access. The token must also establish AAL2.
- Identity mapping uses the immutable provider subject UUID and a server-configured email_password provider key; it must resolve to an existing active human CMD identity.
- CMD role, permission, scope, session, and audit decisions remain independent from Supabase Auth.

## Ordered acceptance pipeline

1. Receive email/password through Supabase Auth email/password sign-in. Do not log request body or credentials.
2. Reject provider errors with a generic response; do not reveal whether an email exists.
3. Validate trusted Auth response shape, UUID subject, non-empty email, email_confirmed_at timestamp, and returned provider session. The local contract helper returns no tokens.
4. Treat this result as first-factor completion only. It is not a CMD session and does not authorize protected data.
5. Check assurance. AAL1 requires TOTP step-up. AAL2 may proceed only if the access token is independently verified and all required claims pass.
6. If step-up is required, challenge exactly one verified TOTP factor, verify the submitted code, and re-check AAL2. Missing, unverified, ambiguous, failed, or stale factor state denies access.
7. Verify the Supabase access-token signature/issuer/audience/expiry using the trusted Worker verifier.
8. Map exact provider subject using trusted server configuration auth_provider = email_password to one existing active human identity. No email fallback, auto-provisioning, or virtual actor.
9. Only after separate integration approval may a future session-exchange implementation create a hash-only CMD session with atomic audit persistence, secure cookie controls, lifecycle checks, CSRF protections, and revocation semantics.
10. Every failure before authorization denies access; no protected data query or CMD session write may occur.

## Password reset and recovery

- Password reset must not alter the required TOTP factor or promote an AAL1 session to AAL2.
- Password reset is not factor recovery. Lost authenticator, TOTP factor reset/removal, and recovery-code operations require a separate high-assurance and audited process.
- Do not expose account existence through sign-in or reset responses.
- Rate-limit sign-in and reset attempts with abuse monitoring; do not introduce permanent lockout without a separately reviewed denial-of-service analysis.
- Do not log passwords, reset tokens, access/refresh tokens, TOTP codes, recovery codes, or raw session cookies.

## Synthetic test acceptance matrix

| Scenario | Expected result |
|---|---|
| Confirmed email + valid provider session | First-factor contract accepted; AAL2 still required |
| Missing/unconfirmed email | Deny |
| user_metadata.email_verified=true but no email_confirmed_at | Deny |
| Provider error or missing session | Generic deny |
| Password-only / AAL1 | Deny CMD access; require TOTP |
| TOTP missing/unverified/multiple/failed | Deny |
| TOTP success but AAL2 not confirmed | Deny |
| Valid signed AAL2 token | Eligible for exact subject mapping |
| Unknown/inactive/virtual CMD identity | Deny |
| Browser supplies provider, role, person ID, scope or email verification flag | Ignore/reject; server configuration and trusted provider response only |
| Password reset while session is AAL1 | Still require TOTP; no MFA bypass |
| Any denial | No CMD session issuance and no protected data read |

All tests must use synthetic identities, mock Auth responses, generated local signing keys, and disposable local databases. No test in this contract authorizes a real Supabase project or identity.