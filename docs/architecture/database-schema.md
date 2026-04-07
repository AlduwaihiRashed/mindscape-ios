# Database Schema

This is a first-pass domain schema for Supabase Postgres. It is intentionally practical rather than exhaustive.

## Identity And Auth

### `auth.users`

Managed by Supabase Auth.

### `profiles`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid | primary key, matches `auth.users.id` |
| `email` | text | normalized email |
| `phone` | text nullable | optional until auth strategy is finalized |
| `full_name` | text nullable | display name |
| `locale` | text | default `en-KW` |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

## Therapist Domain

### `therapists`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid | primary key |
| `slug` | text | unique public identifier |
| `full_name` | text | |
| `title` | text nullable | for display |
| `specialization` | text | first pass as text; can normalize later |
| `bio` | text nullable | short profile copy |
| `languages` | text[] | for example `en`, `ar` |
| `session_modes` | text[] | `video`, `audio` |
| `price_fils` | integer | stored in minor unit |
| `currency_code` | text | expected `KWD` |
| `is_active` | boolean | catalog visibility |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

### `therapist_availability_slots`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid | primary key |
| `therapist_id` | uuid | references `therapists.id` |
| `starts_at` | timestamptz | |
| `ends_at` | timestamptz | |
| `status` | text | `available`, `held`, `booked`, `blocked` |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

## Booking Domain

### `bookings`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid | primary key |
| `user_id` | uuid | references `profiles.id` |
| `therapist_id` | uuid | references `therapists.id` |
| `availability_slot_id` | uuid | references `therapist_availability_slots.id` |
| `booking_status` | text | `pending_payment`, `confirmed`, `canceled`, `expired`, `completed` |
| `session_mode` | text | `video` or `audio` |
| `price_fils` | integer | captured at booking time |
| `currency_code` | text | `KWD` |
| `scheduled_starts_at` | timestamptz | denormalized for simpler reads |
| `scheduled_ends_at` | timestamptz | |
| `expires_at` | timestamptz nullable | used for temporary pending-payment holds |
| `cancellation_reason` | text nullable | |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

## Payment Domain

### `payments`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid | primary key |
| `booking_id` | uuid | references `bookings.id` |
| `provider` | text | `myfatoorah` |
| `provider_payment_id` | text nullable | payment reference |
| `payment_status` | text | `initiated`, `pending`, `paid`, `failed`, `canceled`, `refunded` |
| `amount_fils` | integer | |
| `currency_code` | text | `KWD` |
| `raw_callback_payload` | jsonb nullable | kept carefully and minimally |
| `paid_at` | timestamptz nullable | |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

## Session Domain

### `sessions`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | uuid | primary key |
| `booking_id` | uuid | unique reference to `bookings.id` |
| `agora_channel_name` | text | generated server-side |
| `session_status` | text | `scheduled`, `live`, `completed`, `canceled`, `failed` |
| `join_allowed_from` | timestamptz nullable | policy-controlled |
| `started_at` | timestamptz nullable | |
| `ended_at` | timestamptz nullable | |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

## Optional Later Table

### `reviews`

Not required for initial MVP. Add only when product scope expands.

## Relationship Summary

- one `auth.users` record maps to one `profiles` record
- one therapist has many availability slots
- one user has many bookings
- one therapist has many bookings
- one booking has many payment attempts over time if retries are allowed
- one booking has one session record in MVP

## Row-Level Security Notes

- users can read and update only their own `profiles` row
- users can read only their own `bookings`, linked `payments`, and linked `sessions`
- therapist catalog tables should be publicly readable for active rows in MVP so guests can browse before auth
- payment verification and session token issuance should bypass user-level writes through privileged backend functions only

## Open Schema Decisions

1. whether therapist availability should be stored as discrete slots only or support generated recurring rules
2. how expired pending-payment bookings are promoted to `expired` operationally after the hold window elapses
3. whether therapist identity should link to a future therapist-auth table or remain operations-managed initially

## Assumptions

- Assumption: each booking is for exactly one therapist and one scheduled session.
- Assumption: paid session price is stored on the booking for audit stability even if therapist pricing changes later.
- Assumption: callback payload storage will be minimized to avoid retaining unnecessary sensitive provider data.
- Assumption: booking drafts can reserve a slot for a short pending-payment hold window before payment verification completes.
