import Foundation

final class PreviewRepositoryStore {
    let therapists = MindscapeSampleData.therapists
    let concerns = MindscapeSampleData.concerns
    let homeSnapshot = MindscapeSampleData.homeSnapshot
    var session: UserSession?
    var profile: UserProfile?
    var bookings: [AppointmentSummary]
    let availabilitySlotsByTherapist: [String: [TherapistAvailabilitySlot]]
    let groupSessionsByTherapist: [String: [TherapistGroupSession]]

    init(
        session: UserSession? = nil,
        profile: UserProfile? = MindscapeSampleData.profile,
        bookings: [AppointmentSummary] = MindscapeSampleData.upcomingAppointments + MindscapeSampleData.pastAppointments
    ) {
        self.session = session
        self.profile = profile
        self.bookings = bookings
        availabilitySlotsByTherapist = Dictionary(grouping: MindscapeSampleData.sampleAvailabilitySlots, by: \.therapistId)
        groupSessionsByTherapist = Dictionary(grouping: MindscapeSampleData.sampleGroupSessions, by: \.therapistId)
    }
}

enum PreviewRepositoryError: LocalizedError {
    case invalidCredentials
    case missingEmail
    case missingPassword
    case unavailableSlot
    case bookingNotFound
    case unauthenticated

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The email or password is incorrect."
        case .missingEmail:
            return "Enter your email address to continue."
        case .missingPassword:
            return "Enter your password to continue."
        case .unavailableSlot:
            return "That time slot is no longer available."
        case .bookingNotFound:
            return "We could not find that booking."
        case .unauthenticated:
            return "Sign in to continue."
        }
    }
}

struct PreviewAuthRepository: AuthRepository {
    let store: PreviewRepositoryStore

    func currentSession() async throws -> UserSession? {
        store.session
    }

    func signIn(email: String, password: String) async throws -> UserSession {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !normalizedEmail.isEmpty else {
            throw PreviewRepositoryError.missingEmail
        }

        guard !password.isEmpty else {
            throw PreviewRepositoryError.missingPassword
        }

        guard password.count >= 8 else {
            throw PreviewRepositoryError.invalidCredentials
        }

        let session = UserSession(
            userId: store.profile?.id ?? "u-1",
            email: normalizedEmail,
            fullName: store.profile?.fullName ?? inferredFullName(from: normalizedEmail)
        )

        store.session = session

        if store.profile?.email != normalizedEmail {
            store.profile = UserProfile(
                id: session.userId,
                email: normalizedEmail,
                fullName: session.fullName,
                phone: nil,
                locale: "en-KW"
            )
        }

        return session
    }

    func signUp(email: String, password: String, fullName: String?) async throws -> String {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !normalizedEmail.isEmpty else {
            throw PreviewRepositoryError.missingEmail
        }

        guard !password.isEmpty else {
            throw PreviewRepositoryError.missingPassword
        }

        store.profile = UserProfile(
            id: store.profile?.id ?? "u-1",
            email: normalizedEmail,
            fullName: fullName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            phone: nil,
            locale: "en-KW"
        )

        return "Account created in preview mode. Use your password to sign in."
    }

    func resetPassword(email: String) async throws -> String {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PreviewRepositoryError.missingEmail
        }

        return "Password reset requested in preview mode."
    }

    func signOut() async throws {
        store.session = nil
    }

    private func inferredFullName(from email: String) -> String? {
        let localPart = email.split(separator: "@").first.map(String.init) ?? ""
        let formatted = localPart
            .split(separator: ".")
            .map { $0.capitalized }
            .joined(separator: " ")

        return formatted.nilIfEmpty
    }
}

struct PreviewProfileRepository: ProfileRepository {
    let store: PreviewRepositoryStore

    func getMe() async throws -> UserProfile? {
        guard store.session != nil else {
            return nil
        }

        return store.profile
    }

    func updateLocale(_ locale: String) async throws -> UserProfile {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        let updatedProfile = UserProfile(
            id: store.profile?.id ?? store.session?.userId ?? "u-1",
            email: store.profile?.email ?? store.session?.email ?? "",
            fullName: store.profile?.fullName ?? store.session?.fullName,
            phone: store.profile?.phone,
            locale: locale
        )

        store.profile = updatedProfile
        return updatedProfile
    }

