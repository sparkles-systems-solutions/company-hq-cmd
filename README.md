# Company HQ CMD

Central Management Dashboard for Sparkles Systems Solutions.

## Repository status

This repository is **public by CEO decision**. It contains source code, technical documentation, and synthetic development fixtures only. Never commit customer data, employee personal data, credentials, API tokens, private keys, production exports, or confidential financial records.

## Product direction

Company HQ CMD is the internal operating platform for the AI + Human Hybrid Team. It will provide:

- CEO executive overview and approval queue
- Organization, departments, roles, and role assignments (CEO is the only human member; all other roles are virtual AI members)
- Project portfolio, milestones, tasks, risks, and dependencies
- QA, UAT, defects, release readiness, and audit history
- Budget requests and management reporting
- Document metadata and operational notifications

## Target architecture

- Frontend: static web application hosted on GitHub Pages
- API: Cloudflare Workers
- Database: Cloudflare D1
- Source control and delivery: GitHub
- Authentication: server-side sessions, role-based access control, and MFA for privileged accounts

GitHub Pages is only the public frontend host. It must never contain secrets or directly access a production database.

## Governance

The CEO is the final authority. Financial commitments, real hiring, production releases, production data changes, security-sensitive changes, and destructive actions require explicit CEO approval. AI role labels represent virtual assistance, not human employment or autonomous authority.

## Delivery status

Phase 0 foundation is being prepared on `foundation/phase-0`. This is not yet a deployed or production-ready system. No live authentication, API, D1 database, or production workflow is claimed until implemented and tested.

## Security design documents

- [Roles and permissions](docs/ROLES_AND_PERMISSIONS.md)
- [CMD role permission and data access matrix](docs/ROLE_PERMISSION_DATA_ACCESS_MATRIX.md)
- [Authorization model and API enforcement design](docs/AUTHORIZATION_MODEL_API_ENFORCEMENT.md)
- [Phase 4 authorization schema and migration validation](docs/PHASE4_MIGRATION_VALIDATION.md)
- [Phase 5 Worker authorization foundation](docs/PHASE5_WORKER_AUTHORIZATION.md)
- [Worker source and local test instructions](worker/README.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Workflow and approvals](docs/WORKFLOW.md)

## Organization and governance documents

- [Virtual AI Legal Advisor role profile](docs/LEGAL_ADVISOR_ROLE.md)
- [Company HR and virtual AI recruitment register](docs/HR_ORGANIZATION_RECRUITMENT_REGISTER.md)
- [Virtual AI capability assessment](docs/VIRTUAL_AI_CAPABILITY_ASSESSMENT.md)
- [Roadmap](docs/ROADMAP.md)

## Database migrations (draft source)

- [Initial database schema](migrations/0001_initial.sql)
- [Virtual AI Legal Advisor seed migration](migrations/0002_virtual_legal_advisor.sql)
- [Virtual AI role catalogue migration](migrations/0003_virtual_ai_role_catalogue.sql)
- [Virtual AI member onboarding migration](migrations/0004_virtual_ai_member_onboarding.sql)
- [Authorization schema migration draft](migrations/0005_authorization_schema.sql)

All migrations are source files only until reviewed and applied to a designated test database. No live D1 activation is claimed. The Worker authorization scaffold is not deployed; it exposes only health and authenticated identity endpoints and has no business CRUD or execution routes.
