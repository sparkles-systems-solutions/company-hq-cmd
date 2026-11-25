# CEO Decision — Email + Password First Factor with TOTP MFA

**Decision date:** 2026-11-25  
**Project:** CMD Phase 8 — isolated Supabase Auth prototype  
**Decision owner:** CEO, Sparkles Systems & Solutions  
**Status:** Approved for isolated prototype design only

## 1. Recorded decision

- Identity provider: Supabase Auth
- First factor: **Email + Password**
- Sign-in identifier: **verified email address**
- Second factor: **TOTP authenticator app**
- Required assurance: continue to CMD session exchange only after verified AAL2
- Scope: isolated prototype design and synthetic/local tests only

This decision does not authorize a real Supabase project, real user activation, TOTP enrollment, production credentials, Worker deployment, live D1 changes, PR merge, staging, or production release.

## 2. Intended sign-in sequence

1. User submits email and password to Supabase Auth through the approved browser PKCE flow.
2. Supabase validates the credentials. CMD must not receive or store the user's password.
3. The application checks that the returned identity has a verified email address. An unverified identity must not proceed.
4. The application checks the Supabase Authenticator Assurance Level (AAL).
5. If the session is not AAL2, require the already enrolled TOTP factor: challenge, then verify the submitted code.
6. Continue only after the resulting session is confirmed as AAL2.
7. The Worker verifies the access-token signature, trusted issuer, audience, expiry and required claims; maps the exact provider subject to an existing active human identity; then applies CMD authorization independently.
8. A future CMD session exchange may issue a secure CMD session only after all integration gates, D1 atomicity, audit, CSRF and session lifecycle controls are implemented and approved.

No step in this document is an implemented login route or a live sign-in flow.

## 3. Account and email policy

- Email is the sign-in identifier; require provider-confirmed/verified email before access.
- Disable public self-registration for the intended company CMD deployment; accounts must be provisioned through a controlled administrative process.
- Map provider identity by immutable Supabase subject UUID to an existing CMD human record. Do not map by email alone and do not auto-create CMD users during login.
- Email changes must be verified at the identity provider and reconciled through a separately audited account-maintenance process; never silently change the CMD subject mapping.
- Do not disclose whether an email address exists during sign-in, reset, or recovery responses.
- Do not log passwords, password-reset tokens, access/refresh tokens, TOTP codes, recovery codes, or raw session cookies.

## 4. Password and credential handling

- Password verification and password storage belong to Supabase Auth; CMD Worker and D1 must never store or log plaintext passwords or password hashes.
- Use the provider's current password policy and breached-password protections where available; exact project settings must be reviewed before any isolated provider project is approved.
- Rate-limit sign-in and password-reset attempts and monitor repeated failures. Do not invent a permanent account-lockout policy that could enable denial-of-service; define progressive throttling and recovery controls during implementation review.
- Password reset is not a substitute for TOTP recovery. A password reset alone must not silently remove or bypass the enrolled second factor.
- Recovery, factor reset and lost-device handling require a separate, auditable high-assurance procedure and CEO-approved policy.

## 5. TOTP and assurance requirements

- TOTP remains the required second factor for the approved prototype.
- Enrollment, QR display, factor removal, recovery codes and factor reset are not implemented or authorized by this decision.
- Continue only when Supabase confirms the resulting session is AAL2 and the Worker independently validates the signed access token and required claims.
- A valid password-only AAL1 session is insufficient for CMD access.
- Privileged CMD actions may additionally require fresh MFA according to the existing authorization policy.

## 6. Browser and session boundaries

- Use Supabase Auth PKCE flow; keep the PKCE verifier in an appropriate browser-managed transient context and never expose it in logs.
- Do not persist Supabase access/refresh tokens in localStorage for the intended CMD architecture.
- No CMD session cookie may be issued until the future server-side exchange has completed identity mapping, session policy checks, and atomic D1 session/audit persistence.
- The future CMD cookie must be reviewed for Secure, HttpOnly, SameSite and host-only protections; CSRF/Origin validation is mandatory for cookie-authenticated mutations.
- Session idle expiry, fixed absolute expiry, rotation, logout, global revocation, replay protection and audit behavior remain mandatory integration gates.

## 7. Test plan — synthetic only

The isolated prototype may add tests for:
- Missing, malformed, unverified or mismatched email claims: deny.
- Password-only/AAL1 session: deny CMD access.
- AAL2 session with trusted issuer/audience/signature/expiry: eligible to proceed to exact subject mapping.
- Unknown provider subject, inactive human, or virtual actor: deny.
- Provider errors, rate-limit responses and reset-flow errors: fail closed without account enumeration.
- TOTP missing, multiple, unverified, failed or stale: deny.
- Password reset does not change TOTP assurance or CMD permissions.
- No password, access token, refresh token, TOTP code or recovery secret appears in logs or D1 test fixtures.

Tests must use generated keys, mock provider responses and synthetic identities. They must not connect to a real Supabase project or activate a real user.

## 8. Outstanding decisions and approvals

Before any live provider integration:
1. CEO separately approves creation/configuration of an isolated non-production Supabase project and secret-management approach.
2. Review exact Supabase password policy, email verification, SMTP/delivery and abuse-control settings.
3. Review TOTP enrollment, recovery and factor-reset operations.
4. Review session exchange, cookie, CSRF, D1 atomicity and audit integration.
5. Approve a separate non-production integration/UAT scope.

Production deployment, real user activation, live D1 changes, real TOTP enrollment, production secrets/configuration and PR merge remain separately gated by explicit CEO approval.