    func updateProfile(fullName: String, phone: String?) async throws -> UserProfile {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        let updatedProfile = UserProfile(
            id: store.profile?.id ?? store.session?.userId ?? "u-1",
            email: store.profile?.email ?? store.session?.email ?? "",
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            phone: phone?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            locale: store.profile?.locale ?? "en-KW"
        )

        store.profile = updatedProfile
        return updatedProfile
    }
}

struct PreviewTherapistRepository: TherapistRepository {
    let store: PreviewRepositoryStore

    func listTherapists() async throws -> [TherapistSummary] {
        store.therapists
    }

    func getTherapistById(_ id: String) async throws -> TherapistSummary? {
        store.therapists.first(where: { $0.id == id })
    }

    func listAvailabilitySlots(therapistId: String) async throws -> [TherapistAvailabilitySlot] {
        store.availabilitySlotsByTherapist[therapistId, default: []]
    }

    func listGroupSessions(therapistId: String) async throws -> [TherapistGroupSession] {
        store.groupSessionsByTherapist[therapistId, default: []]
    }
}

struct PreviewBookingRepository: BookingRepository {
    let store: PreviewRepositoryStore

    func listMine() async throws -> [AppointmentSummary] {
        guard store.session != nil else {
            return []
        }

        return store.bookings
    }

    func getById(_ bookingId: String) async throws -> AppointmentSummary? {
        store.bookings.first(where: { $0.id == bookingId })
    }

    func createDraft(therapistId: String, availabilitySlotId: String, sessionMode: SessionMode) async throws -> AppointmentSummary {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        guard
            let therapist = store.therapists.first(where: { $0.id == therapistId }),
            let slot = store.availabilitySlotsByTherapist[therapistId]?.first(where: { $0.id == availabilitySlotId })
        else {
            throw PreviewRepositoryError.unavailableSlot
        }

        let draft = AppointmentSummary(
            id: "draft-\(UUID().uuidString)",
            therapistId: therapist.id,
            therapistName: therapist.fullName,
            therapistInitials: therapist.initials,
            focusArea: therapist.specialization,
            dateLabel: "\(slot.dayLabel), \(slot.dateLabel)",
            timeLabel: slot.timeLabel,
            status: .pendingPayment,
            actionLabel: "Complete payment",
            mode: sessionMode,
            canCancel: true,
            priceLabel: therapist.priceLabel,
            holdExpiresAtLabel: "Expires in 15 minutes"
        )

        store.bookings.insert(draft, at: 0)
        return draft
    }

    func createGroupDraft(groupSessionId: String) async throws -> AppointmentSummary {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        let allGroupSessions = store.groupSessionsByTherapist.values.flatMap { $0 }
        guard let groupSession = allGroupSessions.first(where: { $0.id == groupSessionId }),
              let therapist = store.therapists.first(where: { $0.id == groupSession.therapistId })
        else {
            throw PreviewRepositoryError.unavailableSlot
        }

        let draft = AppointmentSummary(
            id: "draft-group-\(UUID().uuidString)",
            therapistId: therapist.id,
            therapistName: therapist.fullName,
            therapistInitials: therapist.initials,
            focusArea: therapist.specialization,
            groupSessionTitle: groupSession.title,
            isGroupSession: true,
            dateLabel: "\(groupSession.dayLabel), \(groupSession.dateLabel)",
            timeLabel: groupSession.timeLabel,
            status: .pendingPayment,
            actionLabel: "Complete payment",
            mode: .video,
            canCancel: true,
            priceLabel: therapist.priceLabel,
            holdExpiresAtLabel: "Expires in 15 minutes"
        )

        store.bookings.insert(draft, at: 0)
        return draft
    }

