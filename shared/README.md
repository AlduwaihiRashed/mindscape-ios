# Shared Purpose

This folder is for cross-cutting project artifacts that are not owned by a single feature area.

## Intended Use

- stable domain model references
- shared constants and enums
- lightweight utility code that is genuinely cross-cutting

## Current Subfolders

- `constants/`: shared domain constants when implementation begins
- `models/`: shared domain model definitions only if they are broadly reused
- `utils/`: small reusable helpers, not a dumping ground

## Guardrails

- do not move feature-specific logic here just to reduce file count
- do not create vague helpers without clear reuse
- keep shared concepts aligned with `docs/architecture/*`
