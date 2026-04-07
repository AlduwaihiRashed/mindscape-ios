# Roadmap

## Phase 0: Build Readiness

Goal: turn the repository into a clean implementation starting point for the iOS app and backend flows.

- lock MVP scope and domain terms
- confirm backend contract boundaries
- align data model, booking rules, and release expectations
- establish the iOS project shape and local setup path
- prepare the repo for focused feature delivery

Current progress:

- completed: product, architecture, QA, and deployment docs; Supabase workspace and migration chain; iOS scaffold with feature folders, models, DTOs, config files, and preview content
- next: wire real app infrastructure, authenticate against Supabase, and replace preview-driven flows with repository-backed state

## Phase 1: App Shell And Authentication

Goal: establish a production-ready app foundation.

- app startup and dependency wiring
- auth session handling
- onboarding and trust messaging
- profile bootstrap and basic account settings
- localization-ready string strategy

## Phase 2: Therapist Discovery And Details

Goal: help users evaluate available care options confidently.

- therapist catalog
- therapist detail screen
- specialization, language, and session mode metadata
- guest-safe discovery behavior
- final operations-approved therapist content

## Phase 3: Booking And Availability

Goal: let users reserve a session slot with clear state handling.

- availability browsing
- slot selection
- booking review and confirmation state
- upcoming and past booking views
- cancellation handling under documented rules

## Phase 4: Payments

Goal: connect booking to authoritative payment outcomes.

- MyFatoorah initiation flow
- callback and verification handling
- paid, failed, canceled, expired, and refunded states
- booking state reconciliation after payment

## Phase 5: Sessions

Goal: make scheduled session attendance reliable and calm.

- session detail screen
- join eligibility and timing rules
- Agora token issuance flow
- video and audio session entry
- failure recovery and session lifecycle visibility

## Phase 6: Launch Readiness

Goal: prepare a stable first release.

- end-to-end QA on core flows
- staging validation with sandbox integrations
- analytics and operational visibility basics
- App Store release preparation
- post-release monitoring and incident response readiness

## Notes

- this roadmap is intentionally MVP-first
- work should not outrun the documented contracts
- open decisions must be logged in `docs/architecture/decisions.md`
