# Workflow and approvals

## Standard work item

1. A team member creates a task with project, owner, priority, due date, and acceptance criteria.
2. The responsible lead reviews scope and dependencies.
3. Work is implemented in a feature branch.
4. QA records test cases, results, and defects.
5. UAT records functional, integration, regression, and acceptance outcomes as applicable.
6. Release Manager prepares release notes and a rollback plan.
7. Required approvals are collected.
8. Deployment occurs only after authorized approval.
9. Post-release checks and audit records are completed.

## CEO approval gates

Explicit CEO approval is required for financial commitments, real hiring, production releases, production database changes, security-sensitive changes, destructive/irreversible actions, and major business decisions.

A recorded approval must include requester, approver, decision, timestamp, scope, and rationale. An approval record does not itself execute a production action.
