# Phase 8 — Session lifecycle policy

## Status
Isolated policy helpers and synthetic unit tests only. This is not a login/session
implementation and is not wired into the Worker request handler.

## Policy defaults
| Control | Prototype policy |
|---|---:|
| Idle timeout | 30 minutes |
| Absolute lifetime | 12 hours |
| MFA freshness | 10 minutes |
| Last-seen write throttle | 5 minutes |

Absolute expiry is fixed at issuance and must not slide when last_seen_at is updated.
A session is rejected when revoked, malformed, expired, idle, issued in the future,
or configured beyond the absolute lifetime.

## Existing schema fit
Migration 0005 already contains auth_sessions fields for issued_at, expires_at,
last_seen_at, revoked_at, revoke_reason and mfa_verified_at. The policy helpers
do not require a schema migration.

## Required integration work (not performed)
1. Validate Supabase JWT signature, issuer, audience, expiry and AAL2.
2. Map the exact verified provider subject to a pre-provisioned active human.
3. Create a separate opaque CMD session; store only its SHA-256 hash.
4. Set a Secure, HttpOnly, SameSite=Strict, Path=/, host-only session cookie.
5. Rotate sessions safely after reauthentication and revoke the prior session.
6. Support current-session and all-session revocation; audit failures must fail closed.
7. Apply CSRF/Origin protection to browser mutations.
8. Ensure session creation and rotation are atomic; never log raw tokens.

## Test boundary
worker/tests/session-lifecycle.test.js uses synthetic timestamps only. It does not
connect to Supabase, D1, a browser, a cookie jar or any live identity. No real
session has been created and no credentials or MFA factors have been enrolled.

## Outstanding CEO decision
Supabase is selected as provider and TOTP as second factor. The first-factor method
and verified sign-in identifier remain undecided. Select these before building the
real sign-in flow; do not infer email/password or email-OTP.
