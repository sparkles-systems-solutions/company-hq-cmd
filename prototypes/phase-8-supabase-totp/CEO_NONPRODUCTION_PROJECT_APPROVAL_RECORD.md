# CEO Approval Record — Isolated Non-production Supabase Project

**Status: NOT APPROVED / NOT CREATED**

This record captures a specific bounded authorization decision. Completing it does not itself create a project.

## 1. Requested project
- Project name (must include NON-PRODUCTION):
- Supabase organization/account owner:
- Approved region:
- Intended test purpose:
- Test start date:
- Mandatory expiry date:
- Cleanup/deletion owner:
- Synthetic test identity owner:

## 2. Cost and service boundary
- Maximum spend / billing ceiling:
- Billing alert threshold:
- Approved test SMTP provider and sender:
- Exact allowed redirect and callback/logout origins:
- Production origins explicitly excluded:
- Production databases, Workers, and identity providers excluded: YES / NO

## 3. Secret custody
- Approved secret manager:
- Named primary custodian:
- Named backup custodian:
- MFA required for custodians: YES / NO
- Access audit enabled: YES / NO
- Rotation/revocation owner:

Never write secret values, API keys, passwords, recovery codes, service-role keys, or tokens in this record, GitHub, chat, or source files.

## 4. Explicitly permitted actions
- [ ] Create exactly the named non-production Supabase project.
- [ ] Configure Email + Password and verified-email requirement.
- [ ] Disable public self-registration.
- [ ] Configure only the exact approved redirect origins.
- [ ] Configure approved test-only SMTP delivery.
- [ ] Configure TOTP for synthetic test identities.
- [ ] Store required non-production secrets in the named secret manager.
- [ ] Run synthetic end-to-end provider authentication tests.
- [ ] Delete the project at the stated expiry.

Anything not checked remains prohibited. This does not authorize Worker deployment, remote D1 provisioning/writes, CMD session exchange/cookie issuance, real-user activation, staging, PR merge, or production deployment.

## 5. CEO decision
Decision: APPROVED / REJECTED / RETURN FOR CHANGES
Approved project name:
Approved owner and region:
Approved cost ceiling:
Approved expiry and cleanup date:
Approved custodians and secret manager:
Approved actions:
Conditions / restrictions:
CEO authorization through approved company process:
Decision date:
Review / expiry date:

**Approval rule:** A generic go-ahead for prototype design is not sufficient. Approval must explicitly authorize creation of this named non-production project and its bounded configuration.
