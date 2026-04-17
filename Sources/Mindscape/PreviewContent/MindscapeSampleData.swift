import Foundation

enum MindscapeSampleData {
    static let therapists: [TherapistSummary] = [
        TherapistSummary(
            id: "t-1",
            fullName: "Dr. Sara Al-Harbi",
            credentials: "Clinical Psychologist",
            specialization: "Anxiety, trauma, and emotional resilience",
            specializationTags: ["PTSD", "Anxiety", "Burnout"],
            languages: ["English", "Arabic"],
            sessionModes: [.video, .audio],
            priceLabel: "From 26 KWD",
            sessionDurationMinutes: 50,
            rating: 4.9,
            sessionsCompleted: 420,
            bio: "Sara blends evidence-based trauma care with a warm, grounding style that helps clients feel safe enough to move forward at their own pace.",
            availabilityLabel: "Available now",
            isAvailableNow: true,
            initials: "SA"
        ),
        TherapistSummary(
            id: "t-2",
            fullName: "Dr. Lina Noor",
            credentials: "Counselling Therapist",
            specialization: "Relationships, boundaries, and self-worth",
            specializationTags: ["Relationships", "Stress", "Confidence"],
            languages: ["English"],
            sessionModes: [.video, .audio],
            priceLabel: "From 24 KWD",
            sessionDurationMinutes: 45,
            rating: 4.8,
            sessionsCompleted: 316,
            bio: "Lina supports adults navigating emotionally heavy seasons, with sessions that feel clear, compassionate, and forward-looking.",
            availabilityLabel: "Next today",
            isAvailableNow: true,
            initials: "LN"
        ),
        TherapistSummary(
            id: "t-3",
            fullName: "Dr. Omar Haddad",
            credentials: "Psychotherapist",
            specialization: "OCD, panic cycles, and intrusive thoughts",
            specializationTags: ["OCD", "Panic", "Sleep"],
            languages: ["English", "French"],
            sessionModes: [.video],
            priceLabel: "From 29 KWD",
            sessionDurationMinutes: 60,
            rating: 4.7,
            sessionsCompleted: 502,
            bio: "Omar offers structured, reassuring sessions for people who want practical support and steady emotional regulation tools.",
            availabilityLabel: "Tomorrow",
            isAvailableNow: false,
            initials: "OH"
        ),
        TherapistSummary(
            id: "t-4",
            fullName: "Dr. Maya Rahman",
            credentials: "Mindfulness Therapist",
            specialization: "Stress recovery, grief, and life transitions",
            specializationTags: ["Stress", "Grief", "Transitions"],
            languages: ["English", "Arabic", "Hindi"],
            sessionModes: [.video, .audio],
            priceLabel: "From 22 KWD",
            sessionDurationMinutes: 50,
            rating: 4.9,
            sessionsCompleted: 268,
            bio: "Maya creates grounded, reflective sessions for clients looking to slow down, reconnect with themselves, and rebuild capacity gently.",
            availabilityLabel: "Available this evening",
            isAvailableNow: false,
            initials: "MR"
        )
    ]

    static let concerns: [Concern] = [
        Concern(id: "c1", label: "PTSD"),
        Concern(id: "c2", label: "Anxiety"),
        Concern(id: "c3", label: "Stress"),
        Concern(id: "c4", label: "OCD"),
        Concern(id: "c5", label: "Burnout"),
        Concern(id: "c6", label: "Relationships"),
        Concern(id: "c7", label: "Sleep"),
        Concern(id: "c8", label: "Grief")
    ]

    static let upcomingAppointments: [AppointmentSummary] = [
        AppointmentSummary(
            id: "a1",
            therapistId: "t-1",
            therapistName: "Dr. Sara Al-Harbi",
            therapistInitials: "SA",
            focusArea: "Stress reset session",
            dateLabel: "Tue, 16 Apr",
            timeLabel: "6:30 PM",
            status: .confirmed,
            actionLabel: "Join session",
            mode: .video,
            canCancel: true,
            priceLabel: "26 KWD",
            paymentStatusCode: "paid",
            paymentStatus: "Paid",
            sessionStatusCode: "scheduled",
            sessionStatus: "Scheduled"
        ),
        AppointmentSummary(
            id: "a2",
            therapistId: "t-2",
            therapistName: "Dr. Lina Noor",
            therapistInitials: "LN",
            focusArea: "Relationship patterns",
            dateLabel: "Fri, 19 Apr",
            timeLabel: "1:00 PM",
            status: .pendingPayment,
            actionLabel: "Complete payment",
            mode: .video,
            canCancel: true,
            priceLabel: "24 KWD",
            holdExpiresAtLabel: "Expires in 14 min"
        )
    ]

