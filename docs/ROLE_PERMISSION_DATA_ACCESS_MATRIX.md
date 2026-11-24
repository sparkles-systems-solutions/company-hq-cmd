# CMD Role Permission & Data Access Matrix

**Company:** Sparkles Systems & Solutions  
**Phase:** 2 — Role Permission & Data Access Matrix  
**Version:** 1.0  
**Date:** 2026-11-24  
**Status:** Proposed policy; not yet implemented or enforced in a live API

## 1. Purpose and governing rules

This matrix defines the intended access boundary for the Central Management Dashboard (CMD). The Founder / CEO is the company's only human member. All other listed positions are virtual AI roles, not human employees or independent autonomous agents.

**This document grants no live access.** It is a design specification for implementation and testing. All 41 virtual member records remain pending until the system is deployed, access controls are implemented, and the CEO explicitly authorizes activation.

Mandatory rules:

1. Deny by default. No role receives access merely because it exists in the role catalogue.
2. The Worker API is the authorization boundary. Frontend visibility is never a security control.
3. Every request must authenticate the actor (except a deliberately scoped, token-based read-only dashboard share) and authorize action + resource + scope.
4. Virtual AI roles may prepare drafts, recommendations, and proposed changes. They cannot independently approve, publish, execute, spend, sign, or perform destructive actions.
5. The CEO is the sole company approval authority in this single-human organization. Legal and other regulated matters still require qualified external human professionals where applicable.
6. Read access must be limited to the minimum project, department, or record scope needed for the task.
7. No production credentials, unrestricted administrator tokens, bank access, patient data, or third-party system secrets are to be exposed to virtual roles.
8. Privileged actions require explicit CEO approval, step-up authentication/MFA, a reason, and an audit event.
9. Approval is a recorded decision; it does not automatically execute the approved action. Execution is a separate, controlled step.
10. Any role or access grant can be suspended or revoked by the CEO.

## 2. Permission vocabulary

| Code | Permission | Meaning |
|---|---|---|
| N | No access | No visibility or action |
| R | Read | View permitted records within assigned scope |
| D | Draft | Prepare a draft or recommendation; not committed as authoritative |
| P | Propose | Submit a change/request for review and approval |
| T | Test | Execute permitted tests in an isolated test environment and record evidence |
| A | Approve | Record a formal approval decision; reserved to CEO |
| X | Execute | Perform an external, financial, production, destructive, or irreversible action |

**Default for all virtual roles:** R/D/P/T only where explicitly listed and only after activation; never A or X.  
**CEO:** A and X only with strong authentication, confirmation, audit trail, and safety gates.

## 3. CMD module definitions

- **EXEC:** CEO overview, executive reports, decision and approval queue.
- **HR:** department, role, virtual member and onboarding records; no real human employee records in this model.
- **PMO:** projects, milestones, tasks, dependencies and risks.
- **QA:** test cases, test evidence, defects and release quality gates.
- **FIN:** budgets, cost estimates and financial reports.
- **OPS:** operational runbooks, service issues and support workflows.
- **SEC:** access reviews, security findings, privacy risks and audit events.
- **DOC:** document metadata, approved policies, knowledge base and drafts.
- **REL:** release plans, change records, deployment readiness and rollback plans.
- **SHARE:** token-based no-login dashboard shares; management of share tokens is CEO-only.

## 4. CEO permission profile

The Founder / CEO (only human member) has company-wide visibility and final approval authority. CEO permissions are subject to MFA/step-up authentication, audit logging, explicit confirmation, and safety gates.

| Module | CEO |
|---|---|
| EXEC | R, A |
| HR | R, D, P, A, X |
| PMO | R, D, P, A, X |
| QA | R, D, P, A, X |
| FIN | R, D, P, A, X |
| OPS | R, D, P, A, X |
| SEC | R, D, P, A, X |
| DOC | R, D, P, A, X |
| REL | R, D, P, A, X |
| SHARE | R, D, P, A, X |

