import Combine
import Foundation

final class MindscapeAppState: ObservableObject {
    @Published var selectedTab: MindscapeDestination = .home
    @Published var session: UserSession?
    @Published var therapists: [TherapistSummary]
    @Published var upcomingAppointments: [AppointmentSummary]
    @Published var pastAppointments: [AppointmentSummary]
    @Published var concerns: [Concern]
    @Published var homeSnapshot: HomeUISnapshot
    @Published var profile: UserProfile?
    @Published var notificationsEnabled = true

    let supabaseConfiguration = SupabaseConfiguration.fromEnvironment()

    init() {
        therapists = MindscapeSampleData.therapists
        upcomingAppointments = MindscapeSampleData.upcomingAppointments
        pastAppointments = MindscapeSampleData.pastAppointments
        concerns = MindscapeSampleData.concerns
        homeSnapshot = MindscapeSampleData.homeSnapshot
        profile = MindscapeSampleData.profile
        session = nil
    }

    var drawerProfileSummary: DrawerProfileSummary {
        if let session {
            let displayName = session.fullName ?? session.email.split(separator: "@").first.map(String.init) ?? "Mindscape"
            let initials = displayName
                .split(separator: " ")
                .prefix(2)
                .compactMap { $0.first.map(String.init) }
                .joined()
                .uppercased()

            return DrawerProfileSummary(
                title: displayName,
                subtitle: session.email,
                initials: initials.isEmpty ? "M" : initials
            )
        }

        return DrawerProfileSummary(
            title: "Browsing as guest",
            subtitle: "Explore therapists freely. Sign in when you want to book or save progress.",
            initials: "G"
        )
    }
}
