# Phase 5 — Worker Authorization Foundation

**Status:** Source scaffold and unit tests added on `foundation/phase-0`. Not deployed and not connected to D1.

## Scope delivered

- `worker/src/authorization.js`: strict module/action/scope validation, cookie parsing, MFA requirement classification, deny-overrides-allow policy evaluator, SHA-256 helper.
- `worker/src/index.js`: D1-backed session lookup, active human identity check, current role assignment lookup, permission rule lookup, scoped grant lookup, audit writes, CORS/security response headers, minimal health and identity endpoints.
- `worker/tests/authorization.test.js`: Node built-in tests for cookie parsing, malformed policy requests, scope validation, MFA requirements, virtual privileged-action denial, explicit deny precedence, default deny, scoped allow, D1 role-policy retrieval, and scoped authorization outcomes.
- `worker/package.json`: dependency-free local test scripts.

## Security boundaries

- Only active human identities can authenticate through the current `auth_users` schema.
- The Worker does not issue sessions or credentials.
- Role/module/action/scope must be supplied by server-owned route policy, not client JSON. The current API exposes no business-data routes.
- No permission grants or scope grants are seeded; all protected access remains denied until explicitly provisioned and reviewed.
- Virtual actors are denied `approve` and `execute`.
- Fresh MFA (10 minutes) is required for approve/execute and HR/FIN/SEC/REL/SHARE actions.
- Audit write failure causes the authorization call path to throw; route handlers must translate that failure into a 503 and never continue with the protected operation.
- No-login share tokens and approval execution are not exposed as endpoints.

## Test status

GitHub Actions run #30 (`45518871104`) completed successfully on 2026-11-25. Syntax check passed, all 11 unit tests passed, and the disposable SQLite migration replay/safety checks passed. The source review found and fixed an undefined `policyRows` reference in `authorizeActor`; the Worker now loads role policy rows from D1 before applying explicit-deny precedence. MFA timezone-offset parsing was also corrected. These tests still do not prove actual Cloudflare D1 query behavior or deployed Worker behavior; D1 integration remains pending.

## Known limitations before staging

1. Add a login provider and secure session issuance/rotation flow; do not hand-create sessions.
2. Configure D1 binding `DB` and exact `ALLOWED_ORIGIN`.
3. Implement rate limiting at the edge and add brute-force controls.
4. Add CSRF protection for future state-changing cookie-authenticated endpoints.
5. Add route-specific policies and integration tests before adding any business endpoint.
6. Add atomic share-token access counting and read-only field filtering before enabling no-login links.
7. Add an immutable audit strategy and operational retention/backup controls.
8. Verify corrected MFA timestamp parsing against actual D1 timestamp formats in integration tests.
9. Verify full migrations 0001–0005 against disposable D1 before staging.
10. Verify in D1 integration tests that permission rules and scope grants belong to the same active role assignment.

## Not done

No live D1 migration, authentication provider, OTP delivery, MFA enrollment, session issuance, share-link feature, business CRUD, production deployment, production credential, role activation, or PR merge has occurred.
