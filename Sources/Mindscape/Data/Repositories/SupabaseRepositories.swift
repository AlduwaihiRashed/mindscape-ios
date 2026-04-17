import Foundation
import Supabase

// MARK: - Auth

struct SupabaseAuthRepository: AuthRepository {
    let supabase: SupabaseClient

    func currentSession() async throws -> UserSession? {
        try await currentSessionOrNil()
    }

    func signIn(email: String, password: String) async throws -> UserSession {
        _ = try await supabase.auth.signIn(email: email, password: password)

        guard let session = try await currentSessionOrNil() else {
            throw SupabaseRepositoryError(message: "Sign-in finished, but no active session was returned.")
        }

        return session
    }

    func signUp(email: String, password: String, fullName: String?) async throws -> String {
        let trimmedFullName = fullName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let metadata = trimmedFullName?.isEmpty == false ? ["full_name": trimmedFullName!] : nil

        _ = try await supabase.auth.signUp(email: email, password: password, data: metadata)

        if try await currentSessionOrNil() != nil {
            return "Account created. You're signed in."
        }

        return "Account created. Check your email to confirm your account before signing in."
    }

    func resetPassword(email: String) async throws -> String {
        try await supabase.auth.resetPasswordForEmail(email)
        return "Password reset instructions were sent if the account exists."
    }

    func signOut() async throws {
        try? await supabase.auth.signOut()
    }

    private func currentSessionOrNil() async throws -> UserSession? {
        guard let user = try? await supabase.auth.user() else { return nil }

        let profile = try? await fetchProfile(userID: user.id.uuidString)
        let fullName = profile?.fullName
            ?? metadataFullName(user.userMetadata)
            ?? user.email?.split(separator: "@").first.map { String($0).capitalized }

        return UserSession(
            userId: user.id.uuidString,
            email: profile?.email ?? user.email ?? "",
            fullName: fullName
        )
    }

    private func fetchProfile(userID: String) async throws -> ProfileDTO? {
        try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userID)
            .limit(1)
            .single()
            .execute()
            .value
    }

    private func metadataFullName(_ metadata: [String: AnyJSON]?) -> String? {
        guard case let .string(value) = metadata?["full_name"] else { return nil }
        return value
    }
}

// MARK: - Profile

struct SupabaseProfileRepository: ProfileRepository {
    let supabase: SupabaseClient

    func getMe() async throws -> UserProfile? {
        guard let user = try? await supabase.auth.user() else { return nil }

        if let profile = try? await fetchProfile(userID: user.id.uuidString) {
            return profile.toDomain()
        }

        if let profile = try? await ensureProfileExists() {
            return profile
        }

        return UserProfile(
            id: user.id.uuidString,
            email: user.email ?? "",
            fullName: metadataFullName(user.userMetadata),
            phone: nil,
            locale: "en-KW"
        )
    }

    func updateLocale(_ locale: String) async throws -> UserProfile {
        guard let user = try? await supabase.auth.user() else {
            throw SupabaseRepositoryError(message: "You need to sign in first.")
        }

        _ = try? await ensureProfileExists()

        let updated: ProfileDTO = try await supabase
            .from("profiles")
            .update(ProfileUpdateDTO(locale: locale, fullName: nil, phone: nil))
            .eq("id", value: user.id.uuidString)
            .select()
            .single()
            .execute()
            .value

        return updated.toDomain()
    }

    func updateProfile(fullName: String, phone: String?) async throws -> UserProfile {
        guard let user = try? await supabase.auth.user() else {
            throw SupabaseRepositoryError(message: "You need to sign in first.")
        }

        _ = try? await ensureProfileExists()

        let updated: ProfileDTO = try await supabase
            .from("profiles")
            .update(ProfileUpdateDTO(locale: nil, fullName: fullName.nilIfBlank, phone: phone?.nilIfBlank))
            .eq("id", value: user.id.uuidString)
            .select()
            .single()
            .execute()
            .value

        return updated.toDomain()
    }

