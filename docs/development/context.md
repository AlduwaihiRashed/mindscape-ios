# Context

## Project Snapshot

- Product: Mindscape
- Market: Kuwait
- Platform: iOS
- Product type: therapy discovery, booking, payment, and scheduled remote session app
- Current phase: implementation kickoff

## Confirmed Stack

- iOS: SwiftUI
- Backend: Supabase
- Payments: MyFatoorah
- Calls: Agora

## Current Goal

Turn the repository from a prepared scaffold into a working iOS app with backend-backed auth, discovery, booking, payment, and session flows.

## Current Status

- core product docs are defined
- first-pass architecture docs are defined
- delivery, QA, and deployment guidance are defined
- the repository contains an iOS scaffold with feature folders, domain models, DTOs, repository protocols, and preview content
- `supabase/` contains migrations, seed data, policies, and edge-function scaffolding for payment and session flows
- guest discovery, auth-gated booking, payment authority, and session access rules are documented
- final therapist content, live client integration, and release-grade validation are still pending

## Biggest Open Decisions

1. push notification provider and rollout timing
2. exact MyFatoorah callback and reconciliation details once production-facing credentials are configured
3. how much of session lifecycle state should come from app actions versus provider-side webhooks

## Latest Priorities

1. wire the iOS app scaffold to real repositories and app state
2. finish the hosted MyFatoorah initiation and callback path in Supabase
3. replace provisional therapist content and validate the booking flow against final data
4. define the first release validation checklist for auth, booking, payment, and session access

## Working Assumptions

- Assumption: English-first launch, Arabic-ready architecture.
- Assumption: therapist onboarding and verification are handled operationally outside the app at first.
- Assumption: users book scheduled one-to-one sessions, not instant live consultations.

## Constraints

- do not build broad non-MVP features yet
- do not commit real secrets or credentials
- do not let implementation outrun product and architecture agreements on sensitive flows

## What A New Contributor Should Do First

1. read `README.md`
2. read `docs/development/memory.md`
3. read `docs/development/agents.md`
4. read the specific docs for the area being touched
5. check `docs/development/tasks.md` before starting
