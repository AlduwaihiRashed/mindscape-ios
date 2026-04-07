# Supabase Workspace

This directory contains the first starter artifacts for Mindscape's Supabase-backed backend.

## What Exists

- `migrations/`: SQL migration drafts
- `rls-notes.md`: first-pass row-level security guidance
- executable schema and RLS policy migration drafts for the current MVP model
- guest-readable therapist catalog and availability policies for pre-auth discovery
- user-owned profile, booking, payment, and session read policies drafted for authenticated access
- profile bootstrap and booking draft/cancel SQL functions for the current Phase 0 backend-owned path
- local Supabase config, hosted migration/seed rollout, and edge-function scaffolding now exist in-repo

## Current Scope

- initial schema draft from `docs/architecture/database-schema.md`
- practical notes plus executable SQL for user, booking, payment, and session access rules

## Next Useful Steps

1. finish the real MyFatoorah initiation and callback flow in `start-myfatoorah` and `verify-myfatoorah`
2. resolve the hosted `start-myfatoorah` deployment/visibility gap and re-run the full hosted booking-to-token flow
3. replace provisional therapist titles, bios, and timing assumptions with final imported data