    private func fetchProfile(userID: String) async throws -> ProfileDTO {
        try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userID)
            .limit(1)
            .single()
            .execute()
            .value
    }

    private func ensureProfileExists() async throws -> UserProfile {
        do {
            let ensured: ProfileDTO = try await supabase
                .rpc("ensure_profile_exists")
                .execute()
                .value

            return ensured.toDomain()
        } catch {
            guard let user = try? await supabase.auth.user() else {
                throw SupabaseRepositoryError(message: "You need to sign in first.")
            }

            let inserted: ProfileDTO = try await supabase
                .from("profiles")
                .insert(ProfileInsertDTO(
                    id: user.id.uuidString,
                    email: user.email ?? "",
                    fullName: metadataFullName(user.userMetadata),
                    phone: nil,
                    locale: "en-KW"
                ))
                .select()
                .single()
                .execute()
                .value

            return inserted.toDomain()
        }
    }

    private func metadataFullName(_ metadata: [String: AnyJSON]?) -> String? {
        guard case let .string(value) = metadata?["full_name"] else { return nil }
        return value
    }
}

// MARK: - Therapist

struct SupabaseTherapistRepository: TherapistRepository {
    let supabase: SupabaseClient

    func listTherapists() async throws -> [TherapistSummary] {
        let therapists = try await listActiveTherapists()
        guard !therapists.isEmpty else { return [] }

        let availabilityByTherapist = Dictionary(
            grouping: try await listAvailabilityDTOs(therapistIDs: therapists.map(\.id)),
            by: \.therapistId
        )
        return therapists.map { $0.toSummary(slots: availabilityByTherapist[$0.id] ?? []) }
    }

    func getTherapistById(_ id: String) async throws -> TherapistSummary? {
        guard !id.isEmpty else { return nil }

        let therapists: [TherapistDTO] = try await supabase
            .from("therapists")
            .select()
            .eq("id", value: id)
            .eq("is_active", value: true)
            .execute()
            .value

        guard let therapist = therapists.first else { return nil }

        return therapist.toSummary(slots: try await listAvailabilityDTOs(therapistIDs: [id]))
    }

    func listAvailabilitySlots(therapistId: String) async throws -> [TherapistAvailabilitySlot] {
        guard !therapistId.isEmpty else { return [] }
        return try await listAvailabilityDTOs(therapistIDs: [therapistId]).compactMap(\.toAvailabilitySlot)
    }

    func listGroupSessions(therapistId: String) async throws -> [TherapistGroupSession] {
        guard !therapistId.isEmpty else { return [] }

        let groupSessions: [GroupSessionDTO] = try await supabase
            .from("group_sessions")
            .select()
            .eq("therapist_id", value: therapistId)
            .in("session_status", values: ["scheduled", "live"])
            .order("scheduled_starts_at")
            .execute()
            .value

        return groupSessions.compactMap(\.toGroupSession)
    }

    private func listActiveTherapists() async throws -> [TherapistDTO] {
        try await supabase
            .from("therapists")
            .select()
            .eq("is_active", value: true)
            .order("full_name")
            .execute()
            .value
    }

    private func listAvailabilityDTOs(therapistIDs: [String]) async throws -> [AvailabilitySlotDTO] {
        guard !therapistIDs.isEmpty else { return [] }

        return try await supabase
            .from("therapist_availability_slots")
            .select()
            .eq("status", value: "available")
            .in("therapist_id", values: therapistIDs)
            .order("starts_at")
            .execute()
            .value
    }
}

// MARK: - Booking

struct SupabaseBookingRepository: BookingRepository {
    let supabase: SupabaseClient
    let supabaseURL: String
    let publishableKey: String

    func listMine() async throws -> [AppointmentSummary] {
        guard (try? await supabase.auth.user()) != nil else { return [] }

        let bookings: [BookingDTO] = try await supabase
            .from("bookings")
            .select()
            .order("scheduled_starts_at")
            .execute()
            .value

        return try await mapAppointments(bookings)
    }

