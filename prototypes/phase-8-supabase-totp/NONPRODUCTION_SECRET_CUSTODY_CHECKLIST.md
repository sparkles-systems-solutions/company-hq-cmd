# Non-production Secret Custody — Evidence Checklist

**Status: Design and evidence checklist only. No secret or credential is present in this repository.**

This checklist applies only after the CEO separately approves a specifically named non-production Supabase project and secret-handling scope.

## A. Before any secret is created
- [ ] CEO approval record names the project, region, owner, cost ceiling, expiry, and cleanup owner.
- [ ] Secret manager is named and approved.
- [ ] Primary and backup custodians are named; access is protected by MFA.
- [ ] Access is least-privilege and limited to approved operators.
- [ ] Access audit is enabled and a reviewer is assigned.
- [ ] Non-production values are unique; no production value is copied or reused.
- [ ] Worker deployment target and environment are explicitly identified and separately approved.
- [ ] A documented reason exists for every requested secret; avoid service-role keys unless strictly required and separately approved.

## B. Storage and handling controls
- [ ] Secrets are stored only in the approved secret manager or platform secret store.
- [ ] No secret is committed to Git, environment files, source, fixtures, workflow YAML, issue/PR comments, chat, screenshots, or documentation.
- [ ] Secrets are never placed in browser bundles, static frontend configuration, URLs, query strings, or client-side storage.
- [ ] Service-role and secret keys are never exposed to browser code.
- [ ] CI uses protected secret references only if CI use is separately approved; values are masked and never printed.
- [ ] Logs, traces, crash reports, and audit events are checked for password, OTP, recovery-code, and token leakage.
- [ ] Public project URL and publishable key remain environment-specific and are not authorization grants.

## C. Lifecycle and incident response
- [ ] Secret owner, purpose, creation date, and expiry are recorded without recording the value.
- [ ] Rotation interval and immediate-compromise procedure are documented.
- [ ] Revocation is tested in the approved non-production environment.
- [ ] Custodian access is reviewed and removed when no longer needed.
- [ ] At test expiry, secrets are revoked/deleted and project cleanup is evidenced.
- [ ] Suspected exposure triggers containment, revocation/rotation, incident recording, and scope review.

## D. Evidence register (no secret values)
| Evidence | Reference / location | Reviewer | Date | Result |
|---|---|---|---|---|
| CEO project approval |  |  |  | Pending |
| Secret manager approval |  |  |  | Pending |
| Custodian access + MFA |  |  |  | Pending |
| Access audit configuration |  |  |  | Pending |
| Environment separation |  |  |  | Pending |
| Rotation / revocation test |  |  |  | Pending |
| Expiry and cleanup evidence |  |  |  | Pending |

## E. Stop conditions
Stop if approval is ambiguous, a production connection is detected, a secret appears in Git or logs, a custodian is not approved, the cost ceiling is missing, or project expiry/cleanup is undefined.

This checklist does not authorize project creation, secret generation, provider configuration, Worker deployment, remote D1 writes, real-user activation, CMD session exchange, PR merge, or production deployment.
