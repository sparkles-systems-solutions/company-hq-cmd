# CMD Worker Authorization Foundation

This folder contains a deliberately limited Cloudflare Worker foundation for CMD authorization.

## Implemented in this phase

- Opaque session-cookie lookup using SHA-256 token hashes.
- Server-side active human identity and session checks.
- Deny-by-default role permission and scoped-grant evaluator.
- Explicit deny overrides allow.
- Fresh MFA gate for privileged actions/modules.
- Virtual actor approval/execute prohibition in the policy evaluator.
- Append-only authorization audit events using the existing `audit_logs` table.
- Minimal `GET /api/health` and authenticated `GET /api/me` endpoints.
- Unknown API routes return 404; no CRUD, login, token issuance, or execution endpoints exist.

## Not production-ready

No login/OTP provider, MFA enrollment, session issuance/rotation, D1 binding configuration, deployment config, permission seeds, scoped grants, share-link endpoint, approval execution endpoint, or production secrets are included. The worker intentionally cannot issue a session or execute a business operation.

## Local checks

From this directory:

```sh
npm install
npm run check
npm run test:unit
npm run test:integration
```

Unit tests use Node's built-in test runner. D1 integration tests use Miniflare and its local `workerd` runtime with an isolated D1 database; they do not require a Cloudflare account or touch a remote database.

## Integration requirements before staging

1. Add a dedicated disposable Cloudflare D1 database and replay migrations 0001–0005 in order. Miniflare integration tests are local-runtime validation only, not remote Cloudflare D1 validation.
2. Confirm the Worker D1 binding is named `DB`.
3. Configure `ALLOWED_ORIGIN` to the exact approved frontend origin.
4. Implement a reviewed human login provider and MFA enrollment/verification flow before issuing sessions.
5. Add route-specific server-owned policy definitions; never derive permission requests from client JSON.
6. Add integration tests for actual D1 queries, revocation, expiry, audit failures, CORS, and rate limiting.
7. Keep share links and privileged execution disabled until separately reviewed.

Do not deploy or connect production systems from this scaffold.


## CI coverage note

The pull-request workflow validates Worker syntax and unit tests plus the ordered SQL migration replay and authorization invariants in a disposable SQLite database. This is not a substitute for Cloudflare D1 integration testing.

## Local D1 integration coverage

`tests/d1.integration.test.js` replays migrations 0001–0005 into an isolated Miniflare D1 database and exercises the Worker identity endpoint and D1-backed authorization queries. It covers active/revoked sessions, matching and mismatched role/scope assignments, explicit deny precedence, MFA gating, and audit writes. It does not issue real login credentials or deploy a Worker.
