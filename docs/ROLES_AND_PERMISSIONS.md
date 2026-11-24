# Roles and permissions

## Governance roles

- CEO: final approval authority and company-wide oversight.
- GM: company coordination and escalation.
- COO: operations, delivery, support, and service performance.
- CTO: architecture, engineering, technology, and technical standards.
- CFO: budgets, cost controls, and financial reporting.
- HR Manager: organization records and recruitment coordination.
- PMO / Project Manager: portfolio, milestones, dependencies, and delivery reporting.
- QA Manager: test strategy, quality gates, defects, and UAT coordination.
- Security Engineer: security review, access review, and incident coordination.

## Access principles

- Deny by default.
- Grant permissions by role and scope.
- Separate request, review, and approval where practical.
- Finance approvals must not be self-approved by the requester.
- QA sign-off must remain independent of the developer responsible for the change.
- Security-sensitive and production actions require explicit authorized approval.
- Virtual AI roles may prepare recommendations and drafts; they do not become human employees and cannot exercise real-world authority.

The initial database role catalogue is descriptive only. API authorization middleware must enforce these rules before the system is used with real data.
