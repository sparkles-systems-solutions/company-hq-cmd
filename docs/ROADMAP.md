# Roadmap

## Phase 0 — Foundation
- Establish repository structure and governance documentation.
- Define data model and security boundaries.
- Keep all sample data synthetic.

## Phase 1 — Secure platform core
- Cloudflare Worker API.
- D1 migrations and environment separation.
- Authentication, MFA, session lifecycle, RBAC, and audit logging.
- API and security tests.

## Phase 2 — Organization and portfolio
- Departments, role assignments, and project register.
- Milestones, tasks, dependencies, risks, and dashboards.

## Phase 3 — Delivery governance
- QA test cases, defects, UAT evidence, release readiness, and approvals.

## Phase 4 — Finance and operations
- Budget requests, cost tracking, operational reporting, and controlled notifications.

## Phase 5 — Integrations and production
- Approved GitHub integrations, backups, monitoring, recovery drills, and production acceptance.

No phase is complete solely because a screen or placeholder exists. Each feature requires working workflows, server-side validation, persistence, permissions, tests, and documentation.


## Phase 7 — Authentication and session security design
- Document CEO identity proofing, OIDC/PKCE sign-in, MFA, recovery and session lifecycle.
- Identify schema gaps in migration 0005 and define a proposed additive authentication migration.
- Define CSRF, CORS, cookie, rate-limit, audit and security acceptance requirements.
- Keep provider selection and implementation pending CEO review.
- No credentials, live migration, deployment or production changes are part of this design phase.
