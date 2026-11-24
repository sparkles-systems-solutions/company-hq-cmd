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

See:
- [Architecture](docs/ARCHITECTURE.md)
- [Roles and permissions](docs/ROLES_AND_PERMISSIONS.md)
- [Virtual AI Legal Advisor role profile](docs/LEGAL_ADVISOR_ROLE.md)
- [Company HR and virtual AI recruitment register](docs/HR_ORGANIZATION_RECRUITMENT_REGISTER.md)
- [Workflow and approvals](docs/WORKFLOW.md)
- [Roadmap](docs/ROADMAP.md)
- [Database migration](migrations/0001_initial.sql)
- [Virtual AI Legal Advisor seed migration](migrations/0002_virtual_legal_advisor.sql)
- [Virtual AI role catalogue migration](migrations/0003_virtual_ai_role_catalogue.sql)