    func getById(_ bookingId: String) async throws -> AppointmentSummary? {
        guard (try? await supabase.auth.user()) != nil, !bookingId.isEmpty else { return nil }

        let bookings: [BookingDTO] = try await supabase
            .from("bookings")
            .select()
            .eq("id", value: bookingId)
            .limit(1)
            .execute()
            .value

        guard let booking = bookings.first else { return nil }

        let therapist = try? await therapistByID(booking.therapistId)
        let payment = try? await latestPayment(bookingId: bookingId)
        let session = try? await sessionForBooking(bookingId: bookingId)
        let groupSession: GroupSessionDTO? = try? await groupSessionByID(booking.groupSessionId)

        return booking.toAppointmentSummary(
            therapist: therapist,
            payment: payment,
            session: session,
            groupSession: groupSession
        )
    }

    func createDraft(therapistId: String, availabilitySlotId: String, sessionMode: SessionMode) async throws -> AppointmentSummary {
        let booking: BookingDTO = try await supabase
            .rpc(
                "create_booking_draft",
                params: CreateBookingDraftRequestDTO(
                    therapistId: therapistId,
                    availabilitySlotId: availabilitySlotId,
                    sessionMode: sessionMode.rawValue
                )
            )
            .execute()
            .value

        return booking.toAppointmentSummary(therapist: try await therapistByID(booking.therapistId))
    }

    func createGroupDraft(groupSessionId: String) async throws -> AppointmentSummary {
        let booking: BookingDTO = try await supabase
            .rpc(
                "create_group_booking_draft",
                params: CreateGroupBookingDraftRequestDTO(groupSessionId: groupSessionId)
            )
            .execute()
            .value

        let therapist = try? await therapistByID(booking.therapistId)
        let groupSession: GroupSessionDTO? = try? await groupSessionByID(booking.groupSessionId)
        return booking.toAppointmentSummary(therapist: therapist, groupSession: groupSession)
    }

    func cancelBooking(bookingId: String, reason: String?) async throws -> AppointmentSummary {
        let booking: BookingDTO = try await supabase
            .rpc(
                "cancel_booking",
                params: CancelBookingRequestDTO(bookingId: bookingId, reason: reason)
            )
            .execute()
            .value

        return booking.toAppointmentSummary(therapist: try await therapistByID(booking.therapistId))
    }

    func startPayment(bookingId: String) async throws -> PaymentLaunch {
        guard let session = try? await supabase.auth.session else {
            throw SupabaseRepositoryError(message: "You need to sign in before starting payment.")
        }

        let url = URL(string: "\(supabaseURL.trimTrailingSlash)/functions/v1/start-myfatoorah")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(StartMyFatoorahRequestDTO(bookingId: bookingId))

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(MyFatoorahStartPaymentResponseDTO.self, from: data)

        return PaymentLaunch(
            paymentId: response.paymentId,
            paymentStatus: response.paymentStatus,
            provider: response.provider,
            providerReference: response.providerReference,
            redirectUrl: response.redirectUrl,
            requiresExternalVerification: response.requiresExternalVerification
        )
    }

    func verifyPayment(bookingId: String, paymentId: String) async throws -> AppointmentSummary {
        guard let session = try? await supabase.auth.session else {
            throw SupabaseRepositoryError(message: "You need to sign in before checking payment status.")
        }

        let url = URL(string: "\(supabaseURL.trimTrailingSlash)/functions/v1/verify-myfatoorah")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(VerifyMyFatoorahPaymentRequestDTO(paymentId: paymentId))

        _ = try await URLSession.shared.data(for: request)

        guard let updated = try await getById(bookingId) else {
            throw SupabaseRepositoryError(message: "Updated booking not found after payment verification.")
        }
        return updated
    }

