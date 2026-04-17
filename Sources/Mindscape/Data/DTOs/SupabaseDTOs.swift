import Foundation

// MARK: - Profile DTOs

struct ProfileDTO: Codable, Hashable {
    let id: String
    let email: String
    let fullName: String?
    let phone: String?
    let locale: String

    enum CodingKeys: String, CodingKey {
        case id, email, phone, locale
        case fullName = "full_name"
    }
}

struct ProfileUpdateDTO: Codable, Hashable {
    let locale: String
    let fullName: String?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case locale, phone
        case fullName = "full_name"
    }
}

struct ProfileInsertDTO: Codable, Hashable {
    let id: String
    let email: String
    let fullName: String?
    let phone: String?
    let locale: String

    enum CodingKeys: String, CodingKey {
        case id, email, phone, locale
        case fullName = "full_name"
    }
}

// MARK: - Therapist DTOs

struct TherapistDTO: Codable, Hashable {
    let id: String
    let fullName: String
    let title: String?
    let specialization: String
    let bio: String?
    let languages: [String]
    let sessionModes: [String]
    let priceFils: Int
    let currencyCode: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, specialization, bio, languages
        case fullName = "full_name"
        case sessionModes = "session_modes"
        case priceFils = "price_fils"
        case currencyCode = "currency_code"
        case isActive = "is_active"
    }
}

struct AvailabilitySlotDTO: Codable, Hashable {
    let id: String
    let therapistId: String
    let startsAt: String
    let endsAt: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id, status
        case therapistId = "therapist_id"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
    }
}

struct GroupSessionDTO: Codable, Hashable {
    let id: String
    let therapistId: String
    let title: String
    let description: String?
    let sessionMode: String
    let maxParticipants: Int
    let agoraChannelName: String
    let sessionStatus: String
    let scheduledStartsAt: String
    let scheduledEndsAt: String
    let joinAllowedFrom: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case therapistId = "therapist_id"
        case sessionMode = "session_mode"
        case maxParticipants = "max_participants"
        case agoraChannelName = "agora_channel_name"
        case sessionStatus = "session_status"
        case scheduledStartsAt = "scheduled_starts_at"
        case scheduledEndsAt = "scheduled_ends_at"
        case joinAllowedFrom = "join_allowed_from"
    }
}

// MARK: - Booking DTOs

struct BookingDTO: Codable, Hashable {
    let id: String
    let therapistId: String
    let groupSessionId: String?
    let bookingStatus: String
    let sessionMode: String
    let priceFils: Int
    let currencyCode: String
    let scheduledStartsAt: String
    let scheduledEndsAt: String
    let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case therapistId = "therapist_id"
        case groupSessionId = "group_session_id"
        case bookingStatus = "booking_status"
        case sessionMode = "session_mode"
        case priceFils = "price_fils"
        case currencyCode = "currency_code"
        case scheduledStartsAt = "scheduled_starts_at"
        case scheduledEndsAt = "scheduled_ends_at"
        case expiresAt = "expires_at"
    }
}

struct CreateBookingDraftRequestDTO: Codable, Hashable {
    let therapistId: String
    let availabilitySlotId: String
    let sessionMode: String

    enum CodingKeys: String, CodingKey {
        case therapistId = "p_therapist_id"
        case availabilitySlotId = "p_availability_slot_id"
        case sessionMode = "p_session_mode"
    }
}

struct CreateGroupBookingDraftRequestDTO: Codable, Hashable {
    let groupSessionId: String

    enum CodingKeys: String, CodingKey {
        case groupSessionId = "p_group_session_id"
    }
}

struct CancelBookingRequestDTO: Codable, Hashable {
    let bookingId: String
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case bookingId = "p_booking_id"
        case reason = "p_reason"
    }
}

// MARK: - Payment DTOs

struct PaymentDTO: Codable, Hashable {
    let id: String
    let bookingId: String
    let provider: String
    let providerPaymentId: String?
    let paymentStatus: String
    let amountFils: Int
    let currencyCode: String
    let paidAt: String?

    enum CodingKeys: String, CodingKey {
        case id, provider
        case bookingId = "booking_id"
        case providerPaymentId = "provider_payment_id"
        case paymentStatus = "payment_status"
        case amountFils = "amount_fils"
        case currencyCode = "currency_code"
        case paidAt = "paid_at"
    }
}

struct MyFatoorahStartPaymentResponseDTO: Codable, Hashable {
    let paymentId: String
    let paymentStatus: String
    let provider: String
    let providerReference: String?
    let redirectUrl: String
    let requiresExternalVerification: Bool
}

struct MyFatoorahVerifyPaymentResponseDTO: Codable, Hashable {
    let paymentId: String
    let paymentStatus: String
    let bookingId: String
    let bookingStatus: String
}

struct StartMyFatoorahRequestDTO: Codable, Hashable {
    let bookingId: String
}

struct VerifyMyFatoorahPaymentRequestDTO: Codable, Hashable {
    let paymentId: String
}

// MARK: - Session DTOs

struct SessionDTO: Codable, Hashable {
    let id: String
    let bookingId: String
    let agoraChannelName: String
    let sessionStatus: String
    let joinAllowedFrom: String?
    let startedAt: String?
    let endedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case bookingId = "booking_id"
        case agoraChannelName = "agora_channel_name"
        case sessionStatus = "session_status"
        case joinAllowedFrom = "join_allowed_from"
        case startedAt = "started_at"
        case endedAt = "ended_at"
    }
}

struct AgoraTokenResponseDTO: Codable, Hashable {
    let bookingId: String
    let sessionId: String
    let token: String
    let appId: String
    let channelName: String
    let role: String
    let expiresAt: String
}

struct IssueAgoraTokenRequestDTO: Codable, Hashable {
    let bookingId: String
}

// MARK: - Quote DTOs

struct QuoteDTO: Codable, Hashable {
    let id: String
    let text: String
    let author: String?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id, text, author
        case isActive = "is_active"
    }
}
