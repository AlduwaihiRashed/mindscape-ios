import Foundation

enum MindscapeDestination: String, CaseIterable, Hashable {
    case home
    case appointments
    case booking
    case profile
    case sessions

    var label: String {
        switch self {
        case .home:
            return "Home"
        case .appointments:
            return "Appointments"
        case .booking:
            return "Book"
        case .profile:
            return "Profile"
        case .sessions:
            return "Sessions"
        }
    }
}
