# Phase 8 — Non-production Supabase readiness and secret-handling plan

**Status: planning checklist only. No Supabase project, organization, account, credentials, secrets, real user, or TOTP factor has been created.** This document is not authorization to create or configure a provider project.

## 1. Purpose and isolation boundary

A future, separately approved Supabase project would be used only for non-production end-to-end authentication testing with synthetic identities and synthetic data. It must be isolated from production CMD, production data, and real user identities.

Required before project creation:
- CEO explicitly approves creating one named non-production Supabase project and its region.
- CEO approves the account/organization owner and billing boundary.
- CEO approves the exact secret manager and named custodians allowed to access secrets.
- Confirm the project is not linked to production databases, production email domains, production redirect origins, or production Workers.
- Define a short test window, cost limit, retention period, and project deletion/cleanup owner.

Until those approvals are recorded, do not create a project or request, generate, store, or transmit credentials.

## 2. Project configuration review (future UAT)

Record evidence in a controlled, non-public change record; never paste secrets into GitHub issues, pull requests, source files, logs, screenshots, or this document.

- [ ] Project region selected and approved; consider applicable data residency and legal requirements.
- [ ] Project name clearly marked NON-PRODUCTION; production project references prohibited.
- [ ] Email + Password enabled; public self-registration disabled for company use unless separately approved.
- [ ] Email confirmation required; unverified email identities cannot proceed.
- [ ] Redirect URLs restricted to exact approved non-production origins; no wildcard or production origin.
- [ ] TOTP is the required second factor; test enrollment/recovery policy documented and separately approved.
- [ ] Recovery codes and factor reset handled as sensitive recovery operations; password reset alone never bypasses TOTP.
- [ ] Email delivery uses an approved test SMTP/provider; avoid real customer or employee messages.
- [ ] Supabase session lifetime/refresh behavior documented against CMD policy: 30-minute idle, 12-hour absolute, 10-minute fresh-MFA. Supabase settings do not replace CMD enforcement.
- [ ] Auth logs and audit retention reviewed; no passwords, OTP values, recovery codes, access/refresh tokens, or raw CMD tokens in logs.
- [ ] JWKS endpoint and asymmetric signing algorithm confirmed; symmetric legacy signing is not accepted by the current prototype verifier.
- [ ] Project URL and publishable/anon key classified correctly; publishable key is not an authorization grant.
- [ ] Service-role/secret keys remain server-only and are not needed by the browser. Prefer not to provision one unless a documented server-side requirement is approved.

## 3. Secret-handling contract

If a future approved test requires secrets:
1. Store them only in the approved secret manager or platform secret store; never in Git, committed environment files, CI logs, issue comments, chat, or browser bundles.
2. Grant least-privilege access to named custodians; enable access audit and MFA.
3. Use separate values for each environment and purpose; never reuse production secrets.
4. Do not expose Supabase service-role/secret keys to the browser or static GitHub Pages frontend.
5. Worker runtime receives only minimum required configuration. Public project URL and publishable key are not secrets but must still be environment-specific.
6. Rotate immediately after suspected exposure; document revocation and recovery steps.
7. Remove temporary credentials and delete the test project at the end of the approved test window unless the CEO explicitly approves retention.

No actual secret values, secret names, credentials, project refs, or access tokens belong in this repository.

## 4. Minimum synthetic UAT plan

Use synthetic test identities only. A pre-provisioned CMD human fixture in a non-production database requires separate database approval. No real person or patient data.

- [ ] Confirm email/password sign-in and provider-confirmed email.
- [ ] Confirm unverified email is denied.
- [ ] Confirm AAL1 cannot access CMD and TOTP step-up reaches AAL2.
- [ ] Confirm password reset does not remove or bypass TOTP.
- [ ] Confirm factor recovery/reset requires a separate, audited recovery process.
- [ ] Confirm exact provider subject maps to one pre-provisioned active human; no email fallback or auto-provisioning.
- [ ] Confirm anonymous, inactive, virtual, unknown, and mismatched identities are denied.
- [ ] Confirm tokens are not stored in browser storage, logs, URLs, or application JSON.
- [ ] Confirm provider logout/revocation and factor changes follow an approved session invalidation policy.

This UAT plan does not implement or authorize CMD session exchange, cookie issuance, D1 writes, Worker deployment, or real user activation.

## 5. Approval record required before project creation

- [ ] CEO approval explicitly names the non-production Supabase project creation.
- [ ] Approved organization/account owner and project region.
- [ ] Approved billing/cost ceiling and test expiry date.
- [ ] Approved secret manager and custodians.
- [ ] Approved test redirect origin and email delivery method.
- [ ] Approved synthetic test identity owner.
- [ ] Approved cleanup/deletion plan.

A generic go-ahead for isolated prototype work does not satisfy these project-creation approvals.

## 6. Remaining separate gates

Even after an isolated Supabase project is approved, the following remain separately gated:
- CMD non-production remote D1 provisioning/writes and atomicity verification.
- Worker deployment to a non-production environment.
- Real provider sign-in/TOTP enrollment and synthetic user activation.
- Session exchange implementation, token/cookie issuance, CSRF/CORS wiring, and runtime lifecycle integration.
- PR merge, staging, and production deployment.

Production deployment, real user activation, live D1 changes, production credentials/configuration, and PR merge each require explicit separate CEO approval.
