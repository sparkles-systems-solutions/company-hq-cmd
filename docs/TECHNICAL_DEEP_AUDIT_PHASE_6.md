# Technical Deep Audit & Failure Investigation — Phase 6

**Company:** Sparkles Systems & Solutions  
**Phase:** 6 — Technical Deep Audit & Failure Investigation  
**Review date:** 2026-11-25  
**Status:** Source/log review completed for priority findings; no product code changed  
**Scope:** MeetMind deployment failure, Lanka Map Phase 1 UAT failures, and focused source-level risk reviews of VELORA, Advance Meter Taxi and Lingua AI English Academy.

## 1. Executive summary

Phase 6 moved beyond the workflow status labels and inspected the actual failed GitHub Actions job steps/logs and the corresponding source code.

### Confirmed findings

1. **MeetMind API deployment is intentionally blocked by an unconfigured D1 database ID.** The current `api/wrangler.toml` still contains `REPLACE_WITH_CLOUDFLARE_D1_DATABASE_ID`. The deployment workflow exits at configuration validation before D1 migrations, Worker secret configuration or deployment. The log also shows the four required GitHub Actions secret environment variables were empty in that run. No secret values were disclosed.
2. **Lanka Map GPS UAT has a test-fixture/product-contract mismatch.** The test waits for exactly one GPS point and then expects Stop to trigger a GeoJSON download. The application only auto-downloads a LineString when at least two GPS points exist. The test sets the same fixed GPS coordinate for the entire recording, and the application intentionally ignores samples less than 5 metres from the previous point. Thus the test cannot produce the second distinct point needed for the download. The two desktop/mobile variants fail at the same assertion; the other six tests passed.
3. **VELORA has a critical source-level API authorization gap.** `src/worker.js` imports and invokes `handleAuth`, but then proceeds to patient, admission, bed, package, LIS, pharmacy, nursing and other business routes without calling the exported `requireAuth` guard. The auth test explicitly confirms that non-auth routes are not intercepted by `handleAuth`. On the inspected source, the business APIs therefore lack a visible server-side authentication/role gate. This must be treated as a release blocker until verified and corrected in a dedicated security change.
4. **Advance Meter Taxi allows an administrator to delete the entire audit history.** The source exposes `DELETE /api/admin/audit`, and the test suite explicitly expects audit rows to be purged. This conflicts with the purpose of a reliable, tamper-evident audit trail and needs a policy decision and redesign before production.
5. **Lingua UAT success is limited to the workflow's automated checks.** The workflow runs Node tests, SQLite migration tests and syntax checks. It does not deploy or verify real D1, email delivery, actual OTP lifecycle, production secrets, mobile device behavior or the full learner/admin journey. The acceptance checklist contains many separate staging and manual UAT criteria.

These are source/log findings, not proof that any production system has been compromised or that live data was accessed. No production endpoints, databases or secrets were accessed.

## 2. MeetMind — deployment failure root cause

### Run examined

- Repository: `meetmind-ai-live-test`
- Workflow: `Deploy MeetMind API`
- Run: `44757416974`
- Commit: `b7bfcd25c2f57c3a70354d317b861c0031d29ccf`
- Run date: 2026-11-20
- Job: `deploy`
- Job ID: `136360691955`

### What passed

- Checkout
- Node.js setup
- Wrangler installation
- Worker JavaScript syntax validation
- Client JavaScript syntax validation

### Exact blocking condition

The workflow checks whether `api/wrangler.toml` still contains the placeholder D1 database ID. The file currently contains:

```toml
database_name = "meetmind-ai-db"
database_id = "REPLACE_WITH_CLOUDFLARE_D1_DATABASE_ID"
migrations_dir = "migrations"
```

The validation step reports:

```
Set the D1 database_id in api/wrangler.toml before deployment.
Process completed with exit code 1.
```

The job log also shows empty environment values for:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `JWT_SECRET`
- `BOOTSTRAP_SECRET`

Because the placeholder check fails first, the workflow does not reach the explicit missing-secret checks. D1 migrations, Worker secret configuration and Worker deployment were skipped.

### Root-cause classification

- **Primary blocker:** Cloudflare D1 database ID is not configured.
- **Additional deployment prerequisites:** the four required GitHub Actions secrets were empty in this run.
- **Not a code syntax failure:** both JavaScript syntax checks passed.
- **Not a D1 migration failure:** migration step was skipped, not attempted.
- **Not a Worker runtime failure:** deploy step was skipped, not attempted.

### Safe remediation plan

1. Keep the current fail-closed deployment guard.
2. Confirm the intended Cloudflare account/project and whether a D1 database already exists.
3. CEO must separately approve creation/use of a Cloudflare D1 database and any remote migration.
4. Only after explicit approval, a designated human administrator should configure the database ID and required GitHub Actions secrets in the correct private settings.
5. Review token scopes and secret handling; never place token/secret values in repository files, logs or this report.
6. Run schema validation against a disposable local SQLite database first, then plan remote staging migration as a separately approved operation.
7. Verify health, login, ownership isolation, admin authorization and recovery behavior in staging before considering production.

