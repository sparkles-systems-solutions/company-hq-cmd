# Phase 6 — Disposable Migration Replay & Authorization Schema Checks

**Status:** Passed in GitHub Actions on commit `7cd29a5769b985badb3ae0ab83bbdb33348a2477` (2026-11-25). Both push and pull-request `worker-tests` checks completed successfully. This includes syntax checks, Worker unit tests, migration replay/safety invariants, and the Miniflare/workerd D1 integration suite. Remote Cloudflare D1 integration remains pending. No live Cloudflare D1 database has been accessed or modified.

## 1. Source review completed

Reviewed migrations 0001–0005 and their dependencies:

- `0001_initial.sql`: base people, roles, assignments, approvals, audit and operational tables.
- `0002_virtual_legal_advisor.sql`: Legal Advisor virtual role/member seed.
- `0003_virtual_ai_role_catalogue.sql`: remaining virtual role catalogue.
- `0004_virtual_ai_member_onboarding.sql`: 41 virtual member/assignment records and onboarding checkpoints; explicitly resets all virtual people to `pending`.
- `0005_authorization_schema.sql`: module/permission catalogues, role rules, scoped grants, human authentication/session metadata, share-token metadata and approval controls.

## 2. Migration safeguards

Migration 0005 includes database-level safeguards:

1. Virtual role catalogue entries cannot receive `approve` or `execute` permission rules.
2. Active scope grants require an active human grantor and an active assigned role member, on both insert and update.
3. Approval controls must be created unconsumed and may only be consumed once by an active human.

These safeguards supplement Worker authorization and CEO approval controls.

## 3. Disposable migration replay

`scripts/validate_migrations.py` replays migrations 0001–0005 in an in-memory SQLite database and verifies:

- All migrations execute in order.
- Foreign-key checks report no violations.
- Expected counts: 11 departments, 41 roles, 41 virtual people, 41 role assignments and 60 permission catalogue entries.
- All 41 virtual people remain `pending` after replay.
- No role permission rules, scoped grants, login identities, sessions, share tokens or approval controls are seeded.
- Virtual identities cannot be created as login users or receive privileged permissions.
- Pending members cannot receive active scope grants, including through updates.
- Approval controls cannot be inserted consumed or consumed twice.
- Share-token test records obey active-human and seven-day expiry constraints.

## 4. Miniflare/workerd D1 integration suite

`worker/tests/d1.integration.test.js` uses Miniflare with an isolated local workerd D1 binding. It:

- Replays migrations 0001–0005 through the D1 binding API.
- Verifies catalogue and pending-member counts.
- Calls the real Worker `/api/me` handler with missing, revoked and active synthetic human sessions.
- Exercises `authorizeActor` against D1.
- Tests matching role+scope access and rejects a scope grant attached to a different role assignment.
- Tests explicit-deny precedence, MFA gating and audit writes.

The migration statement splitter handles SQL comments and trigger bodies; migration execution errors include the file, statement index and statement preview to improve diagnosis. Migration 0005's permission catalogue seed uses a VALUES CTE compatible with the bundled workerd SQLite limits.

## 5. CI verification

Latest commit: `7cd29a5769b985badb3ae0ab83bbdb33348a2477`.

- GitHub Actions check run `138917614136`: **success**.
- GitHub Actions check run `138917592289`: **success**.
- Both checks completed on 2026-11-25.
- The workflow runs Worker syntax checks, the combined unit/integration test suite, and the disposable SQLite migration/safety validation.

Earlier issues resolved:
- A test assumption was corrected because migration 0004 intentionally resets all virtual members to `pending`.
- Miniflare module detection was made explicit.
- Compatibility date was aligned with the bundled workerd runtime.
- The D1 test migration runner now executes SQL statements individually and recognizes commented CREATE TRIGGER declarations.
- A six-way UNION seed was replaced with a VALUES CTE to avoid the bundled SQLite compound-select limit.
- An undefined `policyRows` reference in `authorizeActor` was fixed by loading role policy rows from D1; MFA timezone-offset parsing was corrected.

## 6. Remaining validation boundary

- Local workerd/Miniflare D1 integration: **passed in CI**.
- Disposable remote Cloudflare D1 validation: **pending**.
- Live D1: untouched.
- Worker deployment: not performed.
- Production: untouched.

Local workerd validation is stronger than a D1 mock but is not proof of behavior against a remote Cloudflare account/database or a deployed Worker.

## 7. Next requirements

1. Use a dedicated disposable Cloudflare D1 database, never production, for remote compatibility validation.
2. Replay migrations 0001–0005 through Cloudflare's D1 migration runner.
3. Verify triggers, foreign keys, timestamp behavior and all Worker queries against that database.
4. Complete authentication, session issuance/revocation, MFA enrollment/verification and rate-limit testing.
5. Keep no-login share links disabled until server-side field allowlisting, filter enforcement, expiry, revocation, rate limiting and audit behavior are tested.
6. Obtain CEO approval before staging deployment, credential creation, security-sensitive changes or any live D1 migration.

**No migration or deployment is authorized for production by this report.**
