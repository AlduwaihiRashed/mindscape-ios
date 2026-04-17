import Foundation

// Tab destinations (used with TabView selection)
enum MindscapeTab: String, CaseIterable, Hashable {
    case home
    case appointments
    case booking
    case yourSpace
    case profile

    var label: String {
        switch self {
        case .home: return "Home"
        case .appointments: return "Appointments"
        case .booking: return "Book"
        case .yourSpace: return "Your Space"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .appointments: return "calendar"
        case .booking: return "plus.circle"
        case .yourSpace: return "heart.text.square"
        case .profile: return "person"
        }
    }
}

// Push-navigation destinations (used with NavigationStack path)
enum MindscapeDestination: Hashable {
    case therapistDetail(therapistId: String)
    case checkout(bookingId: String)
    case sessionDetail(bookingId: String)
    case liveSession(bookingId: String)
}
