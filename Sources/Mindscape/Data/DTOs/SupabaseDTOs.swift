import Foundation

struct ProfileDTO: Codable, Hashable {
    let id: String
    let email: String
    let fullName: String?
    let phone: String?
    let locale: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case phone
        case locale
    }
}

struct ProfileUpdateDTO: Codable, Hashable {
    let locale: String
}

struct ProfileInsertDTO: Codable, Hashable {
    let id: String
    let email: String
    let fullName: String?
    let phone: String?
    let locale: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case phone
        case locale
    }
}

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
        case id
        case fullName = "full_name"
        case title
        case specialization
        case bio
        case languages
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
        case id
        case therapistId = "therapist_id"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case status
    }
}

struct BookingDTO: Codable, Hashable {
    let id: String
    let therapistId: String
    let bookingStatus: String
    let sessionMode: String
    let scheduledStartsAt: String
    let scheduledEndsAt: String
    let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case therapistId = "therapist_id"
        case bookingStatus = "booking_status"
        case sessionMode = "session_mode"
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

struct CancelBookingRequestDTO: Codable, Hashable {
    let bookingId: String
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case bookingId = "p_booking_id"
        case reason = "p_reason"
    }
}
