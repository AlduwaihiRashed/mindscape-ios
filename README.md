# Mindscape iOS

Mindscape is an iOS app for therapy discovery, booking, payment, and scheduled remote sessions in Kuwait.

This repository is set up as a project kickoff package for the next developer to build the app with clear product, architecture, backend, and delivery guidance already in place.

## Product Summary

- users discover therapists
- users review therapist details and availability
- users create a booking and complete payment
- users join scheduled video or audio sessions
- users review booking and session history

## Current Repository State

- product, architecture, QA, deployment, and workflow docs are present
- brand assets are included under `assets/`
- Supabase workspace, migrations, and edge-function scaffolding are under `supabase/`
- an iOS project scaffold is present under `Sources/Mindscape/`, `Configs/`, and `project.yml`
- shared models, DTOs, repository contracts, and preview content are already defined for implementation kickoff

## Start Here

Read these files in order before making changes:

1. `docs/development/context.md`
2. `docs/development/memory.md`
3. `docs/development/agents.md`
4. `docs/development/conventions.md`
5. `docs/development/tasks.md`
6. relevant product and architecture docs for the area you are touching

## Repository Structure

| Path | Purpose |
| --- | --- |
| `Sources/Mindscape/` | iOS app scaffold, feature folders, models, and integration boundaries |
| `Configs/` | local configuration templates and xcconfig files |
| `supabase/` | backend migrations, policies, seed data, and edge functions |
| `docs/product/` | product vision, scope, requirements, and user stories |
| `docs/architecture/` | technical decisions, contracts, schema, and system design |
| `docs/development/` | team coordination and current implementation context |
| `docs/deployment/` | environments, release guidance, and secret handling |
| `docs/qa/` | acceptance criteria, testing guidance, and bug tracking |
| `assets/` | brand references for logo, typography, and color usage |
| `shared/` | cross-cutting workspace for future shared artifacts |

## Current Stack Direction

| Area | Choice | Notes |
| --- | --- | --- |
| iOS app | SwiftUI | native iOS delivery path for MVP |
| Backend | Supabase | auth, Postgres, RLS, and edge functions |
| Payments | MyFatoorah | Kuwait-friendly payment provider |
| Calls | Agora | scheduled in-app video and audio sessions |

## Implementation Notes

- this repo should be treated as the source of truth for scope and contracts while the app is being built
- the client must not become the authority for payment verification or session access
- guest browsing is allowed for discovery, but booking and personal data require authentication
- sensitive configuration belongs in local config or approved secret stores, never in git

## iOS Setup

Project generation is defined in `project.yml`.

If you use XcodeGen on macOS:

```sh
xcodegen generate
```

Then fill in `Configs/Supabase.xcconfig` locally.