CEO execution remains subject to backups, rollback plans, environment separation, legal/professional review, and applicable external platform controls.

## 5. Virtual role access matrix

All entries below are proposed maximum capabilities after individual activation. An omitted module means N — No access. R/D/P/T are scoped to assigned work and approved data. No virtual role has A or X.

| # | Virtual role | Allowed modules | Maximum allowed actions | Explicit exclusions |
|---:|---|---|---|---|
| 1 | General Manager (GM) | EXEC, PMO, OPS, DOC | R, D, P | No approvals, finance execution, hiring, production changes |
| 2 | Chief Operating Officer (COO) | EXEC, PMO, OPS, QA, DOC | R, D, P | No approval authority or real-world operational execution |
| 3 | Chief Technology Officer (CTO) | EXEC, PMO, QA, SEC, DOC, REL | R, D, P, T | No production deployment, secrets, destructive DB or infrastructure actions |
| 4 | Chief Financial Officer (CFO) | EXEC, FIN, PMO, DOC | R, D, P | No bank access, payment, transfer, spending, financial approval or accounting certification |
| 5 | HR Manager | HR, DOC, EXEC | R, D, P | No human hiring/employment decisions, payroll, disciplinary action or sensitive personal data |
| 6 | Recruitment & Organization Coordinator | HR, DOC | R, D, P | No human recruitment or employment action |
| 7 | Head of PMO / Project Manager | PMO, EXEC, QA, DOC, REL | R, D, P | Cannot approve scope/budget or production release |
| 8 | Business Analyst | PMO, DOC, QA | R, D, P | No approval or direct production data changes |
| 9 | Project Coordinator | PMO, DOC, OPS | R, D, P | No approval, external commitments or destructive action |
| 10 | Solution Architect | PMO, QA, SEC, DOC, REL | R, D, P, T | No production architecture changes or secret access |
| 11 | Lead Developer / Engineering Lead | PMO, QA, DOC, REL | R, D, P, T | No self-approval of QA/release, production deploy or secret access |
| 12 | Backend Developer 01 | PMO, QA, DOC | R, D, P, T | No production DB write, secrets, deployment or approval |
| 13 | Backend Developer 02 | PMO, QA, DOC | R, D, P, T | No production DB write, secrets, deployment or approval |
| 14 | Frontend Developer 01 | PMO, QA, DOC | R, D, P, T | No production release or privileged user/session access |
| 15 | Frontend Developer 02 | PMO, QA, DOC | R, D, P, T | No production release or privileged user/session access |
| 16 | Mobile Application Developer | PMO, QA, DOC, REL | R, D, P, T | No signing-key access, production publish or approval |
| 17 | Database Engineer | PMO, QA, SEC, DOC | R, D, P, T | No production data mutation, schema migration execution, backup deletion or secret access |
| 18 | DevOps Engineer | PMO, QA, SEC, DOC, REL | R, D, P, T | No production deployment, credential rotation or infrastructure mutation |
| 19 | Cloud Engineer | PMO, SEC, DOC, REL, FIN | R, D, P, T | No cloud account admin, paid resource provisioning or production changes |
| 20 | UI/UX Designer | PMO, QA, DOC | R, D, P, T | No access to confidential customer records or production admin |
| 21 | Head of ICT / Network Engineer | OPS, SEC, DOC, PMO | R, D, P, T | No live network config, firewall, VPN or switch changes |
| 22 | Systems & Infrastructure Engineer | OPS, SEC, DOC, PMO | R, D, P, T | No server admin, production changes, credential or backup deletion |
| 23 | Head of Product | EXEC, PMO, QA, DOC | R, D, P | No business strategy approval or commercial commitment |
| 24 | Product Analyst | PMO, QA, DOC, EXEC | R, D, P | No unrestricted customer analytics or sensitive data export |
| 25 | Head of QA / QA Manager | QA, PMO, REL, DOC, SEC | R, D, P, T | Cannot approve own test evidence as final company acceptance; no production deploy |
| 26 | QA Engineer 01 | QA, PMO, DOC | R, D, P, T | Test environment only; no production data or code deployment |
| 27 | QA Engineer 02 | QA, PMO, DOC | R, D, P, T | Test environment only; no production data or code deployment |
| 28 | UAT 01 — Functional Testing | QA, PMO, DOC | R, D, P, T | Can prepare and record test evidence; cannot provide human business sign-off |
| 29 | UAT 02 — Integration Testing | QA, PMO, DOC, OPS | R, D, P, T | Test integrations only; no production credentials or real patient/customer data |
| 30 | UAT 03 — Regression & Acceptance | QA, PMO, REL, DOC | R, D, P, T | No final human acceptance or release approval |
| 31 | Head of Cybersecurity / Security Engineer | SEC, OPS, PMO, DOC, QA | R, D, P, T | No autonomous blocking, account changes, exploit execution or production security changes |
| 32 | Security & Privacy Analyst | SEC, DOC, PMO | R, D, P | No access to raw sensitive personal data unless separately approved and strictly necessary |
| 33 | Risk & Compliance Coordinator | SEC, DOC, PMO, EXEC | R, D, P | Cannot certify compliance or provide binding legal/regulatory opinion |
| 34 | Virtual AI Legal Advisor | DOC, SEC, PMO, EXEC | R, D, P | No legal representation, signing, binding opinion, privileged legal files or external notice without CEO/lawyer review |
| 35 | Release Manager | REL, QA, PMO, DOC, OPS | R, D, P, T | No production deployment or release approval |
| 36 | Operations Coordinator | OPS, PMO, DOC | R, D, P | No real-world execution, external commitments or production system changes |
| 37 | Support Manager | OPS, QA, DOC, PMO | R, D, P | No refunds, contractual promises, customer account takeover or privileged access |
| 38 | Application Support Specialist | OPS, QA, DOC | R, D, P, T | Approved test/sanitized logs only; no production account changes or secret access |
| 39 | Customer Support Specialist | OPS, DOC | R, D, P | No access to payment details, sensitive customer records, refunds or contractual commitments |
| 40 | Technical Writer / Documentation Officer | DOC, PMO, QA, REL | R, D, P | Cannot publish policy/contract/release notices without owner approval |
| 41 | Knowledge Base Coordinator | DOC, OPS, QA | R, D, P | No access to restricted documents or independent publication of controlled policies |

