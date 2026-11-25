# Phase 8 — Isolated Supabase Auth + Email/Password + TOTP Prototype

**Status:** isolated prototype foundation and design only. No Supabase project, account, credentials, real user, remote database, Worker deployment, or production configuration is created or changed.

## CEO-approved authentication decisions
- Identity provider: Supabase Auth
- First factor: **Email + Password**
- Sign-in identifier: **verified email address**
- Second factor: **TOTP authenticator app**
- Required assurance before CMD access: **AAL2**
- Scope: isolated prototype design and synthetic/local tests only

See `CEO_EMAIL_PASSWORD_TOTP_DECISION.md` for the CEO decision and `EMAIL_PASSWORD_TOTP_FLOW_CONTRACT.md` for ordered acceptance rules and synthetic test cases. See `NONPRODUCTION_SUPABASE_READINESS.md` for the project-isolation and secret-handling plan; it is a checklist only and does not authorize project creation.

## What this prototype validates
This prototype includes a `jose`-based JWT signature verifier against the project's asymmetric Supabase JWKS, followed by an independently testable AAL2 claims gate. It does not issue CMD sessions or grant CMD permissions. The verifier fails closed for legacy symmetric signing configurations; those require a separately reviewed Auth-server verification path.

Expected verified Supabase access-token claims:
- Exact project issuer: https://<project-ref>.supabase.co/auth/v1
- Audience: authenticated
- Role: authenticated
- Non-empty subject and session ID (UUIDs)
- Unexpired token with valid issued-at time
- Authenticator assurance level: aal2

The Worker must verify JWT signature, issuer, audience, expiry and key rotation against the project's trusted JWKS before calling this claim gate. This gate is not a substitute for signature verification.

## JWT verification implemented in the prototype

`worker/src/supabase-jwt-verifier.js` validates the configured HTTPS Supabase project URL, retrieves the project's Auth JWKS, and verifies signature, exact issuer, `authenticated` audience, expiry, and an explicit algorithm allowlist using `jose`. It then requires the AAL2 claim, UUID-shaped subject/session identifiers, and rejects anonymous identities. The JWKS resolver is cached by project URL. Tests use generated local ES256 keys; no network or Supabase credentials are needed.

The verifier is not yet wired into the Worker request handler or CMD session creation. It must be integrated only after the remaining session/CSRF/audit review.

`worker/src/supabase-totp.js` contains a mock-testable step-up adapter. It checks the Supabase AAL state, requires exactly one already-verified TOTP factor, requests a challenge, verifies the six-digit code, and rechecks that the resulting session is AAL2. It fails closed on missing/multiple factors and provider errors. It does not enroll or remove factors, display QR codes, or establish a CMD session.

## Intended sign-in sequence (design only)

1. Sign in with verified email + password using Supabase Auth PKCE.
2. Require provider-confirmed email; deny unverified identities.
3. Check assurance level and require TOTP challenge/verification unless the session is already AAL2.
4. Continue only when the resulting session is AAL2.
5. Worker verifies the signed access token and maps the exact provider subject to an existing active human CMD identity.
6. A future session exchange may issue a CMD cookie only after session, audit, D1, CSRF and lifecycle controls are integrated and separately approved.

Password storage and verification belong to Supabase Auth. CMD Worker/D1 must never store or log plaintext passwords or password hashes. Public self-registration is disabled in the intended company deployment; no live project configuration has been applied.

## Security boundaries
- Never put a Supabase secret/service-role key in browser code or Git.
- A publishable/anon key is not an authorization grant; server-side checks remain mandatory.
- Do not trust user_metadata, browser-provided role claims, person IDs, or permission/scope fields.
- Do not store Supabase access/refresh tokens in localStorage for the intended CMD architecture.
- Do not issue a CMD `__Host-cmd_session` cookie until the Worker has verified the JWT, confirmed aal2, mapped the subject to the one active human identity, and successfully written D1 audit/session records.
- Do not add or apply migration 0006 in this prototype.
- No authentication identity or TOTP factor is enrolled by these source files.

## Local validation
From `worker/`: `npm test` and `npm run check`. Tests are deterministic and require no Supabase account, network call, secrets, or D1 database.

## Next implementation gate
The CEO has selected Email + Password and approved TOTP for isolated prototype design. Before live provider integration, separately approve an isolated non-production Supabase project and secret handling. Review password/email verification settings, TOTP enrollment and recovery, session exchange and secure cookie design, atomic D1 session/audit writes, CSRF/Origin protections, and remote D1 compatibility. No staging or production work is authorized.
