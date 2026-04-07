# Conventions

## Core Principles

- prefer small, clear changes over large speculative ones
- document important assumptions explicitly
- preserve privacy and trust in both code and UX decisions
- keep terminology consistent across docs, code, and tickets

## Naming Conventions

### Product terminology

- use `user` for the patient-side app user unless a document specifically needs `patient`
- use `therapist` for provider-facing domain records in MVP
- use `booking` for the reservation record
- use `session` for the actual scheduled call experience
- use `payment` for payment initiation and verification records

### Swift and app naming

- Swift type names use UpperCamelCase
- view files should end with `View`
- observable app/state types should end with `State`, `Store`, or `ViewModel` based on their role
- repository protocols should end with `Repository`
- DTO and entity names should reflect the domain, not transport leaks

## Branch And Commit Expectations

- branch names should be short and descriptive, such as `foundation/ios-shell` or `docs/schema-first-pass`
- commit messages should use imperative language, such as `Define first-pass booking schema`
- keep one logical change per commit where practical

## Folder Ownership

| Folder | Primary owner |
| --- | --- |
| `docs/product/` | Product and planning |
| `docs/architecture/` | Architecture and backend |
| `docs/development/` | Documentation integrator and team leads |
| `docs/deployment/` | Backend and release owners |
| `docs/qa/` | QA and reviewers |
| `Sources/Mindscape/` | iOS implementation |
| `supabase/` | Backend and integration |
| `shared/` | Cross-cutting models and constants with architect review |

## Documentation Rules

- update source-of-truth docs when behavior, contracts, or scope changes
- mark uncertain items as `Assumption` or `Open decision`
- keep `memory.md` stable and high signal
- keep `context.md` current and short
- keep `handoff.md` session-specific and practical
- record meaningful decisions in `docs/architecture/decisions.md`

## SwiftUI Expectations

- prefer feature-oriented structure once implementation begins
- keep UI, domain, and data layers separate
- keep SwiftUI views focused on rendering and event wiring
- avoid networking, payment, or Agora orchestration inside views
- model UI state explicitly
- prefer one source of truth for screen state
- externalize strings when UI code is added

## Backend Expectations

- use Supabase auth as the root identity provider unless a decision says otherwise
- document every table, relation, and status enum before large backend work
- use row-level security by default for user-owned data
- keep payment verification authoritative on the backend side
- isolate provider integrations such as MyFatoorah and Agora token generation

## Assumptions And Decisions Logging

- use `Assumption:` in docs for unresolved but usable working assumptions
- use `Open decision:` in docs for unresolved items that block confident implementation
- use `docs/architecture/decisions.md` to record accepted decisions with rationale and impact

## Definition Of Done For A Meaningful Task

- implementation or documentation is internally consistent
- affected docs are updated
- obvious edge cases were considered
- validation performed is stated clearly
- a clean handoff exists for the next contributor
