# Test Plan

## Test Strategy

Mindscape should test the highest-risk flows first:

1. authentication
2. therapist discovery
3. booking creation
4. payment reconciliation
5. session join eligibility and call startup

## Test Layers

### Unit Tests

Use for:

- state transitions for booking, payment, and session status
- view-model or use-case logic
- mapping between remote DTOs and domain models

### Integration Tests

Use for:

- Supabase repository interactions
- payment initiation and verification flows in sandbox
- Agora token issuance contract validation
- row-level security expectations where practical

### UI Tests

Use for:

- sign-in flow
- therapist list and detail navigation
- booking review and confirmation flow
- payment-result handling screens
- session detail and join states

### Manual Testing

Required for:

- real device behavior on iPhone
- edge-case UX review for sensitive messaging
- payment handoff and return behavior
- pre-call and join experience quality

### Release Validation

Required before production release:

- smoke test core MVP path end to end
- verify environment-specific config
- verify no debug endpoints or test credentials remain

## High-Risk Scenarios

- payment succeeds but booking remains pending
- payment fails but slot remains blocked indefinitely
- user sees another user's booking or session data
- session join button appears too early or not at all
- app state after payment return loses the booking context
- poor network during booking or call join leads to ambiguous state

## Test Data Guidance

- use fake users and non-sensitive profile data only
- use sandbox payment credentials only
- avoid storing real therapist personal data unless formally approved for staging or production

## Ownership

- iOS implementation team owns unit and UI tests in app code
- backend team owns integration and policy validation
- QA/review role owns acceptance and release validation coverage
