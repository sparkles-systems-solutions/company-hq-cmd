# Architecture

## System boundary

1. GitHub Pages serves the browser frontend only.
2. Cloudflare Workers exposes the HTTPS API.
3. Cloudflare D1 stores operational records.
4. GitHub stores source code and review history.

The browser is an untrusted client. Authorization must be enforced by the Worker on every protected request. Hiding a button in the UI is not access control.

## Security requirements

- Use server-side authentication and secure, HttpOnly, SameSite cookies.
- Require MFA for CEO, finance, HR, security, and administrator accounts.
- Store password hashes using a modern password-hashing scheme; never store plaintext passwords.
- Keep secrets in Cloudflare secrets, never in GitHub or frontend bundles.
- Apply least-privilege RBAC and verify resource ownership server-side.
- Validate and bound every API input; use parameterized SQL.
- Record security-relevant changes in append-only audit events.
- Back up D1 and test restoration before production.
- Use separate development, staging, and production environments.
- Do not store real patient, hospital, or customer data in this company dashboard unless a separately approved data-protection design exists.

## Deployment boundary

GitHub Pages may be public. The API and database remain protected. CORS is not authentication. A production deployment requires reviewed Worker code, D1 migrations, secrets configuration, MFA, monitoring, backups, and acceptance testing.
