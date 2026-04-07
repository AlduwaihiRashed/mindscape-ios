# Requirements

## Product Summary

Mindscape is a therapy app for Kuwait. The first release supports secure account access, therapist discovery, booking, MyFatoorah payment, and Agora-powered session attendance.

## User Roles

| Role | Description |
| --- | --- |
| User | Person booking and attending therapy sessions |
| Therapist | Provider represented in the catalog and linked to availability and sessions |
| Operations/Admin | Internal role managing therapist data, booking exceptions, and payment issues |

## Functional Requirements

### FR-1 Authentication

The system must allow users to:

- sign up with verified credentials supported by the final auth design
- sign in securely
- reset password
- sign out
- remain authenticated across app restarts unless revoked

### FR-2 User Profile

The system must allow users to:

- create and maintain a basic profile
- view contact details used for bookings
- view relevant account status information

### FR-3 Therapist Discovery

The system must allow users to:

- browse available therapists
- view therapist details
- see practical information needed for selection
- filter by high-value fields such as specialization, language, or session mode when available

### FR-4 Availability And Booking

The system must allow users to:

- view available time slots
- select a slot
- review a booking summary before payment
- create a booking record that can be tracked through status changes

### FR-5 Payment

The system must allow users to:

- see the price before confirming payment
- initiate payment through MyFatoorah
- return to the app with a clear payment result
- see whether a booking is pending payment, paid, failed, canceled, or refunded

### FR-6 Session Access

The system must allow users to:

- open a session detail view
- join an eligible session through video or audio
- understand whether a session is upcoming, live, completed, canceled, or failed

### FR-7 Booking History

The system must allow users to:

- view upcoming bookings
- view completed or canceled bookings
- inspect therapist, time, payment state, and session state for each booking

### FR-8 Notifications

The system should support:

- booking confirmation
- payment confirmation or failure
- session reminders
- cancellation updates

For the first pass, in-app state visibility is mandatory. Push notifications are important but can land after the primary state model is stable.

### FR-9 Error Handling

The system must:

- show calm, human-readable errors
- preserve clear next actions where possible
- avoid leaving the user uncertain about booking or payment outcome

### FR-10 Privacy And Access Control

The system must:

- protect user identity and booking data
- restrict therapist and booking data access by role and ownership
- avoid exposing session credentials before the user is authorized to join
- store only the minimum data necessary for core flows

## Non-Functional Requirements

### NFR-1 Privacy

- personal and health-adjacent information must be handled conservatively
- logs and analytics must avoid leaking sensitive data
- environment and secret handling must prevent accidental exposure

### NFR-2 Reliability

- core flows must behave consistently under normal network conditions
- payment reconciliation must avoid ambiguous booking states
- session join state must recover cleanly from temporary failures

### NFR-3 Performance

- first meaningful screen load should feel responsive on typical iPhone devices in Kuwait
- scrolling and transitions on key user flows should remain smooth
- booking, payment result, and session entry screens must prioritize fast feedback

### NFR-4 Maintainability

- code and docs must support collaboration across multiple AI models and human developers
- domain terminology should remain consistent across app, backend, and docs
- key assumptions must be recorded explicitly

### NFR-5 Localization Readiness

- strings must be externalized once UI implementation begins
- layout and navigation should not block future Arabic right-to-left support

### NFR-6 Accessibility

- color and typography choices should support readable interfaces
- critical actions must not depend only on color
- session, payment, and booking states must be understandable at a glance

## Reliability Rules

- a booking cannot appear confirmed if payment verification failed
- a session cannot be joined without the appropriate booking and access state
- availability must not expose already-booked slots as open after reconciliation
- idempotent backend handling is required for payment callbacks and booking confirmation operations

## Localization Considerations

- initial release may be English-first
- data structures and UI architecture should remain Arabic-ready
- therapist metadata should support both English and Arabic display fields if needed later

## Compliance And Privacy Notes

- legal and regulatory requirements for Kuwait healthcare products still need formal review
- until compliance review is complete, avoid collecting unnecessary clinical notes or sensitive medical history in MVP

## Assumptions

- Assumption: phone number may become a useful identity or contact field for Kuwait, but email-based auth is the simplest initial path.
- Assumption: therapist verification is handled operationally off-app in early phases.
- Assumption: session records store operational status, not full clinical documentation.
