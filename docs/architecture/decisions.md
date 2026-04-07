# Decisions

Use this file as a lightweight ADR log.

## ADR-001: iOS MVP Delivery Path

- status: accepted
- date: 2026-04-07
- decision: build the MVP app for iOS in this repository
- rationale: the repo now serves as a focused implementation package for the next iOS developer
- impact: app structure, delivery planning, and contributor guidance should assume an iOS-native implementation path

## ADR-002: Supabase As Backend Foundation

- status: accepted
- date: 2026-04-05
- decision: use Supabase for auth, Postgres, storage, and backend access control
- rationale: it reduces backend setup time while still giving a strong relational data model and RLS support
- impact: backend design should lean into Postgres schema, policies, and edge functions instead of a large custom server from day one

## ADR-003: MyFatoorah For Payments

- status: accepted
- date: 2026-04-05
- decision: use MyFatoorah as the initial payment provider
- rationale: it is a strong regional fit for Kuwait
- impact: payment flow, callback handling, and booking reconciliation should be designed around MyFatoorah first

## ADR-004: Agora For In-App Sessions

- status: accepted
- date: 2026-04-05
- decision: use Agora for video and audio sessions unless a clearly better option is proven later
- rationale: mature mobile calling support and practical scheduled-session fit
- impact: backend should plan for token issuance and the app should plan for controlled session access

## ADR-005: Documentation-First Kickoff

- status: accepted
- date: 2026-04-05
- decision: establish product, architecture, QA, and workflow docs before broad implementation
- rationale: the repo is intended for coordinated work by multiple AI models and human developers
- impact: future implementation work should update docs when changing behavior or assumptions

## ADR-006: Scheduled Video/Audio Sessions Only For MVP

- status: accepted
- date: 2026-04-05
- decision: MVP booking and session flows support scheduled one-to-one video or audio sessions only
- rationale: it keeps the booking model, session access rules, and UI scope aligned with the documented MVP and avoids mixing scheduled care with instant or in-person paths
- impact: app flows, sample data, schema assumptions, and backend contracts should avoid instant-session or in-person behavior unless a later decision explicitly expands scope

## ADR-007: Guest Discovery With Auth-Gated Booking

- status: accepted
- date: 2026-04-05
- decision: guests can browse therapist catalog and availability before authentication, but booking and private areas require sign-in
- rationale: open discovery supports trust and conversion while keeping personal, booking, payment, and session data behind authentication
- impact: therapist catalog reads should be available to anon users through safe policies, while writes and private data remain authenticated or privileged only

## ADR-008: Email-First Auth With Optional Phone

- status: accepted
- date: 2026-04-06
- decision: MVP authentication is email-first, with phone stored only as an optional profile field
- rationale: email/password is the smallest stable auth baseline for the first release
- impact: auth, profile bootstrap, and backend profile creation should treat email as the required identifier and phone as optional metadata

## ADR-009: Pending-Payment Hold For Booking Drafts

- status: accepted
- date: 2026-04-06
- decision: booking draft creation places a 15-minute pending-payment hold on a slot by creating a `pending_payment` booking with `expires_at`; availability reads must hide slots covered by active holds or confirmed/completed bookings
- rationale: this gives users a deterministic booking outcome before payment verification while keeping slot ownership race conditions out of the client
- impact: booking creation must run through backend-owned functions, availability reads must exclude active holds, and payment reconciliation must eventually promote or expire draft bookings authoritatively

## ADR-010: Operations-Managed Therapist Catalog For MVP

- status: accepted
- date: 2026-04-06
- decision: therapist records and availability remain operations-managed in MVP
- rationale: this avoids introducing therapist-side auth, self-serve availability tooling, and mixed ownership rules before the user booking flow is stable
- impact: therapist and availability writes stay privileged; the app remains a consumer of catalog data only

## ADR-011: Session Join Window For MVP

- status: accepted
- date: 2026-04-06
- decision: session join becomes eligible 15 minutes before the scheduled start and remains eligible until 30 minutes after the scheduled end unless the session is canceled or failed earlier
- rationale: this is a practical default for therapy sessions, gives users a small preparation window, and keeps token issuance rules deterministic
- impact: session token checks, `join_allowed_from`, and client join-state UI should follow this window unless a later decision changes it explicitly

## ADR-012: Mock-Capable Local Provider Scaffolding

- status: accepted
- date: 2026-04-06
- decision: local payment and session edge functions support mock modes by default until hosted provider secrets are available
- rationale: this allows backend orchestration, booking-status transitions, and local validation to proceed without committing secrets or blocking on provider onboarding
- impact: local validation can exercise payment/session flows now, but hosted environment validation still requires real provider configuration

## Open Decision-001: Notification Strategy

- status: open
- question: which push provider and notification architecture should be used for reminders and status updates?
- current leaning: Apple Push Notification service with a lightweight backend-triggered delivery path
- reason still open: not necessary to block first implementation work yet
