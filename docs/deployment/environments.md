# Environments

## Environment Set

| Environment | Purpose | Notes |
| --- | --- | --- |
| Local | developer machine and AI-assisted implementation work | uses sandbox or mock integrations where possible |
| Staging | integrated QA and pre-release validation | should mirror production structure closely |
| Production | live user environment | locked-down secrets and operational controls |

## Local Expectations

- the iOS app runs against local config or staging-safe services
- Supabase uses a dedicated non-production project
- MyFatoorah uses sandbox credentials only
- Agora uses non-production credentials when possible
- logs may be verbose but still must avoid sensitive payload leakage

## Staging Expectations

- use a dedicated staging Supabase project
- use sandbox payment credentials where supported
- use staging app identifiers if needed
- support QA of auth, booking, payment, and session flows end to end
- be stable enough for release candidate validation

## Production Expectations

- production secrets only in approved secret stores or CI-protected configuration
- stricter logging and monitoring controls
- production callback URLs and redirect URLs locked down
- operational visibility for payment failures and session issues

## Config Separation

Keep the following separate per environment:

- Supabase URL and anon key
- service-role or privileged backend credentials
- MyFatoorah API keys and callback URLs
- Agora app credentials and token service settings
- bundle identifiers, signing material, and release metadata where applicable

## Configuration Rules

- never reuse production secrets in local or staging
- client-safe keys and server-only secrets must be separated clearly
- environment names should be reflected consistently in app config and backend deployment config
- `.env`-style files are local-only and must not be committed unless they are example files with placeholder names only
