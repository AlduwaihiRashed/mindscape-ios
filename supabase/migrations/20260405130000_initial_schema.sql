create extension if not exists pgcrypto;

create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    email text not null unique,
    phone text,
    full_name text,
    locale text not null default 'en-KW',
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.therapists (
    id uuid primary key default gen_random_uuid(),
    slug text not null unique,
    full_name text not null,
    title text,
    specialization text not null,
    bio text,
    languages text[] not null default '{}',
    session_modes text[] not null default '{}',
    price_fils integer not null check (price_fils >= 0),
    currency_code text not null default 'KWD',
    is_active boolean not null default true,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.therapist_availability_slots (
    id uuid primary key default gen_random_uuid(),
    therapist_id uuid not null references public.therapists(id) on delete cascade,
    starts_at timestamptz not null,
    ends_at timestamptz not null,
    status text not null check (status in ('available', 'held', 'booked', 'blocked')),
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now()),
    check (ends_at > starts_at)
);

create table if not exists public.bookings (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    therapist_id uuid not null references public.therapists(id) on delete restrict,
    availability_slot_id uuid not null references public.therapist_availability_slots(id) on delete restrict,
    booking_status text not null check (booking_status in ('pending_payment', 'confirmed', 'canceled', 'expired', 'completed')),
    session_mode text not null check (session_mode in ('video', 'audio')),
    price_fils integer not null check (price_fils >= 0),
    currency_code text not null default 'KWD',
    scheduled_starts_at timestamptz not null,
    scheduled_ends_at timestamptz not null,
    cancellation_reason text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now()),
    check (scheduled_ends_at > scheduled_starts_at)
);

create table if not exists public.payments (
    id uuid primary key default gen_random_uuid(),
    booking_id uuid not null references public.bookings(id) on delete cascade,
    provider text not null default 'myfatoorah',
    provider_payment_id text,
    payment_status text not null check (payment_status in ('initiated', 'pending', 'paid', 'failed', 'canceled', 'refunded')),
    amount_fils integer not null check (amount_fils >= 0),
    currency_code text not null default 'KWD',
    raw_callback_payload jsonb,
    paid_at timestamptz,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.sessions (
    id uuid primary key default gen_random_uuid(),
    booking_id uuid not null unique references public.bookings(id) on delete cascade,
    agora_channel_name text not null,
    session_status text not null check (session_status in ('scheduled', 'live', 'completed', 'canceled', 'failed')),
    join_allowed_from timestamptz,
    started_at timestamptz,
    ended_at timestamptz,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_therapist_availability_slots_therapist_id
    on public.therapist_availability_slots(therapist_id);

create index if not exists idx_bookings_user_id
    on public.bookings(user_id);

create index if not exists idx_bookings_therapist_id
    on public.bookings(therapist_id);

create index if not exists idx_payments_booking_id
    on public.payments(booking_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = timezone('utc', now());
    return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_therapists_updated_at on public.therapists;
create trigger set_therapists_updated_at
before update on public.therapists
for each row execute function public.set_updated_at();

drop trigger if exists set_therapist_availability_slots_updated_at on public.therapist_availability_slots;
create trigger set_therapist_availability_slots_updated_at
before update on public.therapist_availability_slots
for each row execute function public.set_updated_at();

drop trigger if exists set_bookings_updated_at on public.bookings;
create trigger set_bookings_updated_at
before update on public.bookings
for each row execute function public.set_updated_at();

drop trigger if exists set_payments_updated_at on public.payments;
create trigger set_payments_updated_at
before update on public.payments
for each row execute function public.set_updated_at();

drop trigger if exists set_sessions_updated_at on public.sessions;
create trigger set_sessions_updated_at
before update on public.sessions
for each row execute function public.set_updated_at();