    static let pastAppointments: [AppointmentSummary] = [
        AppointmentSummary(
            id: "a3",
            therapistId: "t-4",
            therapistName: "Dr. Maya Rahman",
            therapistInitials: "MR",
            focusArea: "Life transition check-in",
            dateLabel: "Mon, 08 Apr",
            timeLabel: "8:00 PM",
            status: .completed,
            actionLabel: "Rebook",
            mode: .audio,
            canCancel: false,
            priceLabel: "22 KWD",
            paymentStatusCode: "paid",
            paymentStatus: "Paid",
            sessionStatusCode: "completed",
            sessionStatus: "Completed"
        ),
        AppointmentSummary(
            id: "a4",
            therapistId: "t-3",
            therapistName: "Dr. Omar Haddad",
            therapistInitials: "OH",
            focusArea: "Panic response plan",
            dateLabel: "Wed, 03 Apr",
            timeLabel: "4:00 PM",
            status: .completed,
            actionLabel: "Rebook",
            mode: .video,
            canCancel: false,
            priceLabel: "29 KWD",
            paymentStatusCode: "paid",
            paymentStatus: "Paid",
            sessionStatusCode: "completed",
            sessionStatus: "Completed"
        )
    ]

    static let notes: [ReflectionNote] = [
        ReflectionNote(id: "n1", title: "What felt lighter this week", excerpt: "I noticed I paused before reacting and came back to my breath instead of spiraling.", createdAt: "Today"),
        ReflectionNote(id: "n2", title: "After session reflection", excerpt: "The idea of a smaller next step felt much kinder than trying to fix everything at once.", createdAt: "2 days ago")
    ]

    static let journeyMetrics: [JourneyMetric] = [
        JourneyMetric(label: "Grounding streak", value: "12 days", supportText: "A steady rhythm is forming"),
        JourneyMetric(label: "Mood trend", value: "+18%", supportText: "Compared with last month"),
        JourneyMetric(label: "Sessions completed", value: "8", supportText: "Consistent support is showing up")
    ]

    static let reflectionPrompts: [ReflectionPrompt] = [
        ReflectionPrompt(id: "p1", prompt: "What helped you feel safest this week?"),
        ReflectionPrompt(id: "p2", prompt: "What boundary protected your energy recently?"),
        ReflectionPrompt(id: "p3", prompt: "What does support look like for you today?")
    ]

    static let wellnessTrends: [WellnessTrend] = [
        WellnessTrend(label: "Mon", value: 5),
        WellnessTrend(label: "Tue", value: 6),
        WellnessTrend(label: "Wed", value: 4),
        WellnessTrend(label: "Thu", value: 7),
        WellnessTrend(label: "Fri", value: 8),
        WellnessTrend(label: "Sat", value: 7),
        WellnessTrend(label: "Sun", value: 9)
    ]

    static let sessionInsights: [SessionInsight] = [
        SessionInsight(title: "Recent insight", summary: "You are more regulated when you name your needs early, rather than waiting until you are overwhelmed."),
        SessionInsight(title: "Therapist note", summary: "Keep your evening wind-down simple: dim lights, one page of journaling, then no screens for ten minutes.")
    ]

    static let sessionTypes: [SessionTypeOption] = [
        SessionTypeOption(id: "video", title: "Video session", subtitle: "Face-to-face guided support", supportingText: "A fuller appointment with visual connection."),
        SessionTypeOption(id: "audio", title: "Audio session", subtitle: "Low-pressure voice only session", supportingText: "Great when you want privacy and calm focus.")
    ]

    static let bookingDates: [BookingDateOption] = [
        BookingDateOption(id: "d1", dayLabel: "Today", dateLabel: "14 Apr"),
        BookingDateOption(id: "d2", dayLabel: "Tue", dateLabel: "15 Apr"),
        BookingDateOption(id: "d3", dayLabel: "Wed", dateLabel: "16 Apr"),
        BookingDateOption(id: "d4", dayLabel: "Thu", dateLabel: "17 Apr"),
        BookingDateOption(id: "d5", dayLabel: "Fri", dateLabel: "18 Apr")
    ]

