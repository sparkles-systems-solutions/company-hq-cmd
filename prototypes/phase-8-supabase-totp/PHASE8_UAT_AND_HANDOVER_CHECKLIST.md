# Phase 8 — UAT and handover checklist

**Current result:** isolated prototype and automated test foundation only. This checklist distinguishes completed local/CI evidence from pending integrated acceptance.

## A. Automated checks with current CI evidence

- [x] Worker JavaScript source syntax validation
- [x] Authorization primitive and D1 mock tests
- [x] Supabase JWT verifier tests using locally generated synthetic keys
- [x] Email/password first-factor response contract tests (trusted synthetic Auth response, verified-email timestamp, no token leakage)
- [x] Email/password provider identity mapping tests using exact subject UUID
- [x] Password-reset/TOTP boundary test: AAL1 still requires TOTP and cannot enter CMD
- [x] TOTP step-up adapter tests with synthetic provider responses
- [x] Exact provider-subject-to-human mapping tests
- [x] Session lifecycle boundary and last-seen refresh helper tests
- [x] Session pipeline ordering and fail-closed dependency-injection tests
- [x] CORS preflight contract tests for current allow-header behavior
- [x] Disposable Miniflare D1 session/audit batch success and rollback tests
- [x] Disposable Miniflare D1 compare-and-set rotation-claim race test
- [x] Disposable Miniflare D1 rotation/audit rollback and exchange-idempotency tests
- [x] Disposable SQLite migration replay and safety invariants

These checks use synthetic identities, locally generated keys, mocks, and disposable databases. GitHub Actions run [#144](https://github.com/sparkles-systems-solutions/company-hq-cmd/actions/runs/45585460944) passed the code commit `2cf5e2ba02f296106e74845f1346629beead6534` (syntax check, unit tests, disposable SQLite migration/safety checks). The two subsequent branch commits were documentation-only; run #144 is not claimed as a run on the latest documentation head. These checks do not prove a deployed authentication flow or remote D1 behavior.

## B. Integrated UAT — not yet executable

- [x] CEO selects first-factor method and verified sign-in identifier (Email + Password; verified email; TOTP second factor) — design-only approval
- [ ] Approved isolated Supabase test project/configuration and secrets
- [ ] End-to-end sign-in and TOTP challenge/verification
- [ ] One-time Supabase-to-CMD session exchange; hash-only session storage
- [ ] Secure cookie attributes and logout clearing
- [ ] Idle and fixed absolute session expiry in actual Worker request handling
- [ ] Current-session and global logout/revocation
- [ ] Rotation with concurrent requests and audit failure
- [ ] CSRF token issuance, CORS allow-header and browser mutation integration
- [ ] Route-level RBAC and exact scope checks for real API handlers
- [ ] Scoped read-only dashboard link lifecycle and revocation
- [ ] Rate limiting, recovery, monitoring and alerting
- [ ] Independent security review and accessibility/browser compatibility

## C. Deployment and operational gates

- [ ] Remote Cloudflare D1 atomicity/consistency behavior verified in an approved non-production environment
- [ ] Backup and restore drill completed
- [ ] Secrets stored only in approved secret manager
- [ ] Staging deployment approved and tested
- [ ] Rollback procedure and incident contact documented
- [ ] Data retention, privacy, and audit retention approved
- [ ] CEO records explicit UAT acceptance
- [ ] CEO separately approves production deployment

## D. Handover statement

Do not describe Phase 8 as production-ready or complete authentication. Current verified status is isolated adapter/helper/test coverage plus design documents. The first-factor choice is recorded for design-only use. Session exchange, runtime lifecycle enforcement, real route integration, share implementation, remote D1 verification, and deployment remain outstanding.

Production deployment, real user activation, live D1 changes, real TOTP enrollment, and PR merge each require their own explicit approval.

## E. Additional isolated exchange-planner checks (code added after CI #130)

- [x] CI run #142 passed on commit `d9a8005d08f04e0e64f8701b842b043b845897c0` (syntax, unit tests, disposable SQLite migration/safety checks).
- [x] Pure planner requires trusted JWT verification and issuer/audience/expiry gate results.
- [x] Rejects AAL1, unapproved provider, unverified email, inactive/non-human mapping, malformed UUIDs, and stale MFA.
- [x] Requires browser mutation guard success and a short-lived SHA-256 exchange-key hash.
- [x] Rejects consumed/replayed, expired, malformed, and overlong exchange keys.
- [x] Returns only a non-secret plan; no token, cookie, D1 write, exchange-key consume, or route integration.
- [ ] End-to-end exchange, cookie issuance, D1 atomic commit, and browser CSRF/CORS integration remain not implemented.



## F. Batch 8 — non-production approval and custody controls

- [x] Added `CEO_NONPRODUCTION_PROJECT_APPROVAL_RECORD.md` as an uncompleted approval template; no approval is recorded.
- [x] Added `NONPRODUCTION_SECRET_CUSTODY_CHECKLIST.md` for least-privilege access, evidence, rotation, revocation, and cleanup.
- [ ] CEO must explicitly approve a named non-production project, owner, region, cost ceiling, expiry, custodians, and exact permitted actions before project creation.
- [ ] Secret manager and named custodians remain unapproved; no secrets have been generated or stored.

These are documentation-only controls. They do not authorize project creation, secrets, remote D1, deployment, session exchange, real-user activation, or PR merge.

## G. Batch 10 — authentication integration implementation plan (design only)

- [x] Added staged implementation plan covering provider adapter, one-time exchange key, target atomic session/exchange/audit commit, cookie and CSRF/CORS, runtime lifecycle, logout/revocation/rotation, route RBAC/data scopes, remote D1 verification, UAT, and release gates.
- [x] Defined proposed API contracts while clearly marking them as not implemented routes.
- [x] Defined no-go conditions, acceptance matrix, evidence requirements, and CEO/virtual-role responsibility boundaries.
- [ ] CEO approval for a named non-production Supabase project and secret custody remains outstanding.
- [ ] Provider project creation, secrets, live sign-in/TOTP, remote D1, runtime exchange/cookie integration, deployment, real-user activation, PR readiness, and merge remain unauthorized or unimplemented pending their separate approvals.

Batch 10 changed documentation only. No CI run is claimed for this documentation-only update; the latest cited code CI evidence remains run #144 on commit 2cf5e2ba02f296106e74845f1346629beead6534.