**No D1 database was created, no secret was added, and no deployment was retried in this phase.**

## 3. Lanka Map — Phase 1 UAT failure root cause

### Run examined

- Repository: `lanka-map`
- Workflow: `Phase 1 UAT`
- Latest examined run: `42078684805`
- Commit: `73bcd00502abf53929ac4220b334340d32b3f77e`
- Branch: `phase-1/core-platform-foundation`
- Job: `browser-uat`
- Job ID: `127425643761`

### Test results

- 6 tests passed.
- 2 tests failed: GPS recording test on Chromium desktop and Chromium mobile.
- Both failures were in `tests/phase-1-smoke.spec.ts` at the download-event wait.
- The workflow uploaded the Playwright report, screenshots, video and trace artifacts.

### Source-level mismatch

The test:
1. Grants geolocation permission.
2. Sets one fixed coordinate: latitude 6.9271, longitude 79.8612, accuracy 8.
3. Starts recording.
4. Waits until the UI reports `GPS points: 1`.
5. Immediately waits for a download event and clicks Stop.

The application:
- Filters GPS samples with accuracy worse than 35 metres.
- Ignores a new point if it is less than 5 metres from the previous point.
- Exports a GeoJSON LineString only when `track.length >= 2`.
- If fewer than two points exist, Stop ends recording but does not automatically download a GeoJSON file.

The test supplies no second, distinct coordinate. It therefore waits for a download event that the application is not required to trigger with only one point.

### Root-cause classification

- **Confirmed:** test expects a download after one point, while the implementation only downloads after at least two points.
- **Confirmed:** fixed geolocation does not simulate movement; duplicate/near-identical samples are intentionally filtered.
- **Not evidence of:** broken GPS permission handling, broken map rendering or a real-device GPS failure.
- **Not yet verified:** whether the stop/download behavior is correct on physical devices.

### Recommended remediation

Preferred correction is to make the UAT simulate a real short route:
1. Start with the first test coordinate.
2. Wait for the first valid point.
3. Change the Playwright geolocation to a second coordinate more than 5 metres away.
4. Wait until the UI reports at least two points.
5. Click Stop and assert the GeoJSON download and filename.
6. Also test the explicit Download GPS track button after a stopped recording.
7. Add a separate negative test confirming that a one-point track does not produce an invalid LineString download.

Do not weaken the application's two-point LineString validation merely to make the existing test pass. If product requirements want one-point exports, define a valid Point/FeatureCollection contract separately.

**No product code or test was modified and no workflow was rerun in this phase.**

## 4. VELORA HealthOS — critical API authorization finding

### Files reviewed

- `src/worker.js`
- `src/auth.js`
- `tests/auth.test.js`
- `tests/api-smoke.test.js`
- `wrangler.jsonc`
- Migration directory listing
- `docs/BUILD-ACCEPTANCE.md`
- `.github/workflows/api-checks.yml`

### Evidence

- `src/auth.js` exports `requireAuth(request, env, roles)`.
- `src/worker.js` imports only `handleAuth`.
- The Worker calls `handleAuth` and, when it returns null, continues processing business routes.
- The auth test explicitly expects `handleAuth` to return null for a non-auth route such as `/api/patients`.
- The inspected Worker business handlers then process routes such as patient registration/listing, admission requests, clearance, bed allocation, packages, LIS, pharmacy and nursing without an evident `requireAuth` check.

### Risk

Patient and operational business APIs may be callable without authenticated identity or role authorization at the Worker layer. This is a critical security blocker for any environment containing real patient or hospital data.

This is a source-level finding. It does not prove that the current deployment is reachable, that real patient data exists in D1, or that anyone accessed it.

### Required remediation design

1. Define a route-to-role authorization matrix from approved hospital roles and workflows.
2. Add a centralized route guard before any business API handler; deny by default.
3. Require an authenticated active user for all business endpoints.
4. Enforce role and permission scope server-side for read and write operations.
5. Ensure sensitive patient data endpoints have explicit permissions and audit events.
6. Keep public health/preflight endpoints narrowly allowlisted.
7. Remove or permanently disable any demo/bootstrap/seed routes that could mutate production data.
8. Add negative tests for every route family: anonymous request, invalid session, insufficient role, allowed role, and cross-patient/encounter access.
9. Add regression tests confirming auth endpoints still work and no public route bypasses the guard.
10. Do not deploy or use real patient data until the security gate passes.

**Priority: Critical / release blocker.** No source fix or deployment was performed because this phase is an audit/report, and production authorization changes require a separate reviewed implementation.

## 5. Advance Meter Taxi — audit integrity finding

### Files reviewed

- `server/server.mjs`
- `test/security.test.mjs`
- `docs/SECURITY.md`
- `docs/DEPLOYMENT.md`
- `docs/QA-MOBILE.md`
- `docs/FIELD-QA-CHECKLIST.md`
- `.github/workflows/application-qa.yml`

