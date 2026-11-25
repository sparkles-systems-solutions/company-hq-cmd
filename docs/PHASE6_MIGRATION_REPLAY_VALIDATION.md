# Phase 6 — Disposable Migration Replay & Authorization Schema Checks

**Status:** Disposable SQLite migration replay, authorization safety invariants and expanded Worker policy tests passed in GitHub Actions run #30 on 2026-11-25. Cloudflare D1 runtime integration remains pending. No live Cloudflare D1 database has been accessed or modified.

## 1. Source review completed

Reviewed the migration chain and its referenced schema:

- `0001_initial.sql`: confirms `people`, `roles`, `role_assignments`, `approvals`, and `audit_logs` columns used by later migrations and the Worker audit insert.
- `0002_virtual_legal_advisor.sql`: seeds the Legal Advisor as a virtual member and role assignment.
- `0003_virtual_ai_role_catalogue.sql`: defines the other 40 virtual roles and departments.
- `0004_virtual_ai_member_onboarding.sql`: seeds the remaining virtual member identities and role assignments, then explicitly resets **all** virtual people—including the previously seeded Legal Advisor from 0002—to `pending`.
- `0005_authorization_schema.sql`: creates module/permission catalogues, role rules, scoped grants, human authentication/session metadata, share-token metadata and approval controls.

## 2. Hardening changes made to migration 0005

The source review identified three database-level safeguards that should not depend solely on application code. Added:

1. Role permission rules cannot grant `approve` or `execute` to virtual role catalogue entries.
2. A scoped grant cannot be inserted or later updated to active unless its grantor is an active human and the assigned role member is active.
3. An approval control must be created unconsumed; consumption is a one-time update by an active human.

These constraints supplement, not replace, Worker authorization and CEO approval controls.

## 3. Automated disposable replay harness

Added `scripts/validate_migrations.py`. It uses Python's built-in SQLite engine and replays migrations 0001–0005 in order in an in-memory database. It checks:

- All migrations execute without SQL errors.
- Foreign-key enforcement is enabled and `PRAGMA foreign_key_check` reports no violations.
- Expected roster/catalogue counts: 41 roles, 41 virtual people, 41 role assignments, and 60 permission catalogue entries; all 41 virtual people must be `pending` after migration replay.
- No role permission rules, scoped grants, login identities, sessions, share tokens or approval controls are seeded by the migration chain.
- Virtual roster identities cannot be created as login users.
- Virtual role catalogue entries cannot be granted approve/execute.
- Pending role members cannot receive active scope grants, including by updating an initially pending grant.
- Approval controls cannot be inserted already consumed and cannot be consumed twice.
- Share tokens can be created in the disposable test only by a synthetic active human and within the seven-day expiry cap.

The GitHub Actions workflow was extended to run this harness alongside Worker syntax checks and unit tests. Its path filters include Worker source, migrations, validation scripts and the workflow itself.

## 4. Verification status

- Migration source review: completed.
- Validation script: committed.
- Initial CI run #17: Worker syntax and all 8 unit tests passed; migration replay failed because the test incorrectly assumed the Legal Advisor remained active after migration 0004. The migration explicitly resets all virtual members to `pending`.
- Corrective test change committed: the disposable test now explicitly simulates a CEO-approved status transition inside the in-memory database before testing the active-grant path, then restores the member to `pending`.
- Corrected GitHub Actions run #25 (`45518706938`): full SQLite replay and safety invariant checks passed.
- Subsequent Worker authorization review found an undefined `policyRows` reference in `authorizeActor`. It was corrected to retrieve role policy rows from D1 before applying deny-overrides-allow. MFA timezone-offset parsing was also corrected.
- GitHub Actions run #30 (`45518871104`): syntax check passed, 11/11 Worker unit tests passed, and full migration replay/safety checks passed.
- Cloudflare D1 compatibility: **not yet proven**. The Worker policy tests use a test double; they do not execute the SQL against Cloudflare D1. SQLite in-memory replay is a useful schema-level check, but it is not the Cloudflare D1 runtime.
- Disposable D1 integration: pending.
- Live D1: untouched.
- Production: untouched.

## 5. Next requirements

1. Create or identify a dedicated disposable Cloudflare D1 database; do not use the production database.
2. Replay migrations 0001–0005 in order using the Cloudflare D1 migration runner.
3. Verify D1 JSON functions, triggers, date/time behavior, foreign keys and Worker queries.
4. Run Worker integration tests against the actual D1 binding for session lookup, role-policy retrieval, same-assignment scope matching, audit failure and deny behavior.
5. Test authentication, session revocation, MFA and share-token restrictions against D1.
6. Obtain CEO approval before any staging deployment or live D1 migration.

**No migration is authorized for production by this report.**
