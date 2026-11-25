# Phase 8 — Isolated Supabase Auth + TOTP Prototype

**Status:** isolated prototype foundation only. No Supabase project, account, credentials, real user, remote database, Worker deployment, or production configuration is created or changed.

## CEO-approved scope
- Provider: Supabase Auth
- MFA: TOTP authenticator app
- Environment: isolated local/disposable prototype only
- Exclusions: production deployment, real user activation, live D1 changes, production secrets, and PR merge.

## What this prototype validates
This prototype now includes a `jose`-based JWT signature verifier against the project's asymmetric Supabase JWKS, followed by an independently testable AAL2 claims gate. It does not issue CMD sessions or grant CMD permissions. The verifier fails closed for legacy symmetric signing configurations; those require a separately reviewed Auth-server verification path.

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

`worker/src/supabase-totp.js` now contains a mock-testable step-up adapter. It checks the Supabase AAL state, requires exactly one already-verified TOTP factor, requests a challenge, verifies the six-digit code, and rechecks that the resulting session is AAL2. It fails closed on missing/multiple factors and provider errors. It does not enroll or remove factors, display QR codes, or establish a CMD session.

## TOTP flow for a disposable Supabase project
1. Create a separate Supabase development project; do not use production.
2. Disable public sign-up and invite only a designated test identity.
3. Enable TOTP MFA.
4. Use Supabase Auth PKCE flow for first-factor sign-in.
5. Read getAuthenticatorAssuranceLevel(). If current level is aal1 and next level is aal2, require a TOTP challenge.
6. Call mfa.challenge() and mfa.verify(); continue only when the resulting session is aal2.
7. Verify the access token at the Worker boundary and map its sub to an already-provisioned active human auth_users row.
8. Keep CMD D1 authorization (role, permission, scope, audit) independent from Supabase identity.

Supabase's documented TOTP lifecycle is enroll → challenge → verify. Successful verification upgrades the session to aal2. Official references:
- https://supabase.com/docs/guides/auth/auth-mfa/totp
- https://supabase.com/docs/guides/auth/auth-mfa
- https://supabase.com/docs/guides/auth/sessions/pkce-flow
- https://supabase.com/docs/guides/auth/jwt-fields

## Security boundaries
- Never put a Supabase secret/service-role key in browser code or Git.
- A publishable/anon key is not an authorization grant; server-side checks remain mandatory.
- Do not trust user_metadata, browser-provided role claims, person IDs, or permission/scope fields.
- Do not store Supabase access/refresh tokens in localStorage for the intended CMD architecture.
- Do not issue a CMD __Host-cmd_session cookie until the Worker has verified the JWT, confirmed aal2, mapped the subject to the one active human identity, and successfully written D1 audit/session records.
- Do not add or apply migration 0006 in this prototype.
- No authentication identity or TOTP factor is enrolled by these source files.

## Local validation
From worker/: npm test and npm run check. Tests are deterministic and require no Supabase account, network call, secrets, or D1 database.

## Next implementation gate
Before connecting the Worker, independently review JWT signing algorithm and JWKS verification, session exchange and secure cookie design (including PKCE verifier handling), atomic D1 session creation and fail-closed audit behavior, TOTP enrollment/recovery and factor-reset procedures, and disposable Cloudflare D1 compatibility plus browser CSRF/Origin protections.

Only after these tests and a security review should a separate staging proposal be prepared. This CEO approval does not authorize staging or production changes.
