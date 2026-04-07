# Tech Stack

## Selected Stack

| Area | Choice | Why it fits Mindscape |
| --- | --- | --- |
| Mobile app | SwiftUI | native iOS quality, straightforward state-driven UI, and good long-term maintainability |
| Backend | Supabase | fast startup path for auth, Postgres, policies, and edge functions |
| Payments | MyFatoorah | better local fit for Kuwait payment expectations than a generic global-only starting point |
| Calls | Agora | mature real-time video/audio SDKs and practical scheduled-session support |

## Why SwiftUI

- it gives a clean native path for iPhone-first delivery
- state-driven UI fits auth, booking, payment, and session status flows well
- it keeps the app surface readable while the product is still shaping its first release

## Why Supabase

- gives a fast path to authentication, Postgres, storage, and role-aware access control
- Postgres is a durable foundation for booking and payment data
- row-level security is a strong fit for user-owned sensitive records
- edge functions can hold provider-specific server logic such as payment verification and Agora token issuance

## Why MyFatoorah

- aligns better with Kuwait market expectations than a US-centric default
- reduces localization friction for checkout
- supports the MVP need: initiate payment, receive callback status, reconcile booking state

## Why Agora

- reliable SDK and infrastructure for mobile voice/video
- practical support for both video and audio-only session modes
- suitable for scheduled sessions instead of building call infrastructure from scratch

## Future Alternatives Worth Noting

Only consider alternatives if current choices fail on product, compliance, cost, or reliability.

- Calls alternative: Daily or Twilio if Agora proves weak on quality, pricing, or operational fit.
- Backend alternative: custom backend only if Supabase starts blocking core business rules or compliance requirements.

These are not current migration plans.

## Supporting Tooling Expectations

- XcodeGen for project generation from `project.yml`
- local xcconfig-based environment separation
- CI later for lint, tests, and release validation

## Constraints

- no real secrets in repo
- no provider SDK added without a documented reason
- client should not become the authority for payment verification or session access