    private func mapAppointments(_ bookings: [BookingDTO]) async throws -> [AppointmentSummary] {
        guard !bookings.isEmpty else { return [] }

        let therapists: [TherapistDTO] = try await supabase
            .from("therapists")
            .select()
            .in("id", values: Array(Set(bookings.map(\.therapistId))))
            .execute()
            .value

        let therapistsByID = Dictionary(uniqueKeysWithValues: therapists.map { ($0.id, $0) })

        let bookingIDs = bookings.map(\.id)

        let payments: [PaymentDTO] = (try? await supabase
            .from("payments")
            .select()
            .in("booking_id", values: bookingIDs)
            .order("created_at", ascending: false)
            .execute()
            .value) ?? []

        let latestPaymentByBookingID: [String: PaymentDTO] = payments.reduce(into: [:]) { dict, payment in
            if dict[payment.bookingId] == nil { dict[payment.bookingId] = payment }
        }

        let sessions: [SessionDTO] = (try? await supabase
            .from("sessions")
            .select()
            .in("booking_id", values: bookingIDs)
            .execute()
            .value) ?? []

        let sessionsByBookingID = Dictionary(uniqueKeysWithValues: sessions.map { ($0.bookingId, $0) })

        let groupSessionIDs = bookings.compactMap(\.groupSessionId)
        var groupSessionsByID: [String: GroupSessionDTO] = [:]
        if !groupSessionIDs.isEmpty {
            let groupSessions: [GroupSessionDTO] = (try? await supabase
                .from("group_sessions")
                .select()
                .in("id", values: groupSessionIDs)
                .execute()
                .value) ?? []
            groupSessionsByID = Dictionary(uniqueKeysWithValues: groupSessions.map { ($0.id, $0) })
        }

        return bookings.map { booking in
            booking.toAppointmentSummary(
                therapist: therapistsByID[booking.therapistId],
                payment: latestPaymentByBookingID[booking.id],
                session: sessionsByBookingID[booking.id],
                groupSession: booking.groupSessionId.flatMap { groupSessionsByID[$0] }
            )
        }
    }

    private func therapistByID(_ therapistID: String) async throws -> TherapistDTO? {
        let therapists: [TherapistDTO] = try await supabase
            .from("therapists")
            .select()
            .eq("id", value: therapistID)
            .limit(1)
            .execute()
            .value

        return therapists.first
    }

    private func latestPayment(bookingId: String) async throws -> PaymentDTO? {
        let payments: [PaymentDTO] = try await supabase
            .from("payments")
            .select()
            .eq("booking_id", value: bookingId)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value

        return payments.first
    }

    private func sessionForBooking(bookingId: String) async throws -> SessionDTO? {
        let sessions: [SessionDTO] = try await supabase
            .from("sessions")
            .select()
            .eq("booking_id", value: bookingId)
            .limit(1)
            .execute()
            .value

        return sessions.first
    }

    private func groupSessionByID(_ id: String?) async throws -> GroupSessionDTO? {
        guard let id, !id.isEmpty else { return nil }

        let groups: [GroupSessionDTO] = try await supabase
            .from("group_sessions")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value

        return groups.first
    }
}

// MARK: - Session

struct SupabaseSessionRepository: SessionRepository {
    let supabase: SupabaseClient
    let supabaseURL: String
    let publishableKey: String

