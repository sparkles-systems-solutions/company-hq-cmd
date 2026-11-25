# Phase 5 — Worker Authorization Foundation

**Status:** Source scaffold, unit tests and local workerd/D1 integration tests committed on `foundation/phase-0`. CI passed on commit `7cd29a5769b985badb3ae0ab83bbdb33348a2477`. The Worker is not deployed and is not connected to a remote Cloudflare D1 database.

## Scope delivered

- `worker/src/authorization.js`: strict module/action/scope validation, cookie parsing, MFA requirement classification, deny-overrides-allow policy evaluator and SHA-256 helper.
- `worker/src/index.js`: D1-backed session lookup, active human identity check, current role assignment lookup, permission rule lookup, scoped grant lookup, audit writes, CORS/security response headers, minimal health and identity endpoints.
- `worker/tests/authorization.test.js`: unit tests for cookie parsing, malformed policy requests, scope validation, MFA requirements, virtual privileged-action denial, explicit deny precedence, default deny, scoped allow and D1 policy retrieval.
- `worker/tests/d1.integration.test.js`: Miniflare/workerd D1 integration coverage using synthetic local records.
- GitHub Actions workflow installs test dependencies and runs syntax, unit/integration, migration replay and safety checks.

## Security boundaries

- Only active human identities can authenticate through the current `auth_users` schema.
- The Worker does not issue sessions or credentials.
- Role/module/action/scope must be supplied by server-owned route policy, not client JSON. The current API exposes no business-data routes.
- No permission grants or scope grants are seeded; protected access remains denied until explicitly provisioned and reviewed.
- Virtual actors are denied `approve` and `execute`.
- Fresh MFA (10 minutes) is required for approve/execute and HR/FIN/SEC/REL/SHARE actions.
- Audit write failure causes the authorization path to throw; route handlers must translate that failure into a 503 and never continue with the protected operation.
- No-login share tokens and approval execution are not exposed as endpoints.

## Test status

The latest commit `7cd29a5769b985badb3ae0ab83bbdb33348a2477` has two successful GitHub Actions `worker-tests` checks. The workflow validates syntax, unit/integration tests, disposable SQLite migration replay and authorization safety invariants. The local Miniflare/workerd suite replays migrations through a D1 binding and tests the real Worker identity handler and D1-backed authorization behavior, including session status, role/scope binding, deny precedence, MFA and audit writes.

A previous source review found and fixed an undefined `policyRows` reference in `authorizeActor`; role policy rows are now loaded from D1 before deny-overrides-allow evaluation. MFA timezone-offset parsing was also corrected.

## Known limitations before staging

1. Add a reviewed human login provider and secure session issuance/rotation/revocation flow.
2. Configure a dedicated D1 binding named `DB` and exact approved `ALLOWED_ORIGIN`.
3. Validate against a dedicated remote disposable Cloudflare D1 database; local workerd simulation is not remote D1 validation.
4. Implement edge rate limiting and brute-force controls.
5. Add CSRF protection for future state-changing cookie-authenticated endpoints.
6. Add route-specific server-owned policies and tests before adding business endpoints.
7. Add atomic share-token access counting and read-only field filtering before enabling no-login links.
8. Define audit retention, backup and recovery controls.
9. Test authentication, MFA, expiry and revocation before staging.

## Not done

No remote or live D1 migration, authentication provider, OTP delivery, MFA enrollment, session issuance, share-link feature, business CRUD, production deployment, production credential, role activation or PR merge has occurred.
