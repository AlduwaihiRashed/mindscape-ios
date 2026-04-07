-- Therapist and availability seed data derived from temp/therapists_db/*.csv.
-- Timings and some bios/titles are still provisional, so this keeps the current source values
-- while normalizing slugs and generating upcoming slot rows the app can book against.

delete from public.therapist_availability_slots
where therapist_id in (
    select id
    from public.therapists
    where slug in (
        'dr-dhai-alduwaihy',
        'dr-ahmed-nabeel',
        'ahmed-almullah',
        'latefa-alhadhoud',
        'eliana-zaar',
        'dr-hasan-arab',
        'nahed-farran',
        'shaimaa-allami',
        'rawaa-alali',
        'lulwa-aljasser',
        'mona-almutawtah',
        'mohammed-akbar'
    )
);

delete from public.therapists
where slug in (
    'dr-dhai-alduwaihy',
    'dr-ahmed-nabeel',
    'ahmed-almullah',
    'latefa-alhadhoud',
    'eliana-zaar',
    'dr-hasan-arab',
    'nahed-farran',
    'shaimaa-allami',
    'rawaa-alali',
    'lulwa-aljasser',
    'mona-almutawtah',
    'mohammed-akbar'
);

with therapist_source as (
    select *
    from (
        values
            (1, 'Dr. Dhai Alduwaihy ', 'dr-dhai-alduwaihy', 'Clinical Psychologist', 'Anxiety, trauma, and emotional resilience,Dhai blends evidence-based trauma care with a warm, grounding style that helps clients feel safe enough to move forward at their own pace.', 'en | ar', 'video | audio | chat', 24000, 'KWD', true),
            (2, 'dr. Ahmed Nabeel ', 'dr-ahmed-nabeel', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (3, ' Ahmed Almullah', 'ahmed-almullah', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (4, 'Latefa Alhadhoud', 'latefa-alhadhoud', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (5, 'Eliana Zaar ', 'eliana-zaar ', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (6, 'Dr. Hasan Arab ', 'dr-hasan-arab ', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (7, 'Nahed Farran', 'nahed-farran', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (8, 'Shaimaa Allami ', 'shaimaa-allami', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (9, 'Rawaa Alali ', 'Rawaa-alali ', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (10, 'Lulwa Aljasser ', 'lulwa-aljasser ', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (11, 'Mona Almutawtah ', 'mona-almutawtah', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true),
            (12, 'Mohammed Akbar ', 'mohammed-akbar ', 'should be title...', 'should be bio...', 'en | ar', 'video | audio | chat', 10000, 'KWD', true)
    ) as t(csv_order, full_name, slug, title, bio, languages, session_modes, price_fils, currency_code, is_active)
),
normalized_therapists as (
    select
        lower(trim(slug)) as slug,
        trim(full_name) as full_name,
        nullif(trim(title), '') as title,
        case
            when lower(trim(slug)) = 'dr-dhai-alduwaihy' then 'Anxiety, trauma, and emotional resilience'
            when bio ilike 'should be bio%' then 'Support session'
            else 'Support session'
        end as specialization,
        nullif(trim(bio), '') as bio,
        array_remove(regexp_split_to_array(regexp_replace(trim(languages), '\s*\|\s*', '|', 'g'), '\|'), '') as languages,
        array_remove(regexp_split_to_array(regexp_replace(trim(session_modes), '\s*\|\s*', '|', 'g'), '\|'), '') as session_modes,
        price_fils,
        currency_code,
        is_active,
        csv_order
    from therapist_source
),
inserted_therapists as (
    insert into public.therapists (
        slug,
        full_name,
        title,
        specialization,
        bio,
        languages,
        session_modes,
        price_fils,
        currency_code,
        is_active
    )
    select
        slug,
        full_name,
        title,
        specialization,
        bio,
        languages,
        session_modes,
        price_fils,
        currency_code,
        is_active
    from normalized_therapists
    order by csv_order
    returning id, slug
),
availability_source as (
    select *
    from (
        values
            (1, 'dr-ahmed-nabeel', '08:00'::time, '11:00'::time),
            (2, 'ahmed-almullah', '08:00'::time, '11:00'::time),
            (3, 'latefa-alhadhoud', '08:00'::time, '11:00'::time),
            (4, 'eliana-zaar ', '08:00'::time, '11:00'::time),
            (5, 'dr-hasan-arab ', '08:00'::time, '11:00'::time),
            (6, 'nahed-farran', '08:00'::time, '11:00'::time),
            (7, 'shaimaa-allami', '08:00'::time, '11:00'::time),
            (8, 'Rawaa-alali ', '08:00'::time, '11:00'::time),
            (9, 'lulwa-aljasser ', '08:00'::time, '11:00'::time),
            (10, 'mona-almutawtah', '08:00'::time, '11:00'::time),
            (11, 'mohammed-akbar ', '08:00'::time, '11:00'::time)
    ) as t(csv_order, slug, starts_at, ends_at)
),
normalized_availability as (
    select
        lower(trim(slug)) as slug,
        starts_at,
        ends_at,
        csv_order
    from availability_source
),
slot_days as (
    select generate_series(
        timezone('Asia/Kuwait', now())::date,
        timezone('Asia/Kuwait', now())::date + 13,
        interval '1 day'
    )::date as slot_day
),
generated_slots as (
    select
        therapists.id as therapist_id,
        slot_start as starts_at,
        slot_start + interval '50 minutes' as ends_at,
        availability.csv_order
    from normalized_availability availability
    join inserted_therapists therapists on therapists.slug = availability.slug
    cross join slot_days
    cross join lateral generate_series(
        (slot_days.slot_day::timestamp + availability.starts_at) at time zone 'Asia/Kuwait',
        (slot_days.slot_day::timestamp + availability.ends_at - interval '1 hour') at time zone 'Asia/Kuwait',
        interval '1 hour'
    ) as slot_start
)
insert into public.therapist_availability_slots (
    therapist_id,
    starts_at,
    ends_at,
    status
)
select
    therapist_id,
    starts_at,
    ends_at,
    'available'
from generated_slots
order by csv_order, starts_at;