    func getForBooking(_ bookingId: String) async throws -> SessionDetails? {
        guard (try? await supabase.auth.user()) != nil, !bookingId.isEmpty else { return nil }

        let bookings: [BookingDTO] = try await supabase
            .from("bookings")
            .select()
            .eq("id", value: bookingId)
            .limit(1)
            .execute()
            .value

        guard let booking = bookings.first else { return nil }

        let therapists: [TherapistDTO] = (try? await supabase
            .from("therapists")
            .select()
            .eq("id", value: booking.therapistId)
            .limit(1)
            .execute()
            .value) ?? []

        let payments: [PaymentDTO] = (try? await supabase
            .from("payments")
            .select()
            .eq("booking_id", value: bookingId)
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value) ?? []

        let sessions: [SessionDTO] = (try? await supabase
            .from("sessions")
            .select()
            .eq("booking_id", value: bookingId)
            .limit(1)
            .execute()
            .value) ?? []

        let groupSession: GroupSessionDTO? = try? await {
            guard let gsID = booking.groupSessionId else { return nil }
            let groups: [GroupSessionDTO] = try await supabase
                .from("group_sessions")
                .select()
                .eq("id", value: gsID)
                .limit(1)
                .execute()
                .value
            return groups.first
        }()

        return booking.toSessionDetails(
            therapist: therapists.first,
            payment: payments.first,
            session: sessions.first,
            groupSession: groupSession
        )
    }

    func issueAgoraToken(bookingId: String) async throws -> AgoraJoinCredentials {
        guard let session = try? await supabase.auth.session else {
            throw SupabaseRepositoryError(message: "You need to sign in before joining a session.")
        }

        let url = URL(string: "\(supabaseURL.trimTrailingSlash)/functions/v1/issue-agora-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(IssueAgoraTokenRequestDTO(bookingId: bookingId))

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AgoraTokenResponseDTO.self, from: data)

        return AgoraJoinCredentials(
            bookingId: response.bookingId,
            sessionId: response.sessionId,
            token: response.token,
            appId: response.appId,
            channelName: response.channelName,
            role: response.role,
            expiresAt: response.expiresAt
        )
    }
}

// MARK: - Quotes

struct SupabaseQuoteRepository: QuoteRepository {
    let supabase: SupabaseClient

    func listQuotes() async throws -> [QuoteCard] {
        let quotes: [QuoteDTO] = try await supabase
            .from("quotes")
            .select()
            .eq("is_active", value: true)
            .order("id")
            .execute()
            .value

        return quotes.map { QuoteCard(id: $0.id, text: $0.text, author: $0.author) }
    }
}

// MARK: - Shared Error

struct SupabaseRepositoryError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

// MARK: - DTO Extensions

private extension ProfileDTO {
    func toDomain() -> UserProfile {
        UserProfile(id: id, email: email, fullName: fullName, phone: phone, locale: locale)
    }
}

private extension ProfileUpdateDTO {
    init(locale: String?, fullName: String?, phone: String?) {
        self.locale = locale ?? ""
        self.fullName = fullName
        self.phone = phone
    }
}

private extension TherapistDTO {
    func toSummary(slots: [AvailabilitySlotDTO]) -> TherapistSummary {
        let nextSlot = slots.min { $0.startsAt < $1.startsAt }
        let isAvailableNow = nextSlot?.startsAt.isAvailableSoon ?? false

        return TherapistSummary(
            id: id,
            fullName: fullName,
            credentials: title ?? "Therapist",
            specialization: specialization,
            specializationTags: specialization
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty },
            languages: languages.map(\.displayLanguage),
            sessionModes: sessionModes.compactMap(SessionMode.init(rawValue:)).ifEmpty([.video]),
            priceLabel: Self.formatPriceLabel(priceFils: priceFils, currencyCode: currencyCode),
            sessionDurationMinutes: 50,
            rating: 0,
            sessionsCompleted: 0,
            bio: bio ?? "",
            availabilityLabel: Self.formatAvailabilityLabel(startsAt: nextSlot?.startsAt),
            isAvailableNow: isAvailableNow,
            initials: fullName.initials
        )
    }

    static func formatPriceLabel(priceFils: Int, currencyCode: String) -> String {
        let major = Double(priceFils) / 1000
        let formatted = major.rounded(.towardZero) == major
            ? String(Int(major))
            : String(format: "%.3f", major).replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
        return "\(formatted) \(currencyCode == "KWD" ? "KWD" : currencyCode)"
    }

    static func formatAvailabilityLabel(startsAt: String?) -> String {
        guard let startsAt, let date = ISO8601DateFormatter().date(from: startsAt) else {
            return "No slots yet"
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today \(date.formatted(date: .omitted, time: .shortened))"
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        }

        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }
}

