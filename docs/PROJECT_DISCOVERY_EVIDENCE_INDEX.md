# Project Discovery Evidence Index — Phase 5

**Review date:** 2026-11-25  
**Repository:** `sparkles-systems-solutions/company-hq-cmd`  
**Purpose:** Index the primary evidence used for the Phase 5 discovery report.

## Company repository listing

Accessible repositories inspected included:
- `velora-his-erp`
- `advance-meter-taxi-private`
- `Advance-Meeter-Taxi-slzzz-oo`
- `meeter-taxi-slzzz-com`
- `meeter-taxi-com`
- `Open-Taxi-`
- `All-in-taxi-com`
- `Inventory-Management-`
- `Smart--inventory--management-systems`
- `opd-token-systems`
- `Voice-type-doc`
- `teamapp`
- `teamtracker-app`
- `lanka-map`
- `lingua-ai-english-academy`
- `meetmind-ai-live-test`
- `company-hq-cmd`

No matching dedicated repository was found in the accessible owner listing for PriceTagSystem, Personal AI Agent or SAP Business One / Enterprise Solutions.

## Selected evidence references

| Project | Repository path / evidence |
|---|---|
| VELORA | `README.md`, `package.json`, `docs/BUILD-ACCEPTANCE.md`, `docs/REQUIREMENT-LAYERS.md`, `docs/UAT-ROADMAP.md`, `tests/api-smoke.test.js`, `tests/auth.test.js`, `.github/workflows/api-checks.yml` |
| Taxi | `README.md`, `package.json`, `docs/SECURITY.md`, `docs/FIELD-QA-CHECKLIST.md`, `docs/QA-MOBILE.md`, `docs/DEPLOYMENT.md`, eight test files under `test/` |
| Lingua | `README.md`, `docs/REPOSITORY_AUDIT.md`, `docs/PHASE_ROADMAP.md`, `docs/BACKEND_FOUNDATION.md`, `tests/ACCEPTANCE_CHECKLIST.md`, auth/API/dictionary/schema test files |
| MeetMind | `api/README.md`, `api/worker.js`, `api/schema.sql`, `api/migrations/`, `.github/workflows/deploy-api.yml` |
| Lanka Map | root `index.html`, main commit history, `Phase 1 UAT` workflow summaries |
| TeamApp | `index.html`, `admin.html`, `chat.html`, `map.html` |
| TeamTracker | Gradle files, `app/src`, `Build APK` workflow summaries |
| Inventory | `Inventory-Management-/README.md`, `22untitled.html`, `Smart--inventory--management-systems/index.html` |
| OPD Token | `opd-token-systems/index.html` and Pages workflow summaries |
| Voice Type | `Voice-type-doc/index.html` and Pages workflow summaries |

## Evidence interpretation

- A successful CI workflow is evidence only for the checks performed by that workflow on its associated commit.
- A failed workflow is a signal requiring log inspection; the failure cause must not be guessed.
- A static HTML file is evidence of a source artifact, not proof of a complete application.
- README and roadmap statements are project documentation, not independently verified runtime facts.
- The absence of a repository from the accessible listing does not prove that no source exists elsewhere.
