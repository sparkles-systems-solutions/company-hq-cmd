# Phase 6 — Technical Audit Evidence Index

**Review date:** 2026-11-25  
**Scope:** Read-only source and GitHub Actions log inspection.

## GitHub Actions runs inspected

| Project | Workflow run | Job | Result |
|---|---:|---|---|
| MeetMind API | 44757416974 | 136360691955 | Failed at deployment configuration validation |
| Lanka Map Phase 1 UAT | 42078684805 | 127425643761 | 6 passed, 2 failed in GPS recording test |

Related earlier Lanka Map run 42078644243 showed the same job/test failure pattern.

## MeetMind evidence

- `api/wrangler.toml`: D1 database ID remains a placeholder.
- `.github/workflows/deploy-api.yml`: validates D1 ID and four required secrets before remote migrations, secret setup and deployment.
- `api/README.md`: lists D1 creation, migration and secret setup as deployment prerequisites.
- Job log: syntax checks passed; configuration validation failed; migrations, secrets and deployment were skipped.
- The log printed empty values for the names of the four expected secret environment variables. Secret values were not accessed or disclosed.

## Lanka Map evidence

- `tests/phase-1-smoke.spec.ts`: sets a single fixed geolocation point, waits for `GPS points: 1`, then expects a download after Stop.
- `index.html`: ignores samples within 5 metres and only calls the automatic GeoJSON download when at least two points exist.
- `playwright.config.ts`: executes the suite on Chromium desktop and Pixel 7 mobile projects.
- Job log: both desktop and mobile GPS test cases timed out waiting for download; six other tests passed.
- The workflow uploaded screenshots, video, trace and Playwright report artifacts.

## VELORA evidence

- `src/auth.js`: exports `requireAuth`; `handleAuth` handles authentication routes.
- `tests/auth.test.js`: verifies non-auth business routes are not intercepted by `handleAuth`.
- `src/worker.js`: imports `handleAuth` and then routes to patient/admission/bed/package/LIS/pharmacy/nursing business handlers without an evident call to `requireAuth`.
- `tests/api-smoke.test.js`: validation tests exist for selected API inputs but do not demonstrate role authorization for all business endpoints.

## Advance Meter Taxi evidence

- `server/server.mjs`: `DELETE /api/admin/audit` deletes all audit records and inserts `audit_purged`.
- `test/security.test.mjs`: explicitly tests and expects audit purge to succeed for admin.
- `docs/SECURITY.md`: describes audit events among implemented controls.

## Lingua evidence

- `.github/workflows/uat.yml`: Node tests, SQLite migration checks and JavaScript syntax checks.
- `backend/src/index.js`: OTP, rate limit, email-provider and session code paths.
- `tests/ACCEPTANCE_CHECKLIST.md`: calls for real D1 staging, email, session, cloud sync, export/deletion, Android and Sinhala quality checks.
- `README.md` and `docs/REPOSITORY_AUDIT.md`: document current prototype/foundation limitations and historical audit scope.

## Evidence limitations

- No test suite was rerun locally or in a new workflow.
- No failed workflow was retried.
- No production API endpoint, D1 database, Cloudflare dashboard or secret value was accessed.
- Source review cannot prove runtime reachability or whether external perimeter controls exist. The VELORA finding is specifically that the inspected Worker source does not show server-side authorization on its business routes.
- Workflow summaries and source documentation are not substitutes for end-to-end staging UAT.
