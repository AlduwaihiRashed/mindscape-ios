# Acceptance Checklist

## MVP Checklist

### Account And Access

- user can sign up or sign in successfully
- user can recover account access through password reset flow
- authenticated session persists correctly after app restart

### Discovery

- user can browse active therapists
- therapist detail shows core information needed for booking
- filters, if shipped, behave predictably

### Booking

- user can select an available slot
- booking summary is clear before payment
- booking state is visible after creation attempt

### Payment

- user sees the correct price before payment
- MyFatoorah flow returns a clear outcome
- booking status matches verified payment state
- failed payment leaves the user with a clear next action

### Session

- user can view session detail for eligible bookings
- join button state matches session timing and eligibility rules
- user can enter video or audio session successfully when allowed
- completed or canceled session state is reflected afterward

### Privacy And Trust

- user cannot access another user's booking, payment, or session data
- app copy avoids confusing or insensitive wording in core flows
- no secrets or raw provider internals are exposed in the client UI

### Release Readiness

- docs reflect shipped behavior
- no placeholder branding remains on user-facing surfaces
- critical bugs from the release cycle are resolved or explicitly deferred with approval
