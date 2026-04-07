# System Design

## High-Level Architecture

Mindscape is an iOS client backed by Supabase services and a small set of backend orchestration functions.

### Main boundaries

- iOS client: UI, local state, app-side validation, repository calls
- Supabase: auth, Postgres, storage, row-level security
- backend orchestration: edge functions for payment verification, session token generation, and privileged workflows
- external services: MyFatoorah for payments, Agora for calls

## App Layers

### Presentation

- SwiftUI views
- feature-level state holders
- UI state and event handling

### Domain

- use cases for auth, discovery, booking, payment status, and session access
- domain models and state transitions

### Data

- repositories
- Supabase client integration
- remote DTO mapping
- local session/config persistence where needed

## Client And Backend Responsibilities

| Responsibility | Client | Backend |
| --- | --- | --- |
| Sign in/out | initiate and display state | validate through Supabase auth |
| Therapist discovery | render lists and filters | provide therapist and availability data |
| Booking creation | collect user intent | enforce slot and booking rules |
| Payment result | show pending and final state | verify and reconcile authoritatively |
| Session access | enable join UI when allowed | issue Agora token and enforce access rules |

## High-Level Data Flow

1. user authenticates through Supabase
2. client fetches therapist catalog and availability
3. user creates a booking draft for a selected slot
4. backend initiates MyFatoorah payment for that booking
5. payment callback or verification updates authoritative payment state
6. booking state becomes confirmed, failed, expired, or canceled
7. when join conditions are met, backend issues Agora session credentials
8. client joins the session and records status updates

## Flow Details

### Auth Flow

1. user signs up or signs in
2. Supabase returns authenticated session
3. client loads user profile and upcoming bookings
4. row-level security limits user-visible records

### Booking Flow

1. user selects therapist and slot
2. client creates booking intent
3. backend persists booking with a pending status
4. client starts payment flow if payment is required
5. backend reconciles payment outcome and updates booking status

### Payment Flow

1. backend creates payment request to MyFatoorah
2. client is redirected or handed off to payment UX
3. MyFatoorah returns callback and reference data
4. backend verifies result and updates payment record
5. backend updates linked booking status based on business rules

### Session Flow

1. user opens session detail screen
2. client asks backend whether join is allowed yet
3. backend checks booking ownership, payment state, session timing, and session status
4. backend returns Agora token and channel info when allowed
5. client joins audio or video session

### Notifications Flow

1. backend-side state changes create notification-worthy events
2. client always reflects latest state through refresh or subscription
3. push notifications are added for confirmations and reminders when provider choice is finalized

## Security Model

- Supabase auth is the root identity layer
- user-owned data is protected with row-level security
- privileged operations run in backend functions, not the client
- payment verification is backend-authoritative
- session credentials are short-lived and issued only when eligibility checks pass

## Assumptions

- Assumption: therapist catalog data is managed by internal operations at first.
- Assumption: booking confirmation depends on successful payment verification for paid sessions.
- Assumption: full therapist-side app or dashboard is not part of MVP architecture.