private extension AvailabilitySlotDTO {
    var toAvailabilitySlot: TherapistAvailabilitySlot? {
        guard let date = ISO8601DateFormatter().date(from: startsAt) else { return nil }

        let calendar = Calendar.current
        let dayKey = DateFormatter.bookingDayKey.string(from: date)

        return TherapistAvailabilitySlot(
            id: id,
            therapistId: therapistId,
            startsAt: startsAt,
            endsAt: endsAt,
            dayKey: dayKey,
            dayLabel: date.dayLabel(calendar: calendar),
            dateLabel: date.formatted(.dateTime.day().month(.abbreviated)),
            timeLabel: date.formatted(date: .omitted, time: .shortened)
        )
    }
}

private extension GroupSessionDTO {
    var toGroupSession: TherapistGroupSession? {
        guard let date = ISO8601DateFormatter().date(from: scheduledStartsAt) else { return nil }

        let calendar = Calendar.current
        let dayKey = DateFormatter.bookingDayKey.string(from: date)

        return TherapistGroupSession(
            id: id,
            therapistId: therapistId,
            title: title,
            description: description ?? "",
            sessionMode: sessionMode,
            startsAt: scheduledStartsAt,
            endsAt: scheduledEndsAt,
            dayKey: dayKey,
            dayLabel: date.dayLabel(calendar: calendar),
            dateLabel: date.formatted(.dateTime.day().month(.abbreviated)),
            timeLabel: date.formatted(date: .omitted, time: .shortened),
            maxParticipants: maxParticipants
        )
    }
}

private extension BookingDTO {
    func toAppointmentSummary(
        therapist: TherapistDTO?,
        payment: PaymentDTO? = nil,
        session: SessionDTO? = nil,
        groupSession: GroupSessionDTO? = nil
    ) -> AppointmentSummary {
        let effectiveStatus = computedEffectiveStatus
        let therapistName = therapist?.fullName ?? "Therapist"
        let scheduledDate = ISO8601DateFormatter().date(from: scheduledStartsAt)
        let sessionStatusCode = groupSession?.sessionStatus ?? session?.sessionStatus

        return AppointmentSummary(
            id: id,
            therapistId: therapistId,
            therapistName: therapistName,
            therapistInitials: therapistName.initials,
            focusArea: groupSession?.title ?? therapist?.specialization ?? "Support session",
            groupSessionTitle: groupSession?.title,
            isGroupSession: groupSessionId != nil,
            dateLabel: scheduledDate?.formatted(.dateTime.weekday(.abbreviated).day(.twoDigits).month(.abbreviated)) ?? "Upcoming",
            timeLabel: scheduledDate?.formatted(date: .omitted, time: .shortened) ?? "",
            status: effectiveStatus.bookingStatus,
            actionLabel: effectiveStatus.actionLabel,
            mode: SessionMode(rawValue: sessionMode.lowercased()) ?? .video,
            canCancel: effectiveStatus.canCancel,
            priceLabel: TherapistDTO.formatPriceLabel(priceFils: priceFils, currencyCode: currencyCode),
            holdExpiresAtLabel: expiresAt.flatMap { formatShortTimeLabel($0) },
            paymentStatusCode: payment?.paymentStatus,
            paymentStatus: payment?.paymentStatus.flatMap { displayPaymentStatus($0) },
            sessionStatusCode: sessionStatusCode,
            sessionStatus: sessionStatusCode.flatMap { displaySessionStatus($0) }
        )
    }

