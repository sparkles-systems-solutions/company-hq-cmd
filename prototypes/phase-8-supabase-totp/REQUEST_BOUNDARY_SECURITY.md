# Phase 8 — Request boundary and browser mutation guard

Status: isolated prototype utilities with unit tests. They are not wired into production routes.

## Supabase bearer boundary

`supabase-request-auth.js` composes the verified JWT adapter and the exact provider-subject mapping. It accepts only a Bearer token, requires a successful cryptographic AAL2 verification result, then requires an active pre-provisioned human CMD mapping. It never maps by email, trusts request-supplied roles, creates accounts, issues CMD sessions, or sets cookies.

## Browser mutation protection

`request-security.js` supplies a guard for future cookie-authenticated mutation routes. It requires:
- Exact configured Origin match.
- Same-origin Fetch Metadata when the header is present.
- JSON content type.
- Matching `__Host-cmd_csrf` cookie and `x-cmd-csrf` header (double-submit pattern).

Safe methods bypass the mutation token check. Missing Origin policy fails closed. This helper does not issue CSRF tokens, authenticate sessions, or replace authorization checks. A future integration must create a cryptographically random CSRF token, set the cookie with Secure, HttpOnly=false, SameSite=Strict, Path=/ and no Domain, and protect the cookie-authenticated session with Secure, HttpOnly, SameSite=Strict.

## Test scope

Unit tests use synthetic bearer tokens, mocked verification, and mock D1 bindings. They do not contact Supabase, create credentials, or access remote D1. These helpers remain deliberately unintegrated until the first-factor method and verified CEO identity mapping are explicitly configured.

## Not performed

No session issuance, session cookie, CSRF token issuance, production route wiring, provider project configuration, real identity provisioning, D1 migration, deployment, or PR merge.
