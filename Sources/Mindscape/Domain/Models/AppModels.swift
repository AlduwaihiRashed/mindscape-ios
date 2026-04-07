import Foundation

struct UserSession: Hashable, Codable {
    let userId: String
    let email: String
    let fullName: String?
}

struct AuthUIState: Hashable {
    var session: UserSession?
    var isLoading = false
    var errorMessage: String?
    var statusMessage: String?
}

struct TherapistSummary: Identifiable, Hashable, Codable {
    let id: String
    let fullName: String
    let credentials: String
    let specialization: String
    let specializationTags: [String]
    let languages: [String]
    let sessionModes: [SessionMode]
    let priceLabel: String
    let sessionDurationMinutes: Int
    let rating: Double
    let sessionsCompleted: Int
    let bio: String
    let availabilityLabel: String
    let isAvailableNow: Bool
    let initials: String
}

struct TherapistAvailabilitySlot: Identifiable, Hashable, Codable {
    let id: String
    let therapistId: String
    let startsAt: String
    let endsAt: String
    let dayKey: String
    let dayLabel: String
    let dateLabel: String
    let timeLabel: String
}

struct BookingAvailabilityDay: Identifiable, Hashable {
    let id: String
    let dayLabel: String
    let dateLabel: String
    let slots: [BookingTimeOption]
}

struct BookingContextUIState: Hashable {
    var therapist: TherapistSummary?
    var availabilityDays: [BookingAvailabilityDay] = []
    var isLoading = true
    var errorMessage: String?
    var requiresTherapistSelection = false
    var isSubmitting = false
    var submissionErrorMessage: String?
}

struct DiscoveryUIState: Hashable {
    var therapists: [TherapistSummary] = []
    var isLoading = true
    var errorMessage: String?
}

struct Concern: Identifiable, Hashable, Codable {
    let id: String
    let label: String
}

struct AppointmentSummary: Identifiable, Hashable, Codable {
    let id: String
    let therapistId: String
    let therapistName: String
    let therapistInitials: String
    let focusArea: String
    let dateLabel: String
    let timeLabel: String
    let status: BookingStatus
    let actionLabel: String
    let mode: SessionMode
    let canCancel: Bool
}

struct UserProfile: Identifiable, Hashable, Codable {
    let id: String
    let email: String
    let fullName: String?
    let phone: String?
    let locale: String
}

struct ProfileUIState: Hashable {
    var profile: UserProfile?
    var notificationsEnabled = true
    var isLoading = true
    var errorMessage: String?
}

struct BookingUIState: Hashable {
    var upcomingAppointments: [AppointmentSummary] = []
    var pastAppointments: [AppointmentSummary] = []
    var isLoading = true
    var errorMessage: String?
}

struct ReflectionNote: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let excerpt: String
    let createdAt: String
}

struct JourneyMetric: Hashable, Codable {
    let label: String
    let value: String
    let supportText: String
}

struct ReflectionPrompt: Identifiable, Hashable, Codable {
    let id: String
    let prompt: String
}

struct WellnessTrend: Hashable, Codable {
    let label: String
    let value: Int
}

struct SessionInsight: Hashable, Codable {
    let title: String
    let summary: String
}

struct SessionTypeOption: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let supportingText: String
}

struct BookingDateOption: Identifiable, Hashable, Codable {
    let id: String
    let dayLabel: String
    let dateLabel: String
}

struct BookingTimeOption: Identifiable, Hashable, Codable {
    let id: String
    let timeLabel: String
    let isPopular: Bool
}

struct DrawerProfileSummary: Hashable {
    let title: String
    let subtitle: String
    let initials: String
}

struct HomeUISnapshot: Hashable, Codable {
    let quote: String
    let journeyHeadline: String
    let journeySupport: String
}

enum SessionMode: String, Codable, CaseIterable, Hashable {
    case video
    case audio

    var label: String {
        rawValue.capitalized
    }
}

enum BookingStatus: String, Codable, CaseIterable, Hashable {
    case pendingPayment = "pending_payment"
    case confirmed
    case canceled
    case expired
    case completed

    var label: String {
        switch self {
        case .pendingPayment:
            return "Pending payment"
        case .confirmed:
            return "Confirmed"
        case .canceled:
            return "Canceled"
        case .expired:
            return "Expired"
        case .completed:
            return "Completed"
        }
    }
}

enum PaymentStatus: String, Codable, CaseIterable, Hashable {
    case initiated
    case pending
    case paid
    case failed
    case canceled
    case refunded
}

enum SessionStatus: String, Codable, CaseIterable, Hashable {
    case scheduled
    case live
    case completed
    case canceled
    case failed
}
