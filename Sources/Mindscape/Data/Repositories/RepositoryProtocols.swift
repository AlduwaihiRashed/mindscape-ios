import Foundation

protocol AuthRepository {
    func currentSession() async throws -> UserSession?
    func signIn(email: String, password: String) async throws -> UserSession
    func signUp(email: String, password: String, fullName: String?) async throws -> String
    func resetPassword(email: String) async throws -> String
    func signOut() async throws
}

protocol ProfileRepository {
    func getMe() async throws -> UserProfile?
    func updateLocale(_ locale: String) async throws -> UserProfile
}

protocol TherapistRepository {
    func listTherapists() async throws -> [TherapistSummary]
    func getTherapistById(_ id: String) async throws -> TherapistSummary?
    func listAvailabilitySlots(therapistId: String) async throws -> [TherapistAvailabilitySlot]
}

protocol BookingRepository {
    func listMine() async throws -> [AppointmentSummary]
    func createDraft(therapistId: String, availabilitySlotId: String, sessionMode: SessionMode) async throws -> AppointmentSummary
    func cancelBooking(bookingId: String, reason: String?) async throws -> AppointmentSummary
}