    func toSessionDetails(
        therapist: TherapistDTO?,
        payment: PaymentDTO?,
        session: SessionDTO?,
        groupSession: GroupSessionDTO? = nil
    ) -> SessionDetails {
        let effectiveStatus = computedEffectiveStatus
        let therapistName = therapist?.fullName ?? "Therapist"
        let scheduledDate = ISO8601DateFormatter().date(from: scheduledStartsAt)
        let sessionStatusCode = groupSession?.sessionStatus ?? session?.sessionStatus

        let canJoinNow: Bool
        if effectiveStatus != .confirmed {
            canJoinNow = false
        } else if let groupSession {
            canJoinNow = groupSessionJoinAllowed(groupSession: groupSession)
        } else if let session {
            canJoinNow = sessionJoinAllowed(session: session)
        } else {
            canJoinNow = false
        }

        return SessionDetails(
            bookingId: id,
            therapistId: therapistId,
            therapistName: therapistName,
            therapistInitials: therapistName.initials,
            groupSessionTitle: groupSession?.title,
            isGroupSession: groupSessionId != nil,
            sessionMode: displayBookingMode(groupSession: groupSession),
            dateLabel: scheduledDate?.formatted(.dateTime.weekday(.abbreviated).day(.twoDigits).month(.abbreviated)) ?? "Upcoming",
            timeLabel: scheduledDate?.formatted(date: .omitted, time: .shortened) ?? "",
            priceLabel: TherapistDTO.formatPriceLabel(priceFils: priceFils, currencyCode: currencyCode),
            bookingStatusCode: effectiveStatus.rawValue,
            bookingStatus: effectiveStatus.displayLabel,
            paymentStatusCode: payment?.paymentStatus,
            paymentStatus: payment?.paymentStatus.flatMap { displaySessionPaymentStatus($0) },
            sessionStatusCode: sessionStatusCode,
            sessionStatus: sessionStatusCode.flatMap { displaySessionStatus($0) },
            joinAllowedFromLabel: (groupSession?.joinAllowedFrom ?? session?.joinAllowedFrom).flatMap { formatFullTimeLabel($0) },
            holdExpiresAtLabel: expiresAt.flatMap { formatFullTimeLabel($0) },
            canJoinNow: canJoinNow,
            canRetryPayment: effectiveStatus == .pendingPayment || effectiveStatus == .paymentFailed || effectiveStatus == .expired
        )
    }

    private func sessionJoinAllowed(session: SessionDTO) -> Bool {
        if session.sessionStatus == "canceled" || session.sessionStatus == "failed" { return false }
        guard
            let start = ISO8601DateFormatter().date(from: scheduledStartsAt),
            let end = ISO8601DateFormatter().date(from: scheduledEndsAt)
        else { return false }

        let joinFrom = session.joinAllowedFrom.flatMap { ISO8601DateFormatter().date(from: $0) }
            ?? start.addingTimeInterval(-15 * 60)
        let closeAt = end.addingTimeInterval(30 * 60)
        let now = Date()
        return now >= joinFrom && now <= closeAt
    }

    private func groupSessionJoinAllowed(groupSession: GroupSessionDTO) -> Bool {
        if groupSession.sessionStatus == "canceled" || groupSession.sessionStatus == "failed" { return false }
        guard
            let start = ISO8601DateFormatter().date(from: scheduledStartsAt),
            let end = ISO8601DateFormatter().date(from: scheduledEndsAt)
        else { return false }

        let joinFrom = groupSession.joinAllowedFrom.flatMap { ISO8601DateFormatter().date(from: $0) }
            ?? start.addingTimeInterval(-15 * 60)
        let closeAt = end.addingTimeInterval(30 * 60)
        let now = Date()
        return now >= joinFrom && now <= closeAt
    }

    var computedEffectiveStatus: BookingPresentationStatus {
        if bookingStatus != BookingStatus.pendingPayment.rawValue {
            return BookingPresentationStatus(rawValue: bookingStatus) ?? .confirmed
        }

        guard
            let expiresAt,
            let expiry = ISO8601DateFormatter().date(from: expiresAt),
            expiry > Date()
        else {
            if expiresAt != nil { return .expired }
            return .pendingPayment
        }

        return .pendingPayment
    }

