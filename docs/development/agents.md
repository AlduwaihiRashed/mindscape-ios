# Agents

This repo is designed for parallel work across AI models and human developers. Each role has explicit boundaries to reduce duplicate effort and contradictory changes.

## Shared Rules For Every Role

### Must read first

1. `README.md`
2. `docs/development/context.md`
3. `docs/development/memory.md`
4. `docs/development/conventions.md`
5. `docs/development/tasks.md`
6. relevant product and architecture docs for the task

### Must update after finishing

- `docs/development/handoff.md` for substantial work
- `docs/development/done-log.md` for meaningful completed work
- `docs/development/context.md` if current priorities or status changed
- source-of-truth product or architecture docs if decisions changed

### Must never do

- invent product behavior that contradicts the docs
- silently redefine domain terminology
- commit secrets or fake credentials
- implement large features without updating the related docs

## Product And Planning Model

### Purpose

Owns scope clarity, priorities, feature framing, and acceptance language.

### Can change

- `docs/product/*`
- `docs/development/tasks.md`
- `docs/qa/acceptance-checklist.md`
- roadmap-level priorities in `roadmap.md`

### Must read first

- all product docs
- `docs/development/context.md`
- `docs/architecture/decisions.md`

### Must update after finishing

- touched product docs
- `docs/development/context.md` if priorities changed
- `docs/development/handoff.md`

### Must never do

- choose implementation details that belong to app or backend design unless documenting an assumption
- expand scope casually without updating `scope.md`

## iOS Implementation Model

### Purpose

Builds the app foundation and user-facing flows with SwiftUI and documented integration boundaries.

### Can change

- `Sources/Mindscape/`
- `Configs/`
- iOS-related sections in docs when implementation proves changes are needed
- app tests related to iOS work

### Must read first

- `docs/product/requirements.md`
- `docs/architecture/system-design.md`
- `docs/architecture/api-contracts.md`
- `docs/development/conventions.md`

### Must update after finishing

- `docs/development/handoff.md`
- `docs/development/done-log.md`
- architecture docs if implementation revealed a contract or layer change

### Must never do

- hardcode secrets or provider keys
- invent backend endpoints or state models that do not exist in docs
- place network, payment, or session authorization logic directly in views

## Backend And API Model

### Purpose

Defines and implements Supabase-backed data, security, payment orchestration, and session access rules.

### Can change

- `supabase/`
- `docs/architecture/database-schema.md`
- `docs/architecture/api-contracts.md`
- `docs/architecture/decisions.md`
- deployment docs related to secrets and environments

### Must read first

- product requirements and scope
- architecture docs
- deployment docs for secrets and environment constraints

### Must update after finishing

- schema and contract docs impacted
- `docs/development/handoff.md`
- `docs/development/done-log.md`

### Must never do

- weaken privacy or access rules for convenience
- assume therapist operations are fully self-serve unless product docs change
- expose payment verification as a client-only responsibility

## QA And Review Model

### Purpose

Reviews code and docs for bugs, contradictions, regression risk, privacy issues, and missing tests.

### Can change

- `docs/qa/*`
- narrowly scoped fixes when the task is explicitly remediation-oriented
- `docs/development/handoff.md` with review findings

### Must read first

- relevant implementation or docs under review
- `docs/product/requirements.md`
- `docs/qa/test-plan.md`

### Must update after finishing

- `docs/qa/bug-log.md` if issues are found
- `docs/development/handoff.md`

### Must never do

- approve work without checking failure states
- focus only on style while ignoring behavioral risk
- introduce major new features during a review task

## Refactor And Cleanup Model

### Purpose

Improves clarity, reduces duplication, and keeps the project maintainable without changing agreed behavior.

### Can change

- code organization in `Sources/Mindscape/`, `supabase/`, or `shared/`
- documentation that is inaccurate due to cleanup work

### Must read first

- current architecture docs
- the touched implementation area
- latest handoff notes

### Must update after finishing

- `docs/development/handoff.md`
- `docs/development/done-log.md`
- `docs/architecture/decisions.md` if boundaries changed materially

### Must never do

- alter product behavior under the label of cleanup
- merge unrelated refactors into feature delivery

## Documentation Integrator Model

### Purpose

Keeps the repository coherent as a working project memory system.

### Can change

- all documentation files
- lightweight structure notes in `Sources/Mindscape/`, `supabase/`, and `shared/`

### Must read first

- current docs across the affected area
- latest done log and handoff

### Must update after finishing

- any stale docs discovered during the task
- `docs/development/handoff.md`
- `docs/development/done-log.md`

### Must never do

- let docs drift from actual repo state
- fill files with generic placeholder text that does not help implementation
