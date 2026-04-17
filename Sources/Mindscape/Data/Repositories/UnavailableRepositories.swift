import Foundation

struct UnavailableAuthRepository: AuthRepository {
    let message: String

    func currentSession() async throws -> UserSession? {
        nil
    }

    func signIn(email: String, password: String) async throws -> UserSession {
        throw UnavailableRepositoryError(message: message)
    }

    func signUp(email: String, password: String, fullName: String?) async throws -> String {
        throw UnavailableRepositoryError(message: message)
    }

    func resetPassword(email: String) async throws -> String {
        throw UnavailableRepositoryError(message: message)
    }

    func signOut() async throws {}
}

struct UnavailableTherapistRepository: TherapistRepository {
    let message: String

    func listTherapists() async throws -> [TherapistSummary] {
        throw UnavailableRepositoryError(message: message)
    }

    func getTherapistById(_ id: String) async throws -> TherapistSummary? {
        throw UnavailableRepositoryError(message: message)
    }

    func listAvailabilitySlots(therapistId: String) async throws -> [TherapistAvailabilitySlot] {
        throw UnavailableRepositoryError(message: message)
    }

    func listGroupSessions(therapistId: String) async throws -> [TherapistGroupSession] {
        throw UnavailableRepositoryError(message: message)
    }
}

struct UnavailableProfileRepository: ProfileRepository {
    let message: String

    func getMe() async throws -> UserProfile? {
        throw UnavailableRepositoryError(message: message)
    }

    func updateLocale(_ locale: String) async throws -> UserProfile {
        throw UnavailableRepositoryError(message: message)
    }

    func updateProfile(fullName: String, phone: String?) async throws -> UserProfile {
        throw UnavailableRepositoryError(message: message)
    }
}

struct UnavailableBookingRepository: BookingRepository {
    let message: String

    func listMine() async throws -> [AppointmentSummary] {
        throw UnavailableRepositoryError(message: message)
    }

    func getById(_ bookingId: String) async throws -> AppointmentSummary? {
        throw UnavailableRepositoryError(message: message)
    }

    func createDraft(therapistId: String, availabilitySlotId: String, sessionMode: SessionMode) async throws -> AppointmentSummary {
        throw UnavailableRepositoryError(message: message)
    }

    func createGroupDraft(groupSessionId: String) async throws -> AppointmentSummary {
        throw UnavailableRepositoryError(message: message)
    }

    func cancelBooking(bookingId: String, reason: String?) async throws -> AppointmentSummary {
        throw UnavailableRepositoryError(message: message)
    }

    func startPayment(bookingId: String) async throws -> PaymentLaunch {
        throw UnavailableRepositoryError(message: message)
    }

    func verifyPayment(bookingId: String, paymentId: String) async throws -> AppointmentSummary {
        throw UnavailableRepositoryError(message: message)
    }
}

struct UnavailableSessionRepository: SessionRepository {
    let message: String

    func getForBooking(_ bookingId: String) async throws -> SessionDetails? {
        throw UnavailableRepositoryError(message: message)
    }

    func issueAgoraToken(bookingId: String) async throws -> AgoraJoinCredentials {
        throw UnavailableRepositoryError(message: message)
    }
}

struct UnavailableQuoteRepository: QuoteRepository {
    let message: String

    func listQuotes() async throws -> [QuoteCard] {
        throw UnavailableRepositoryError(message: message)
    }
}

struct UnavailableRepositoryError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}
