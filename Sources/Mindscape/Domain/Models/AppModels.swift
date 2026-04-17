import Foundation

// MARK: - Auth

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

// MARK: - Therapists

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

struct TherapistGroupSession: Identifiable, Hashable, Codable {
    let id: String
    let therapistId: String
    let title: String
    let description: String
    let sessionMode: String
    let startsAt: String
    let endsAt: String
    let dayKey: String
    let dayLabel: String
    let dateLabel: String
    let timeLabel: String
    let maxParticipants: Int
}

// MARK: - Discovery & Concerns

struct DiscoveryUIState: Hashable {
    var therapists: [TherapistSummary] = []
    var isLoading = true
    var errorMessage: String?
}

struct Concern: Identifiable, Hashable, Codable {
    let id: String
    let label: String
}

// MARK: - Booking Context

struct BookingAvailabilityDay: Identifiable, Hashable {
    let id: String
    let dayLabel: String
    let dateLabel: String
    let slots: [BookingTimeOption]
}

struct BookingContextUIState: Hashable {
    var therapist: TherapistSummary?
    var availabilityDays: [BookingAvailabilityDay] = []
    var groupSessions: [TherapistGroupSession] = []
    var isLoading = true
    var errorMessage: String?
    var requiresTherapistSelection = false
    var isSubmitting = false
    var submissionErrorMessage: String?
    var submissionStatusMessage: String?
}

// MARK: - Appointments

struct AppointmentSummary: Identifiable, Hashable, Codable {
    let id: String
    let therapistId: String
    let therapistName: String
    let therapistInitials: String
    let focusArea: String
    let groupSessionTitle: String?
    let isGroupSession: Bool
    let dateLabel: String
    let timeLabel: String
    let status: BookingStatus
    let actionLabel: String
    let mode: SessionMode
    let canCancel: Bool
    let priceLabel: String
    let holdExpiresAtLabel: String?
    let paymentStatusCode: String?
    let paymentStatus: String?
    let sessionStatusCode: String?
    let sessionStatus: String?

    init(
        id: String,
        therapistId: String,
        therapistName: String,
        therapistInitials: String,
        focusArea: String,
        groupSessionTitle: String? = nil,
        isGroupSession: Bool = false,
        dateLabel: String,
        timeLabel: String,
        status: BookingStatus,
        actionLabel: String,
        mode: SessionMode,
        canCancel: Bool,
        priceLabel: String = "",
        holdExpiresAtLabel: String? = nil,
        paymentStatusCode: String? = nil,
        paymentStatus: String? = nil,
        sessionStatusCode: String? = nil,
        sessionStatus: String? = nil
    ) {
        self.id = id
        self.therapistId = therapistId
        self.therapistName = therapistName
        self.therapistInitials = therapistInitials
        self.focusArea = focusArea
        self.groupSessionTitle = groupSessionTitle
        self.isGroupSession = isGroupSession
        self.dateLabel = dateLabel
        self.timeLabel = timeLabel
        self.status = status
        self.actionLabel = actionLabel
        self.mode = mode
        self.canCancel = canCancel
        self.priceLabel = priceLabel
        self.holdExpiresAtLabel = holdExpiresAtLabel
        self.paymentStatusCode = paymentStatusCode
        self.paymentStatus = paymentStatus
        self.sessionStatusCode = sessionStatusCode
        self.sessionStatus = sessionStatus
    }
}

struct BookingUIState: Hashable {
    var upcomingAppointments: [AppointmentSummary] = []
    var pastAppointments: [AppointmentSummary] = []
    var isLoading = true
    var errorMessage: String?
}

// MARK: - Checkout

struct PaymentLaunch: Hashable {
    let paymentId: String
    let paymentStatus: String
    let provider: String
    let providerReference: String?
    let redirectUrl: String
    let requiresExternalVerification: Bool
}

struct CheckoutUIState: Hashable {
    var appointment: AppointmentSummary?
    var isLoading = true
    var isStartingPayment = false
    var isVerifyingPayment = false
    var pendingPaymentLaunch: PaymentLaunch?
    var errorMessage: String?
    var statusMessage: String?
}

// MARK: - Session

struct SessionDetails: Hashable {
    let bookingId: String
    let therapistId: String
    let therapistName: String
    let therapistInitials: String
    let groupSessionTitle: String?
    let isGroupSession: Bool
    let sessionMode: String
    let dateLabel: String
    let timeLabel: String
    let priceLabel: String
    let bookingStatusCode: String
    let bookingStatus: String
    let paymentStatusCode: String?
    let paymentStatus: String?
    let sessionStatusCode: String?
    let sessionStatus: String?
    let joinAllowedFromLabel: String?
    let holdExpiresAtLabel: String?
    let canJoinNow: Bool
    let canRetryPayment: Bool
}

struct AgoraJoinCredentials: Hashable {
    let bookingId: String
    let sessionId: String
    let token: String
    let appId: String
    let channelName: String
    let role: String
    let expiresAt: String
}

struct SessionUIState: Hashable {
    var details: SessionDetails?
    var isLoading = true
    var errorMessage: String?
}

struct LiveSessionUIState: Hashable {
    var details: SessionDetails?
    var credentials: AgoraJoinCredentials?
    var isLoading = true
    var isConnecting = false
    var errorMessage: String?
}

// MARK: - Profile

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
    var isSaving = false
    var errorMessage: String?
    var statusMessage: String?
}

// MARK: - Your Space / Quotes

struct QuoteCard: Identifiable, Hashable, Codable {
    let id: String
    let text: String
    let author: String?
}

// MARK: - Space / Journey

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

// MARK: - Booking UI Options

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
    let supportingText: String?
    let isPopular: Bool
    let startsAt: String?

    init(
        id: String,
        timeLabel: String,
        supportingText: String? = nil,
        isPopular: Bool = false,
        startsAt: String? = nil
    ) {
        self.id = id
        self.timeLabel = timeLabel
        self.supportingText = supportingText
        self.isPopular = isPopular
        self.startsAt = startsAt
    }
}

// MARK: - Misc UI State

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

struct LoginPrompt: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
}

// MARK: - Enums

enum SessionMode: String, Codable, CaseIterable, Hashable {
    case video
    case audio

    var label: String { rawValue.capitalized }
}

enum BookingStatus: String, Codable, CaseIterable, Hashable {
    case pendingPayment = "pending_payment"
    case confirmed
    case canceled
    case expired
    case completed
    case paymentFailed = "payment_failed"

    var label: String {
        switch self {
        case .pendingPayment: return "Pending payment"
        case .confirmed: return "Confirmed"
        case .canceled: return "Canceled"
        case .expired: return "Expired"
        case .completed: return "Completed"
        case .paymentFailed: return "Payment failed"
        }
    }
}

enum PaymentStatus: String, Codable, CaseIterable, Hashable {
    case initiated, pending, paid, failed, canceled, refunded
}

enum SessionStatus: String, Codable, CaseIterable, Hashable {
    case scheduled, live, completed, canceled, failed
}
