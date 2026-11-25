# Phase 8 — UAT and handover checklist

**Current result:** isolated prototype and automated test foundation only. This checklist distinguishes completed local/CI evidence from pending integrated acceptance.

## A. Automated checks with current CI evidence

- [x] Worker JavaScript source syntax validation
- [x] Authorization primitive and D1 mock tests
- [x] Supabase JWT verifier tests using locally generated synthetic keys
- [x] TOTP step-up adapter tests with synthetic provider responses
- [x] Exact provider-subject-to-human mapping tests
- [x] Session lifecycle boundary and last-seen refresh helper tests
- [x] Session pipeline ordering and fail-closed dependency-injection tests
- [x] CORS preflight contract tests for current allow-header behavior
- [x] Disposable Miniflare D1 session/audit batch success and rollback tests
- [x] Disposable Miniflare D1 compare-and-set rotation-claim race test
- [x] Disposable Miniflare D1 rotation/audit rollback and exchange-idempotency tests
- [x] Disposable SQLite migration replay and safety invariants

These checks use synthetic identities, locally generated keys, mocks, and disposable databases. They do not prove a deployed authentication flow or remote D1 behavior.

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

Do not describe Phase 8 as production-ready or complete authentication. Current verified status is isolated adapter/helper/test coverage plus design documents. First-factor choice, session exchange, runtime lifecycle enforcement, real route integration, share implementation, remote D1 verification, and deployment remain outstanding.

Production deployment, real user activation, live D1 changes, real TOTP enrollment, and PR merge each require their own explicit approval.
