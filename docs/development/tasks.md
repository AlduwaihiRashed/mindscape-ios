# Tasks

## Now

1. wire the iOS app shell to real app state, dependency injection, and repository-backed screen flows
2. finish the real MyFatoorah initiation and callback flow in Supabase
3. replace provisional therapist titles, bios, languages, pricing, and availability assumptions with final operations-approved data
4. define the first release validation path for auth, booking, payment, and session access

## Next

1. implement therapist detail and availability screens against live backend data
2. implement booking draft creation, cancellation, and state refresh against backend-owned workflows
3. add session detail, join eligibility, and Agora token retrieval in the app
4. choose a push notification provider and define reminder/event delivery scope

## Later

1. Arabic localization rollout
2. therapist-facing tooling
3. ratings and feedback
4. support and operational dashboards
5. analytics, observability, and growth tooling beyond MVP basics

## Current Risks To Watch

- payment state ambiguity causing broken booking confirmation
- under-specified privacy and access rules in early backend work
- provisional therapist data hiding product or operational gaps
- app state and backend contracts drifting apart if docs are not kept current

## Recently Completed

- prepared the repository as an iOS implementation kickoff package
- added iOS project generation config and local xcconfig templates
- added SwiftUI app skeleton, feature folders, shared models, DTOs, repository contracts, and preview content
- wired the app shell to injected preview repositories and explicit async screen state for auth, discovery, bookings, profile, and booking availability
- aligned the iOS repository/container path with the Android repo by adding Supabase-backed repositories, unavailable fallbacks, and package wiring for the same auth, profile, discovery, and booking contracts
- aligned docs, backend workspace, and repo structure around one MVP delivery path
