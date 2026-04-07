# Memory

Keep this file concise. It stores stable project facts that future contributors should preserve unless there is an explicit decision to change them.

## Stable Product Facts

- Mindscape is a therapy app for Kuwait.
- The primary user journey is discover, book, pay, and attend a scheduled session.
- MVP sessions are one-to-one video or audio sessions.
- Trust, privacy, clarity, and calm UX are core product values.
- Emergency response and social/community features are not part of MVP.

## Stable Technical Facts

- iOS is the app platform for this repository.
- SwiftUI is the intended app UI framework.
- Supabase is the backend foundation.
- MyFatoorah is the payment provider.
- Agora is the session provider unless a documented decision changes it.
- Thin repositories and explicit state models are preferred before deeper architectural layering.
- Guest users may browse therapists before authentication, but booking and personal areas require sign-in.

## Stable Workflow Facts

- this repo is intended for coordinated work by multiple AI models and human developers
- `docs/development/context.md` is for current project state
- `docs/development/handoff.md` is for session transfer
- `docs/architecture/decisions.md` is for important technical decisions and open questions
- major implementation should stay aligned with the docs instead of inventing behavior ad hoc

## Stable Domain Terms

- `user`: patient-side app account
- `therapist`: provider shown in discovery and booking flows
- `booking`: reserved appointment record
- `session`: scheduled audio/video meeting
- `payment`: payment initiation and verification record

## Preserve These Engineering Values

- small, readable changes
- explicit assumptions
- documented decisions
- privacy-aware implementation
- clear boundaries between UI, domain, data, and integrations
