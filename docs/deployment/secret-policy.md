# Secret Policy

## Secrets In This Project

Expected sensitive values include:

- Supabase project URLs and keys
- Supabase service-role credentials
- MyFatoorah API keys and webhook verification details
- Agora app certificate or token-generation secrets
- Apple signing certificates, profiles, and App Store Connect credentials
- CI tokens and release automation credentials

## Where Secrets Belong

| Secret Type | Allowed Location |
| --- | --- |
| iOS local config | local untracked config files such as `Configs/Supabase.xcconfig` or machine-local overrides |
| Backend local config | untracked `.env` files under local workflow only |
| CI/CD secrets | hosted secret store in CI provider |
| Production credentials | managed secret store or deployment platform secret manager |

## What Must Never Be Committed

- real API keys
- service-role keys
- signing material
- signing passwords or private signing material
- raw provider credentials in docs, examples, screenshots, or tests

## Safe Patterns

- commit only placeholder example files when necessary
- use clearly fake values in documentation, or avoid showing values entirely
- keep client-safe config separate from server-only secrets
- rotate exposed secrets immediately if a leak is suspected

## Specific Rules

- MyFatoorah verification and reconciliation secrets must stay backend-only
- Agora token generation secrets must never live in the iOS app
- Supabase service-role credentials must never be used by the client app

## Incident Response

If a secret is committed or pasted into the repo:

1. treat it as compromised
2. rotate it immediately
3. remove it from the codebase and docs
4. document the incident in internal operations notes if this becomes a real team process