    func cancelBooking(bookingId: String, reason: String?) async throws -> AppointmentSummary {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        guard let index = store.bookings.firstIndex(where: { $0.id == bookingId }) else {
            throw PreviewRepositoryError.bookingNotFound
        }

        let existing = store.bookings[index]
        let updated = AppointmentSummary(
            id: existing.id,
            therapistId: existing.therapistId,
            therapistName: existing.therapistName,
            therapistInitials: existing.therapistInitials,
            focusArea: existing.focusArea,
            groupSessionTitle: existing.groupSessionTitle,
            isGroupSession: existing.isGroupSession,
            dateLabel: existing.dateLabel,
            timeLabel: existing.timeLabel,
            status: .canceled,
            actionLabel: "Canceled",
            mode: existing.mode,
            canCancel: false,
            priceLabel: existing.priceLabel
        )

        store.bookings[index] = updated
        return updated
    }

    func startPayment(bookingId: String) async throws -> PaymentLaunch {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        guard store.bookings.contains(where: { $0.id == bookingId }) else {
            throw PreviewRepositoryError.bookingNotFound
        }

        return PaymentLaunch(
            paymentId: "preview-pay-\(bookingId)",
            paymentStatus: "initiated",
            provider: "myfatoorah",
            providerReference: nil,
            redirectUrl: "https://example.com/preview-payment",
            requiresExternalVerification: false
        )
    }

    func verifyPayment(bookingId: String, paymentId: String) async throws -> AppointmentSummary {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        guard let index = store.bookings.firstIndex(where: { $0.id == bookingId }) else {
            throw PreviewRepositoryError.bookingNotFound
        }

        let existing = store.bookings[index]
        let confirmed = AppointmentSummary(
            id: existing.id,
            therapistId: existing.therapistId,
            therapistName: existing.therapistName,
            therapistInitials: existing.therapistInitials,
            focusArea: existing.focusArea,
            groupSessionTitle: existing.groupSessionTitle,
            isGroupSession: existing.isGroupSession,
            dateLabel: existing.dateLabel,
            timeLabel: existing.timeLabel,
            status: .confirmed,
            actionLabel: "Join session",
            mode: existing.mode,
            canCancel: true,
            priceLabel: existing.priceLabel,
            paymentStatusCode: "paid",
            paymentStatus: "Paid"
        )

        store.bookings[index] = confirmed
        return confirmed
    }
}

struct PreviewSessionRepository: SessionRepository {
    let store: PreviewRepositoryStore

    func getForBooking(_ bookingId: String) async throws -> SessionDetails? {
        guard let booking = store.bookings.first(where: { $0.id == bookingId }),
              let therapist = store.therapists.first(where: { $0.id == booking.therapistId })
        else {
            return nil
        }

        return SessionDetails(
            bookingId: bookingId,
            therapistId: therapist.id,
            therapistName: therapist.fullName,
            therapistInitials: therapist.initials,
            groupSessionTitle: booking.groupSessionTitle,
            isGroupSession: booking.isGroupSession,
            sessionMode: booking.mode.rawValue,
            dateLabel: booking.dateLabel,
            timeLabel: booking.timeLabel,
            priceLabel: booking.priceLabel,
            bookingStatusCode: booking.status.rawValue,
            bookingStatus: booking.status.label,
            paymentStatusCode: booking.paymentStatusCode,
            paymentStatus: booking.paymentStatus,
            sessionStatusCode: booking.sessionStatusCode,
            sessionStatus: booking.sessionStatus,
            joinAllowedFromLabel: nil,
            holdExpiresAtLabel: booking.holdExpiresAtLabel,
            canJoinNow: booking.status == .confirmed,
            canRetryPayment: booking.status == .pendingPayment || booking.status == .paymentFailed
        )
    }

    func issueAgoraToken(bookingId: String) async throws -> AgoraJoinCredentials {
        guard store.session != nil else {
            throw PreviewRepositoryError.unauthenticated
        }

        return AgoraJoinCredentials(
            bookingId: bookingId,
            sessionId: "preview-session-\(bookingId)",
            token: "preview-agora-token",
            appId: "mock-app-id",
            channelName: "preview-channel",
            role: "publisher",
            expiresAt: "2026-12-31T23:59:59Z"
        )
    }
}

struct PreviewQuoteRepository: QuoteRepository {
    func listQuotes() async throws -> [QuoteCard] {
        MindscapeSampleData.quotes
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
