# CMD integration readiness — Phase 8

**Status:** readiness assessment only. Existing Worker API remains a limited authorization foundation, not a complete CMD backend.

## Verified current API surface

| Route | Current behavior | Readiness |
|---|---|---|
| `GET /api/health` | Returns service health and authorization-foundation mode | Basic health only; no dependency or readiness probe |
| `GET /api/me` | Authenticates existing CMD session cookie and returns minimal active-human identity | Existing cookie path only; no Supabase exchange or lifecycle helper integration |
| `OPTIONS` | Exact configured-origin preflight; current allow-header is content-type | CSRF custom header not enabled |
| Other paths | Returns 404 | No business API modules implemented |

## Integration rules for every future protected route

1. Match method and route before reading request body or protected data.
2. Use a server-owned immutable route policy: module, action, scope resolver, data projection, mutation classification, and MFA requirement. Never accept these values from browser JSON/query parameters.
3. Authenticate the CMD session; verify active human identity, revocation, fixed absolute expiry, idle timeout, timestamp validity, and required MFA freshness.
4. Apply the approved session recheck/consistency strategy before authorization. The current recheck contract is a test seam and does not eliminate the final read-to-data race.
5. Resolve current role assignments and scoped grants from D1. Explicit deny overrides allow; virtual actors can never approve or execute.
6. Apply resource scope and field-level projection in the server query. Frontend filtering is not authorization.
7. For browser mutations, enforce Origin/CSRF before mutation. The standalone guard is not wired and CORS does not currently allow the custom CSRF header.
8. Write the required audit event. Audit failure must fail closed for sensitive operations.
9. Return no-store and security headers; return generic client errors and keep secrets/PII out of logs.
10. Test allow, deny, cross-scope, stale session, revocation, MFA, audit outage, and concurrent changes for each route.

## No-login read-only share boundary

No-login dashboard sharing is a separate capability route, not a bypass through `/api/me`. Implement only from the separate `SHARE_LINK_SECURITY_CONTRACT.md`; it must never inherit ordinary user routes or broader role permissions.

## Explicit integration blockers

- First-factor decision recorded: Email + Password with verified email identifier; TOTP second factor. This is a design-only decision and does not authorize a live provider project or sign-in.
- Supabase bearer verification and TOTP step-up adapters are not connected to a CMD session exchange.
- Session lifecycle pure helpers and pipeline contract are not integrated into `worker/src/index.js`.
- No session issuance, rotation, logout, global revocation, or CSRF-token issuance route exists.
- No protected business-data API routes exist.
- No dashboard-share schema, endpoint, token, or data connection exists.
- No rate-limit storage or account recovery flow is implemented.
- Remote Cloudflare D1 transaction/consistency behavior has not been verified.
- No staging environment or production configuration is connected.

## Route acceptance checklist

- [ ] Route policy is defined server-side and version-controlled
- [ ] Request body cannot choose role, action, module, scope, or data projection
- [ ] Authentication and session lifecycle checks run before authorization
- [ ] Actor is active and human for human-only routes
- [ ] Permission and exact record/project/department scope are checked
- [ ] Explicit deny and virtual-role restrictions are tested
- [ ] MFA step-up is required for approval, execution, and privileged modules
- [ ] CSRF/Origin protection is wired for every cookie-authenticated mutation
- [ ] Audit events are durable and failure behavior is tested
- [ ] Data access uses parameterized SQL and server-side field projection
- [ ] Response/cache/security headers are tested
- [ ] Revocation and concurrency behavior is tested against target D1 semantics
- [ ] Negative tests prove no protected data query occurs after a denial