    private func displayBookingMode(groupSession: GroupSessionDTO?) -> String {
        let base = sessionMode.prefix(1).uppercased() + sessionMode.dropFirst().lowercased()
        return (groupSession != nil || groupSessionId != nil) ? "Group \(base)" : base
    }

    private func formatShortTimeLabel(_ iso: String) -> String? {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return nil }
        return date.formatted(date: .omitted, time: .shortened)
    }

    private func formatFullTimeLabel(_ iso: String) -> String? {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return nil }
        return date.formatted(.dateTime.weekday(.abbreviated).day(.twoDigits).month(.abbreviated).hour().minute())
    }

    private func displayPaymentStatus(_ status: String) -> String {
        switch status {
        case "initiated": return "Payment started"
        case "pending": return "Awaiting confirmation"
        case "paid": return "Paid"
        case "failed": return "Payment failed"
        case "canceled": return "Payment canceled"
        case "refunded": return "Refunded"
        default: return status.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func displaySessionPaymentStatus(_ status: String) -> String {
        switch status {
        case "initiated": return "Payment started"
        case "pending": return "Awaiting provider confirmation"
        case "paid": return "Paid"
        case "failed": return "Payment failed"
        case "canceled": return "Payment canceled"
        case "refunded": return "Refunded"
        default: return status.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func displaySessionStatus(_ status: String) -> String {
        switch status {
        case "scheduled": return "Scheduled"
        case "live": return "Live"
        case "completed": return "Completed"
        case "canceled": return "Canceled"
        case "failed": return "Failed"
        default: return status.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

// MARK: - Booking Presentation Status

private enum BookingPresentationStatus: String {
    case pendingPayment = "pending_payment"
    case confirmed
    case completed
    case canceled
    case paymentFailed = "payment_failed"
    case expired

    var bookingStatus: BookingStatus {
        switch self {
        case .pendingPayment: return .pendingPayment
        case .confirmed: return .confirmed
        case .completed: return .completed
        case .canceled: return .canceled
        case .paymentFailed: return .paymentFailed
        case .expired: return .expired
        }
    }

    var displayLabel: String {
        switch self {
        case .pendingPayment: return "Pending payment"
        case .confirmed: return "Confirmed"
        case .completed: return "Completed"
        case .canceled: return "Canceled"
        case .paymentFailed: return "Payment failed"
        case .expired: return "Expired"
        }
    }

    var actionLabel: String {
        switch self {
        case .pendingPayment: return "Complete payment"
        case .confirmed: return "View details"
        case .completed: return "Rebook"
        case .canceled, .expired, .paymentFailed: return "Book again"
        }
    }

    var canCancel: Bool {
        self == .pendingPayment || self == .confirmed
    }
}

// MARK: - Helpers

private extension String {
    var initials: String {
        split(separator: " ").filter { !$0.isEmpty }.prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    var displayLanguage: String {
        switch lowercased() {
        case "en": return "English"
        case "ar": return "Arabic"
        case "fr": return "French"
        case "hi": return "Hindi"
        default: return capitalized
        }
    }

    var isAvailableSoon: Bool {
        guard let date = ISO8601DateFormatter().date(from: self) else { return false }
        return date <= Date().addingTimeInterval(30 * 60)
    }

    var nilIfBlank: String? {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self
    }

    var trimTrailingSlash: String {
        hasSuffix("/") ? String(dropLast()) : self
    }
}

private extension Array {
    func ifEmpty(_ fallback: @autoclosure () -> [Element]) -> [Element] {
        isEmpty ? fallback() : self
    }
}

private extension Date {
    func dayLabel(calendar: Calendar) -> String {
        if calendar.isDateInToday(self) { return "Today" }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
           calendar.isDate(self, inSameDayAs: tomorrow) { return "Tomorrow" }
        return formatted(.dateTime.weekday(.abbreviated))
    }
}

private extension DateFormatter {
    static let bookingDayKey: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