## 6. Approval and separation-of-duties rules

| Action | Preparer | Reviewer | Final approver | Executor |
|---|---|---|---|---|
| Project plan / milestone | PMO / BA | GM or COO | CEO for material scope changes | Authorized workflow after approval |
| Budget request | CFO / PMO | CEO reviews supporting evidence | CEO | CEO-authorized human action; no AI payment execution |
| Code change | Developer | Lead Developer / CTO | CEO for production-sensitive change | Authorized deployment process only |
| QA test plan/results | QA roles | QA Manager / independent reviewer | CEO for acceptance gate where required | Test runner in isolated environment |
| Security-sensitive change | Security / CTO | Independent security review | CEO | Authorized human operator after approval |
| Production database migration | Database Engineer drafts | CTO + QA + backup/rollback review | CEO | Authorized human operator only |
| Legal agreement / notice | Virtual AI Legal Advisor drafts | Qualified human lawyer where required | CEO | CEO or duly authorized human signatory |
| Release | Release Manager prepares | QA + CTO | CEO | Controlled deployment pipeline after approval |
| Dashboard share token | Requesting role may propose | CEO reviews scope and expiry | CEO | System issues token after CEO authorization |

No virtual AI role can approve its own request. The preparer cannot be treated as an independent approver. Where a role is assigned multiple duties, the CEO must provide the independent review.

## 7. Sensitive data classification

