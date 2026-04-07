alter table public.bookings
    add column if not exists expires_at timestamptz;

create index if not exists idx_bookings_availability_slot_id
    on public.bookings(availability_slot_id);

create index if not exists idx_bookings_expires_at
    on public.bookings(expires_at);

drop policy if exists "availability_select_active_therapists" on public.therapist_availability_slots;
create policy "availability_select_active_therapists"
on public.therapist_availability_slots
for select
to anon, authenticated
using (
    status = 'available'
    and exists (
        select 1
        from public.therapists
        where public.therapists.id = therapist_availability_slots.therapist_id
          and public.therapists.is_active = true
    )
    and not exists (
        select 1
        from public.bookings
        where public.bookings.availability_slot_id = therapist_availability_slots.id
          and (
              public.bookings.booking_status = 'confirmed'
              or public.bookings.booking_status = 'completed'
              or (
                  public.bookings.booking_status = 'pending_payment'
                  and coalesce(public.bookings.expires_at, timezone('utc', now()) + interval '1 second') > timezone('utc', now())
              )
          )
    )
);

drop policy if exists "bookings_insert_own" on public.bookings;

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
begin
    insert into public.profiles (
        id,
        email,
        phone,
        full_name,
        locale
    )
    values (
        new.id,
        coalesce(new.email, ''),
        new.phone,
        nullif(trim(coalesce(new.raw_user_meta_data ->> 'full_name', '')), ''),
        'en-KW'
    )
    on conflict (id) do update
    set email = excluded.email,
        phone = coalesce(excluded.phone, public.profiles.phone),
        full_name = coalesce(excluded.full_name, public.profiles.full_name);

    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

create or replace function public.ensure_profile_exists()
returns public.profiles
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    v_user_id uuid := auth.uid();
    v_user auth.users%rowtype;
    v_profile public.profiles%rowtype;
begin
    if v_user_id is null then
        raise exception 'Authentication required.' using errcode = 'P0001';
    end if;

    select *
    into v_profile
    from public.profiles
    where id = v_user_id;

    if found then
        return v_profile;
    end if;

    select *
    into v_user
    from auth.users
    where id = v_user_id;

    if not found then
        raise exception 'Authenticated user was not found.' using errcode = 'P0001';
    end if;

    insert into public.profiles (
        id,
        email,
        phone,
        full_name,
        locale
    )
    values (
        v_user.id,
        coalesce(v_user.email, ''),
        v_user.phone,
        nullif(trim(coalesce(v_user.raw_user_meta_data ->> 'full_name', '')), ''),
        'en-KW'
    )
    on conflict (id) do update
    set email = excluded.email,
        phone = coalesce(excluded.phone, public.profiles.phone),
        full_name = coalesce(excluded.full_name, public.profiles.full_name)
    returning * into v_profile;

    return v_profile;
end;
$$;

create or replace function public.create_booking_draft(
    p_therapist_id uuid,
    p_availability_slot_id uuid,
    p_session_mode text
)
returns public.bookings
language plpgsql
security definer
set search_path = public
as $$
declare
    v_user_id uuid := auth.uid();
    v_therapist public.therapists%rowtype;
    v_slot public.therapist_availability_slots%rowtype;
    v_booking public.bookings%rowtype;
    v_hold_window interval := interval '15 minutes';
begin
    if v_user_id is null then
        raise exception 'Authentication required.' using errcode = 'P0001';
    end if;

    if p_session_mode not in ('video', 'audio') then
        raise exception 'Unsupported session mode.' using errcode = 'P0001';
    end if;

    perform public.ensure_profile_exists();

    select *
    into v_therapist
    from public.therapists
    where id = p_therapist_id
      and is_active = true;

    if not found then
        raise exception 'Therapist not found.' using errcode = 'P0001';
    end if;

    if not (p_session_mode = any(v_therapist.session_modes)) then
        raise exception 'Selected session mode is not available for this therapist.' using errcode = 'P0001';
    end if;

    select *
    into v_slot
    from public.therapist_availability_slots
    where id = p_availability_slot_id
      and therapist_id = p_therapist_id
      and status = 'available'
      and starts_at > timezone('utc', now());

    if not found then
        raise exception 'Selected slot is no longer available.' using errcode = 'P0001';
    end if;

    if exists (
        select 1
        from public.bookings existing_booking
        where existing_booking.availability_slot_id = p_availability_slot_id
          and (
              existing_booking.booking_status = 'confirmed'
              or existing_booking.booking_status = 'completed'
              or (
                  existing_booking.booking_status = 'pending_payment'
                  and coalesce(existing_booking.expires_at, timezone('utc', now()) + interval '1 second') > timezone('utc', now())
              )
          )
    ) then
        raise exception 'Selected slot is no longer available.' using errcode = 'P0001';
    end if;

    insert into public.bookings (
        user_id,
        therapist_id,
        availability_slot_id,
        booking_status,
        session_mode,
        price_fils,
        currency_code,
        scheduled_starts_at,
        scheduled_ends_at,
        expires_at
    )
    values (
        v_user_id,
        p_therapist_id,
        p_availability_slot_id,
        'pending_payment',
        p_session_mode,
        v_therapist.price_fils,
        v_therapist.currency_code,
        v_slot.starts_at,
        v_slot.ends_at,
        timezone('utc', now()) + v_hold_window
    )
    returning * into v_booking;

    return v_booking;
end;
$$;

create or replace function public.cancel_booking(
    p_booking_id uuid,
    p_reason text default null
)
returns public.bookings
language plpgsql
security definer
set search_path = public
as $$
declare
    v_user_id uuid := auth.uid();
    v_booking public.bookings%rowtype;
begin
    if v_user_id is null then
        raise exception 'Authentication required.' using errcode = 'P0001';
    end if;

    update public.bookings
    set booking_status = 'canceled',
        cancellation_reason = coalesce(nullif(trim(coalesce(p_reason, '')), ''), 'canceled_by_user')
    where id = p_booking_id
      and user_id = v_user_id
      and booking_status in ('pending_payment', 'confirmed')
      and scheduled_starts_at > timezone('utc', now())
    returning * into v_booking;

    if not found then
        raise exception 'Booking cannot be canceled.' using errcode = 'P0001';
    end if;

    return v_booking;
end;
$$;

grant execute on function public.ensure_profile_exists() to authenticated;
grant execute on function public.create_booking_draft(uuid, uuid, text) to authenticated;
grant execute on function public.cancel_booking(uuid, text) to authenticated;