    static let bookingTimes: [BookingTimeOption] = [
        BookingTimeOption(id: "t1", timeLabel: "10:30 AM", isPopular: false),
        BookingTimeOption(id: "t2", timeLabel: "12:00 PM", isPopular: true),
        BookingTimeOption(id: "t3", timeLabel: "2:30 PM", isPopular: false),
        BookingTimeOption(id: "t4", timeLabel: "5:00 PM", isPopular: true),
        BookingTimeOption(id: "t5", timeLabel: "7:30 PM", isPopular: false)
    ]

    static let sampleAvailabilitySlots: [TherapistAvailabilitySlot] = [
        TherapistAvailabilitySlot(id: "slot-1", therapistId: "t-1", startsAt: "2026-04-14T10:30:00+03:00", endsAt: "2026-04-14T11:20:00+03:00", dayKey: "2026-04-14", dayLabel: "Today", dateLabel: "14 Apr", timeLabel: "10:30 AM"),
        TherapistAvailabilitySlot(id: "slot-2", therapistId: "t-1", startsAt: "2026-04-15T12:00:00+03:00", endsAt: "2026-04-15T12:50:00+03:00", dayKey: "2026-04-15", dayLabel: "Tue", dateLabel: "15 Apr", timeLabel: "12:00 PM"),
        TherapistAvailabilitySlot(id: "slot-3", therapistId: "t-2", startsAt: "2026-04-15T17:00:00+03:00", endsAt: "2026-04-15T17:45:00+03:00", dayKey: "2026-04-15", dayLabel: "Tue", dateLabel: "15 Apr", timeLabel: "5:00 PM"),
        TherapistAvailabilitySlot(id: "slot-4", therapistId: "t-3", startsAt: "2026-04-16T19:30:00+03:00", endsAt: "2026-04-16T20:30:00+03:00", dayKey: "2026-04-16", dayLabel: "Wed", dateLabel: "16 Apr", timeLabel: "7:30 PM"),
        TherapistAvailabilitySlot(id: "slot-5", therapistId: "t-4", startsAt: "2026-04-17T14:30:00+03:00", endsAt: "2026-04-17T15:20:00+03:00", dayKey: "2026-04-17", dayLabel: "Thu", dateLabel: "17 Apr", timeLabel: "2:30 PM")
    ]

    static let sampleGroupSessions: [TherapistGroupSession] = [
        TherapistGroupSession(
            id: "gs-1",
            therapistId: "t-1",
            title: "Anxiety Management Circle",
            description: "A guided group session for building tools to manage day-to-day anxiety in a supportive, confidential space.",
            sessionMode: "video",
            startsAt: "2026-04-18T18:00:00+03:00",
            endsAt: "2026-04-18T19:00:00+03:00",
            dayKey: "2026-04-18",
            dayLabel: "Fri",
            dateLabel: "18 Apr",
            timeLabel: "6:00 PM",
            maxParticipants: 6
        ),
        TherapistGroupSession(
            id: "gs-2",
            therapistId: "t-4",
            title: "Grief Support Group",
            description: "A compassionate space to process loss alongside others who understand what it means to grieve.",
            sessionMode: "video",
            startsAt: "2026-04-19T20:00:00+03:00",
            endsAt: "2026-04-19T21:00:00+03:00",
            dayKey: "2026-04-19",
            dayLabel: "Sat",
            dateLabel: "19 Apr",
            timeLabel: "8:00 PM",
            maxParticipants: 8
        )
    ]

    static let quotes: [QuoteCard] = [
        QuoteCard(id: "q1", text: "Healing often begins with one gentle, honest moment.", author: nil),
        QuoteCard(id: "q2", text: "You do not have to be perfect to deserve rest.", author: "Unknown"),
        QuoteCard(id: "q3", text: "Progress is still progress, even when it is quiet.", author: nil),
        QuoteCard(id: "q4", text: "The bravest thing you can do is ask for help.", author: nil),
        QuoteCard(id: "q5", text: "Small steps are still steps forward.", author: nil)
    ]

    static let homeSnapshot = HomeUISnapshot(
        quote: "Healing often begins with one gentle, honest moment.",
        journeyHeadline: "Your pace is enough",
        journeySupport: "Small steps still count. Keep building steady support around you."
    )

    static let profile = UserProfile(
        id: "u-1",
        email: "hello@mindscape.app",
        fullName: "Mindscape Guest",
        phone: nil,
        locale: "en-KW"
    )
}
