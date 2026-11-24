# Phase 4 — Authorization Schema & Migration Validation

**Status:** Draft migration committed; local SQLite compatibility checks passed against a minimal parent-schema contract.  
**Migration:** `migrations/0005_authorization_schema.sql`  
**Branch:** `foundation/phase-0`

## 1. Scope

This phase adds an additive authorization schema for the CMD. It does not alter or drop tables from migrations 0001–0004.

New structures:
- `module_catalogue` and `permission_catalogue`: 10 modules × 6 actions (read, draft, propose, test, approve, execute).
- `role_permission_rules`: role policy mapping with explicit allow/deny effect and scope requirement. It is intentionally empty after migration.
- `role_scope_grants`: assignment-linked project/department/record/company scope grants; new grants default to pending.
- `auth_users` and `auth_sessions`: human login identity and hashed session-token metadata.
- `dashboard_share_tokens`: hashed, read-only share-token metadata, explicit fields/filters, revocation, access limit and maximum seven-day lifetime.
- `approval_controls`: immutable action/resource/environment/payload binding for a CEO-approved operation, with one-time consumption metadata.

Triggers prevent virtual members from becoming login identities, creating dashboard share links, activating scope grants, or acting as approval authority. Approval controls require a corresponding approved legacy `approvals` row naming an active human approver.

## 2. Deliberate deny-by-default behavior

- The migration seeds 60 permission definitions only; definitions are not grants.
- `role_permission_rules` is empty. No role receives access from this migration.
- No `auth_users`, `auth_sessions`, scope grants, dashboard share tokens, or approval controls are seeded.
- Existing virtual roster records and assignments are unchanged and remain pending under their existing onboarding process.
- No CEO login identity is created because the authentication provider and verified login identifier have not been selected.

## 3. Local validation performed

The migration SQL was executed in an in-memory SQLite database with a minimal parent-table contract matching the referenced columns and key types from migration 0001. This is a local SQL compatibility check, not a full replay of migrations 0001–0004 and not a Cloudflare D1 integration test.

| Check | Result |
|---|---|
| Migration SQL execution | Passed |
| Permission catalogue row count | 60 |
| Role permission rules initially seeded | 0 |
| New scope grant default | `pending` |
| Virtual member login identity rejected | Passed |
| Active human login identity and session accepted | Passed |
| Share token scope mutation rejected | Passed |
| Active human share-token creation accepted | Passed |
| Virtual approver rejected by approval-control trigger | Passed |
| Approval control one-time consumption / replay reset rejected | Passed |
| SQLite foreign-key check | No violations |

## 4. Required Worker/API enforcement before use

Database constraints are defense-in-depth, not the complete authorization system. The Cloudflare Worker must still:
1. Authenticate sessions using a cryptographically random opaque token; store and compare only a strong hash (or keyed hash) server-side.
2. Check session expiry, revocation, account status, MFA freshness, and the current active human/virtual identity on every request.
3. Resolve role assignments and scope grants from D1 on the server; never trust browser-supplied role, module, action, scope, or approval status.
4. Deny by default and require a matching active permission rule and active, unexpired scope grant.
5. Categorically deny virtual actors `approve` and `execute`, regardless of client claims or seeded policy data.
6. Validate dashboard share tokens by hash, expiry, revocation, access count, exact dashboard, field allowlist and filters. Enforce read-only behavior and no export/search/navigation beyond the authorized view.
7. Verify the linked legacy approval is still approved and matches the exact action, resource, environment, payload hash and expiry immediately before any separately authorized human execution.
8. Consume approval controls atomically to prevent replay; approval does not itself execute an operation.
9. Write append-only security events to `audit_logs` for sensitive reads, denials, token creation/use/revocation, approval and execution attempts.
10. Use parameterized SQL, rate limits, no-store responses, strict CORS, referrer protection, and fail-closed behavior on D1/auth errors.

The Worker must also check that the referenced `role_assignment` and its `people` row remain active and unexpired. The schema does not make a client-side check authoritative.

## 5. Open items / not implemented

- No Cloudflare Worker middleware or API endpoint has been implemented.
- No login provider, OTP delivery service, MFA enrollment, credential, or real CEO login has been configured.
- No permission rules or operational role scopes have been populated.
- No share link has been created or enabled.
- No approval has been issued or executed.
- No automated test suite, disposable D1 migration replay, staging test, production D1 migration, deployment, or PR merge has been performed.
- No real virtual AI agent has been instantiated or activated.

## 6. Next step

Phase 5 should implement the Worker authorization middleware and automated allow/deny tests against a disposable local/staging D1 database. The implementation must be reviewed against the Phase 2 permission matrix and Phase 3 enforcement design before any production connection. CEO approval remains mandatory for production credentials, live migrations, release/deployment, and operational activation.