| Class | Examples | Virtual role access |
|---|---|---|
| Public | Public product descriptions, public docs | R if relevant |
| Internal | Project plans, non-sensitive tasks, internal SOPs | Scoped R/D/P |
| Confidential | Budgets, vendor terms, unreleased plans, security findings | Need-to-know, sanitized summaries by default; explicit CEO-approved scope |
| Restricted | Passwords, API tokens, private keys, bank credentials, patient data, identity documents, raw sensitive personal data | N by default; never place secrets in prompts, GitHub, or public CMD frontend |

The CMD should not contain hospital/patient data or customer production data unless a separately approved legal, security, privacy, retention, and access-control design exists.

## 8. Secure no-login dashboard share

A dashboard share link is a narrow exception to user login, not an authentication bypass.

Required design:
- CEO creates and approves the share; token is generated server-side using cryptographically secure randomness.
- Store only a hash of the token; show the raw token once at creation.
- Token grants read-only access to one dashboard and explicitly enumerated fields/filters only.
- No access to navigation into other modules, search across the tenant, export, mutations, comments, or attachments unless separately approved.
- Require an expiry; short default lifetime (recommended maximum 7 days for initial release).
- Support immediate revocation and rotation.
- Apply rate limits, Cache-Control: no-store, Referrer-Policy: no-referrer, and avoid third-party analytics/scripts on share pages.
- Where feasible, restrict by internal network/VPN or approved IP ranges; do not rely on IP restrictions as the only control.
- Log token creation, use, failed attempts, expiry, and revocation without logging the raw token.
- Do not expose patient, employee-sensitive, financial-account, or restricted security data through no-login links.
- Share links must be unguessable, non-indexable, excluded from sitemaps, and protected against referrer leakage.
- If any requirement cannot be enforced, disable no-login sharing until fixed.

## 9. Minimum API enforcement requirements

Every protected API request must:
1. Validate session/token cryptographically and check expiry/revocation.
2. Resolve actor identity and current active role assignments from the server-side database.
3. Check module permission, action, record scope, and project/department ownership.
4. Enforce field-level filtering for confidential data.
5. Enforce approval state for sensitive actions; approval must match exact resource, action, environment, and expiry.
6. Reject virtual actors attempting A or X.
7. Reject stale, suspended, expired, or unassigned roles.
8. Write an append-only audit event for access denials and sensitive reads/writes.
9. Use parameterized SQL and validate all inputs.
10. Return minimal error details; never leak secrets or internal stack traces.

Example policy decision (illustrative only): actor_type=virtual; role_id=role-project-manager; module=PMO; action=draft; project scope=project-demo-001; decision=allow. This is not an implemented API contract.

## 10. Activation checklist

A virtual role remains **Pending** until all applicable items are completed and evidenced:

- [ ] Role owner and reporting line confirmed
- [ ] Exact module and record scope approved
- [ ] Data classification and prohibited-data rules reviewed
- [ ] Read-only access tested first
- [ ] Draft/proposal workflow tested in staging
- [ ] Approval separation and deny tests passed
- [ ] Audit events verified
- [ ] Revocation/suspension tested
- [ ] CEO activation approval recorded
- [ ] CMD API enforcement independently reviewed

The role must remain inactive if any mandatory test fails. Do not activate all roles merely because the migration seeds their records.

## 11. Current status

- This matrix is a proposed authorization policy document.
- It has not been implemented in Cloudflare Workers or D1.
- No real credentials or permissions have been issued.
- No virtual AI role is currently verified as operationally active in a live CMD.
- The 41 virtual roster entries remain pending.
- The PR remains subject to review; this document does not authorize merge, deployment, or live data migration.

## 12. Next implementation phase

**Phase 3 — Authorization Model & API Enforcement Design**

Translate this matrix into a normalized permission catalogue, role-to-permission assignments, resource-scope rules, approval checks, share-token lifecycle, and deny-by-default Worker middleware. Build automated allow/deny tests before connecting live systems.
