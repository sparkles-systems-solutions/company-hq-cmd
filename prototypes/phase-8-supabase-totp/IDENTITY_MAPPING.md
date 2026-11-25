# Phase 8 — Supabase subject-to-CMD identity mapping prototype

Status: isolated, unintegrated prototype. No real user mapping or session issuance.

## Purpose

After `verifySupabaseAccessToken` has cryptographically verified the access token and confirmed AAL2, `resolveSupabaseHumanIdentity` can match the verified Supabase `sub` to a pre-provisioned CMD `auth_users.provider_subject`.

## Safety properties

- Accepts only a verifier result marked `valid: true` and `assuranceLevel: aal2`.
- The `authProvider` selector must come from trusted server configuration, never a request parameter.
- Matches the exact provider subject; it does not fall back to email address.
- Requires an active CMD auth account and an active human person record.
- Rejects virtual AI identities and inactive or missing mappings.
- Returns only the minimum CMD identity fields needed by a later session layer.
- Does not create or update auth users, enroll factors, issue CMD sessions, set cookies, or activate identities.

## Schema compatibility gate

The current CMD `auth_users.auth_provider` constraint permits only `email_otp`, `oidc`, and `webauthn`. Supabase is the upstream authentication service, not itself an identity method. The CEO has selected Supabase + TOTP but has not selected the first-factor method or identity-provider mapping. Therefore this prototype requires an explicit trusted configuration value matching the existing enum and intentionally does not choose one.

Before integration, decide and document the first-factor method, establish a verified provider-subject mapping for the CEO identity, and review whether the existing `auth_provider` enum accurately represents the chosen flow. Do not map by email alone.

## Verification

Unit tests use a mock D1-style binding and synthetic identities. They do not contact Supabase or any remote D1 database. Run `npm test` from `worker/`.

## Not authorized / not performed

No Supabase project configuration, real identity provisioning, account activation, session issuance, production Worker integration, D1 migration, secret creation, deployment, or PR merge.
