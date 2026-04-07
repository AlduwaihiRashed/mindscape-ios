# API Contracts

These are first-pass service contracts, expressed in endpoint-like terms even if final implementation uses Supabase RPC, edge functions, or direct table access.

## Contract Principles

- the client is not the source of truth for payment or session authorization
- privileged workflows belong in backend functions
- responses should return explicit status fields that map cleanly to UI states

## Auth Contracts

### `auth.signUp`

- purpose: create account
- input: email, password, optional profile basics
- output: auth session or verification-needed state

### `auth.signIn`

- purpose: start authenticated user session
- input: email and password
- output: auth session and user identifier

### `auth.resetPassword`

- purpose: start password reset flow
- input: email
- output: accepted state

## Profile Contracts

### `profile.getMe`

- purpose: fetch current authenticated user profile
- output: profile summary, locale, contact fields, account metadata needed by the app

### `profile.updateMe`

- purpose: update editable profile fields
- input: editable profile fields only
- output: updated profile

## Discovery Contracts

### `therapists.list`

- purpose: return active therapist catalog entries
- input:
  - optional filters: specialization, language, session mode
  - pagination parameters
- output:
  - therapist summaries
  - pagination metadata

### `therapists.getBySlug`

- purpose: fetch therapist detail for display and booking context
- input: therapist slug or id
- output: therapist detail and available session modes

### `therapists.getAvailability`

- purpose: fetch bookable slots for a therapist
- input: therapist id, optional date range
- output: slot list with start time, end time, and status

## Booking Contracts

### `bookings.createDraft`

- purpose: create a pending booking before payment verification
- input:
  - therapist id
  - availability slot id
  - session mode
- output:
  - booking id
  - booking status
  - hold expiration timestamp
  - price summary
  - payment requirement flag
- notes:
  - this contract is backend-owned and should be implemented through RPC or equivalent privileged workflow, not direct client table inserts

### `bookings.listMine`

- purpose: list current user's bookings
- input: status filters and pagination
- output: booking summaries with therapist, payment, and session statuses

### `bookings.getById`

- purpose: fetch full booking detail
- input: booking id
- output: booking, payment summary, session summary

### `bookings.cancel`

- purpose: request booking cancellation under allowed rules
- input: booking id, optional reason
- output: updated booking state
- notes:
  - cancellation should be backend-owned so business rules can reject non-cancelable states cleanly

## Payment Contracts

### `payments.startMyFatoorah`

- purpose: initialize a payment for a booking
- authority: backend only
- input: booking id
- output:
  - payment id
  - payment status
  - redirect or launch payload required for MyFatoorah flow

### `payments.verifyMyFatoorah`

- purpose: verify payment callback or return reference
- authority: backend only
- input: provider reference or callback payload
- output:
  - authoritative payment status
  - linked booking status

### `payments.getForBooking`

- purpose: fetch latest payment state for a booking visible to the user
- input: booking id
- output: payment summary

## Session Contracts

### `sessions.getForBooking`

- purpose: fetch session detail and join eligibility
- input: booking id
- output:
  - session status
  - join eligibility flag
  - join allowed from timestamp

### `sessions.issueAgoraToken`

- purpose: issue short-lived Agora credentials for an eligible booking
- authority: backend only
- input: booking id
- output:
  - token
  - channel name
  - role
  - expires at timestamp

### `sessions.markLifecycleEvent`

- purpose: record operational session state changes
- authority: backend or trusted service only
- input: booking id or session id, event type
- output: updated session state

## Notification Event Types

These are internal event contracts more than public endpoints.

- `booking_confirmed`
- `payment_failed`
- `session_reminder_due`
- `session_started`
- `booking_canceled`

## Error Contract Expectations

- every failure should return a stable machine-readable code
- user-facing copy should be mapped in the client, not leaked from raw provider messages
- payment verification failures must preserve traceability for support and retry handling

## Open Decisions

1. whether session lifecycle updates come only from app actions or also from Agora webhooks later
2. exact hosted MyFatoorah callback and reconciliation payload shape once provider credentials are configured
