# RLS Notes

These notes are intentionally policy-oriented rather than final SQL.

## Policy Goals

- users can access only their own profile and booking data
- therapist catalog visibility should stay broader than user-private records
- payment verification and session token issuance remain privileged server operations

## Table Notes

### `profiles`

- authenticated users can `select` their own row where `auth.uid() = id`
- authenticated users can `update` their own editable fields only
- inserts should be handled by signup bootstrap or trusted function for missing historical rows

### `therapists`

- authenticated users can `select` active therapist rows
- if discovery becomes public later, expose a safe view or public read policy only for non-sensitive fields
- writes should remain service-role or operations-only in MVP

### `therapist_availability_slots`

- authenticated users can `select` bookable availability for active therapists
- writes should remain privileged to avoid slot manipulation from the client

### `bookings`

- authenticated users can `select` rows where `user_id = auth.uid()`
- booking draft creation should happen through RPC or equivalent trusted function only
- status updates after payment should happen through trusted backend logic, not broad client write access
- availability reads should hide slots covered by active pending-payment holds or confirmed bookings

### `payments`

- authenticated users can `select` payments only through ownership of the linked booking
- inserts and updates should be backend-only because payment verification is authoritative server work

### `sessions`

- authenticated users can `select` sessions only through ownership of the linked booking
- writes should be restricted to trusted backend flows

## Open Policy Decisions

1. whether therapist discovery is public before sign-in
2. how expired pending-payment holds are promoted to `expired` operationally
