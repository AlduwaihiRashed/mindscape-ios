# Scope

## MVP Definition

Mindscape MVP is the smallest release that supports this complete path:

`account access -> therapist discovery -> slot selection -> payment -> session join -> history`

If a feature does not materially improve that path, it should not enter MVP by default.

## In Scope For MVP

### User account

- sign up
- sign in
- password reset
- secure session persistence
- basic profile editing

### Therapist discovery

- therapist listing
- therapist detail view
- core metadata such as specialization, language, session type, and bio
- simple filtering for the highest-value traits

### Booking

- availability display
- slot selection
- booking review before confirmation
- upcoming and past booking views
- cancellation rules visibility

### Payment

- price visibility before payment
- MyFatoorah checkout handoff
- payment status reconciliation
- booking state that reflects payment outcome clearly

### Session attendance

- session detail screen
- in-app video or audio join via Agora
- session status visibility
- access rules that prevent early or unauthorized joins

### Core notifications

- in-app status updates are required
- push notifications are allowed only for high-value reminders and confirmations

## Out Of Scope For Now

- web app
- therapist self-serve onboarding portal
- full admin dashboard
- insurance and claims handling
- AI chatbot or AI clinical support
- mood tracking, journaling, or wellness content library
- group therapy sessions
- social or community features
- family/shared accounts
- multi-country expansion logic

## Later-Phase Ideas

- Arabic localization
- reviews or post-session feedback
- richer search and sort
- therapist-side schedule tooling
- support center and operational tooling
- coupon or promotional flows
- analytics and growth experiments

## Scope Guardrails

- Any new feature request must be labeled as `now`, `next`, or `later` in `docs/development/tasks.md`.
- Product-impacting changes must update `requirements.md` and, if needed, `user-stories.md`.
- Architecture-heavy additions must be recorded in `docs/architecture/decisions.md` before broad implementation.

## Assumptions

- Assumption: users book individual scheduled sessions rather than instant on-demand consultations.
- Assumption: therapist operational tooling is handled manually or outside the user app during MVP.
- Assumption: refund and reschedule complexity will start narrow and expand later.
