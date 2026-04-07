# Release Process

## Goal

Keep release management lightweight but disciplined enough for a serious startup team.

## Branching Approach

- `main` should represent the current stable integration branch
- short-lived feature branches should be used for meaningful work
- pull requests should stay focused on one feature, fix, or document set

## Minimum Merge Expectations

- docs updated if behavior or scope changed
- tests or validation notes included
- no secrets committed
- reviewer can trace the change to a task, decision, or requirement

## Release Flow

1. merge validated work into `main`
2. cut a release candidate tag when the sprint scope is complete
3. run staging validation on auth, booking, payment, and session flows
4. fix blockers only
5. create production release tag
6. prepare App Store release notes and rollout plan

## Testing Before Release

- unit tests for critical domain logic
- integration validation for Supabase, MyFatoorah sandbox, and Agora token flow
- UI validation on core iOS flows
- manual smoke test on at least one realistic iPhone device and one simulator profile

## Store Preparation

- confirm app name, icon, screenshots, and short description
- confirm privacy policy and support contact requirements
- confirm signing and bundle configuration
- confirm version and build number update

## Tagging Convention

- release candidate: `v0.x.y-rc1`
- production release: `v0.x.y`

## Rollout Guidance

- start with controlled rollout when possible
- monitor booking, payment, and call failures closely during first releases
- keep a short post-release watch window for urgent fixes