### Evidence

- `GET /api/admin/audit` is admin-only.
- `DELETE /api/admin/audit` is also admin-only, but deletes all audit rows and then inserts a new `audit_purged` event.
- The security test explicitly expects this purge operation to succeed.
- The security/deployment documentation describes audit events as an operational security control.

### Risk

An administrator can erase prior audit evidence. The new `audit_purged` event records that a purge occurred, but it cannot reconstruct the deleted events or establish what they contained. This is not a tamper-evident audit design.

### Recommended remediation

1. Decide the approved audit retention and archival policy.
2. Remove ordinary application-level audit deletion.
3. Use append-only audit records with restricted database permissions.
4. If retention expiry is legally/operationally required, use a separately authorized archival/retention process with immutable export and verifiable checksums.
5. Record privileged administrative actions without allowing the same actor to erase their history.
6. Update the security test: a driver must be denied, an admin must be denied ordinary purge, and audit records must remain available after normal admin operations.
7. Keep database backup and audit retention as separate controls.

**Priority: High.** No product code was changed.

## 6. Lingua AI English Academy — UAT coverage and readiness review

### Files reviewed

- `README.md`
- `backend/src/index.js`
- `tests/ACCEPTANCE_CHECKLIST.md`
- `docs/REPOSITORY_AUDIT.md`
- `.github/workflows/uat.yml`

### What the UAT workflow actually checks

- Node test files under `tests/*.test.js`
- SQL migration execution and constraints using Python SQLite
- Learner inline JavaScript syntax
- Auth client JavaScript syntax

The latest observed main workflow success was associated with commit `fee11a6904` on 2026-11-03.

### What that does not establish

- Real Cloudflare D1 migration success or production database binding.
- Real Resend email delivery and sender-domain verification.
- Full learner OTP lifecycle on a deployed Worker.
- Admin password + TOTP and passwordless OTP end-to-end behavior in a deployed environment.
- Actual learner progress sync across separate devices.
- Android APK build, installation and device acceptance.
- AI tutor or Sinhala speech recognition quality.
- Production monitoring, data export/deletion and operational recovery.

### Source-level observations

- Backend OTP code has rate-limit, expiry, attempt-count and hashed challenge/session primitives.
- Email sending requires `RESEND_API_KEY` and `EMAIL_FROM`; these are runtime prerequisites, not proven by local UAT.
- The acceptance checklist explicitly calls for real D1 staging, email delivery, session security, cross-account isolation, data export/deletion, Android visual UAT and Sinhala reviewer checks.
- The repository audit is an older historical document and should not be treated as a current complete inventory without reconciliation against later commits.

### Recommended next validation

Create a controlled non-production acceptance runbook covering learner OTP, admin login methods, role boundaries, progress sync, email failures, session expiry/revocation, dictionary moderation, export/deletion and mobile viewport checks. Use synthetic accounts and test content only.

**Priority: Medium / readiness evidence gap.** No real email, D1 or account setup was performed.

## 7. Cross-project remediation register

| ID | Project | Finding | Priority | Next action | Change authority |
|---|---|---|---|---|---|
| AUD-01 | VELORA | Business API handlers lack visible centralized auth/role gate | Critical | Design route guard and authorization matrix; add negative tests | CEO approval before implementation/deployment |
| AUD-02 | MeetMind | D1 database ID placeholder blocks deploy; required secrets empty in observed run | High | Confirm Cloudflare project and approved staging prerequisites | Separate CEO approval for D1/secrets/remote migration |
| AUD-03 | Lanka Map | GPS UAT waits for download after only one fixed point | High | Fix Playwright fixture to simulate two distinct points | Isolated test-only PR can be proposed; no deploy |
| AUD-04 | Advance Meter Taxi | Admin can purge entire audit history | High | Replace purge with append-only/retention design and revise tests | Separate reviewed code change |
| AUD-05 | Lingua | CI does not prove real D1/email/auth/mobile acceptance | Medium | Build synthetic staging acceptance evidence | CEO approval before staging resources |
| AUD-06 | VELORA | Need endpoint-by-endpoint authorization tests | Critical | Test anonymous/role/ownership denials for every business route | Before any real data use |
| AUD-07 | Taxi | Physical-device GPS/printing/mobile acceptance remains outstanding | High | Complete supervised field checklist on staging | Human tester / CEO sign-off |

## 8. Safe next steps

The next safe work can continue as documentation and isolated source/test review:
1. Prepare a VELORA API authorization matrix and route inventory.
2. Prepare a Lanka Map test-only correction proposal, without modifying the product branch.
3. Prepare a MeetMind deployment prerequisite checklist, leaving D1/secrets/deployment gated.
4. Prepare a Taxi append-only audit redesign proposal.
5. Prepare a Lingua synthetic staging UAT checklist.

No production deployments, remote D1 changes, secret configuration, live account creation, patient-data access, audit deletion, product repository modifications or PR merges were performed in Phase 6.
