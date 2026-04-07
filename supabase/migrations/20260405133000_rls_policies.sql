alter table public.profiles enable row level security;
alter table public.therapists enable row level security;
alter table public.therapist_availability_slots enable row level security;
alter table public.bookings enable row level security;
alter table public.payments enable row level security;
alter table public.sessions enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "therapists_select_active" on public.therapists;
create policy "therapists_select_active"
on public.therapists
for select
to anon, authenticated
using (is_active = true);

drop policy if exists "availability_select_active_therapists" on public.therapist_availability_slots;
create policy "availability_select_active_therapists"
on public.therapist_availability_slots
for select
to anon, authenticated
using (
    status = 'available'
    and
    exists (
        select 1
        from public.therapists
        where public.therapists.id = therapist_availability_slots.therapist_id
          and public.therapists.is_active = true
    )
);

drop policy if exists "bookings_select_own" on public.bookings;
create policy "bookings_select_own"
on public.bookings
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "bookings_insert_own" on public.bookings;
drop policy if exists "payments_select_linked_booking_owner" on public.payments;
create policy "payments_select_linked_booking_owner"
on public.payments
for select
to authenticated
using (
    exists (
        select 1
        from public.bookings
        where public.bookings.id = payments.booking_id
          and public.bookings.user_id = auth.uid()
    )
);

drop policy if exists "sessions_select_linked_booking_owner" on public.sessions;
create policy "sessions_select_linked_booking_owner"
on public.sessions
for select
to authenticated
using (
    exists (
        select 1
        from public.bookings
        where public.bookings.id = sessions.booking_id
          and public.bookings.user_id = auth.uid()
    )
);
