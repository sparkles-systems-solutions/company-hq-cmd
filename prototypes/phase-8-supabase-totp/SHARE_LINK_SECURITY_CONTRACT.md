# CMD no-login dashboard share security contract

**Status:** design and acceptance contract only. No share-token route, token issuance, database migration, or live share exists.

## Security objective

Allow a person who cannot sign in to view one explicitly approved dashboard through an unguessable, short-lived, read-only link. This is a narrowly scoped capability, not anonymous access to CMD and not a substitute for user authentication.

## Threat model and required controls

- Treat a leaked URL as a leaked bearer capability. The token must be unguessable, narrowly scoped, short-lived, revocable, and never logged.
- Generate at least 32 cryptographically random bytes server-side and encode as base64url. Store only SHA-256(token); display the raw token once.
- Require CEO approval before creation. The approval record must bind the exact dashboard, data scope, allowed fields, filters, expiry, and restrictions.
- Default expiry should be short; absolute maximum seven days for the initial release. No indefinite links and no silent renewal.
- Allow immediate revocation. Every request must check token hash, active status, expiry, and revocation state server-side.
- Grant GET-only read access to one dashboard and explicitly enumerated fields/filters. Deny navigation to other modules, search, exports, attachments, comments, mutation, and arbitrary query parameters.
- Apply field-level projection on the server. Do not fetch broad data and rely on frontend hiding.
- Return Cache-Control: no-store, Referrer-Policy: no-referrer, X-Content-Type-Options: nosniff, and a restrictive CSP. Do not load third-party scripts, pixels, fonts, or analytics on share pages.
- Use rate limits and generic failure responses. Do not reveal whether a token exists, is expired, or was revoked.
- Audit creation, CEO approval, successful use, denied use, expiry, and revocation. Never log raw tokens, full URLs, sensitive field values, or personal data.
- Exclude share pages from indexing and sitemaps. Use robots directives only as defense-in-depth, never as access control.
- Where appropriate, allow a CEO-approved VPN/internal-network/IP restriction as an additional control, not as the sole protection.
- Never expose passwords, credentials, identity documents, patient data, restricted security findings, bank data, or confidential third-party information through a share link.

## Suggested data contract (not a migration)

A future share record should bind random record ID; unique token hash; dashboard key; immutable allowlisted field identifiers and validated filters; creator and CEO approval reference; created-at, expires-at, revoked-at and revoke reason; rate-limit policy; and audit correlation ID.

The token itself must not be a primary key or be stored in plaintext. Treat filters and field lists as immutable after approval; changing scope requires revocation and a new approval.

## Request decision sequence

1. Accept the token only from the designated path segment; reject query-string tokens and referrer propagation.
2. Hash the supplied token immediately and look up the share record using a parameterized query.
3. Fail closed on missing, expired, revoked, malformed, or disabled records.
4. Validate the requested dashboard and filters against the approved immutable scope.
5. Apply rate limiting and write a non-sensitive access audit event.
6. Query only the approved dataset and project only the approved fields.
7. Return no-store response headers and no links to other CMD surfaces.

## Acceptance test matrix

| Scenario | Expected behavior |
|---|---|
| Valid token, approved dashboard and fields | Read-only scoped response |
| Unknown, malformed, expired, or revoked token | Generic denial; no data query |
| Token requests another dashboard | Deny; no data query |
| Request adds an unapproved field/filter | Deny; no data query |
| POST/PUT/PATCH/DELETE | Deny |
| Export, attachment, search, or navigation route | Deny |
| Token hash duplicated | Unique constraint rejects issuance |
| Raw token appears in DB, audit, logs, or response JSON | Test failure |
| Audit write fails | Fail closed; no data response |
| Rate limit exceeded | Deny without revealing token state |
| CEO revokes link | Subsequent request denied |
| Scope needs modification | Revoke old share and create a newly approved share |

## Explicit non-goals and gates

- This contract does not implement a share endpoint or create a token.
- No migration or live D1 write is included.
- No real dashboard data is connected.
- No no-login access is enabled.
- Before implementation, the CEO must approve the concrete dashboard, exact fields/filters, expiry, audience, and any network restriction. The data classification and privacy review must confirm the content is suitable for link-based access.
- Any staging or production implementation, live database change, deployment, or activation requires separate explicit approval.
