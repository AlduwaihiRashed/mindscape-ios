import SwiftUI

struct MindscapeRootView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack {
                HomeView(appState: appState)
            }
            .tabItem { Label(MindscapeTab.home.label, systemImage: MindscapeTab.home.systemImage) }
            .tag(MindscapeTab.home)

            NavigationStack(path: $appState.navigationPath) {
                AppointmentsView(appState: appState)
                    .navigationDestination(for: MindscapeDestination.self) { destination in
                        navigationDestinationView(for: destination)
                    }
            }
            .tabItem { Label(MindscapeTab.appointments.label, systemImage: MindscapeTab.appointments.systemImage) }
            .tag(MindscapeTab.appointments)

            NavigationStack {
                BookingRootView(appState: appState)
                    .navigationDestination(for: MindscapeDestination.self) { destination in
                        navigationDestinationView(for: destination)
                    }
            }
            .tabItem { Label(MindscapeTab.booking.label, systemImage: MindscapeTab.booking.systemImage) }
            .tag(MindscapeTab.booking)

            NavigationStack {
                YourSpaceView(appState: appState)
            }
            .tabItem { Label(MindscapeTab.yourSpace.label, systemImage: MindscapeTab.yourSpace.systemImage) }
            .tag(MindscapeTab.yourSpace)

            NavigationStack {
                ProfileView(appState: appState)
            }
            .tabItem { Label(MindscapeTab.profile.label, systemImage: MindscapeTab.profile.systemImage) }
            .tag(MindscapeTab.profile)
        }
        .tint(BrandPalette.primary)
        .sheet(item: $appState.loginPrompt) { prompt in
            LoginSheet(appState: appState, prompt: prompt)
        }
    }

    @ViewBuilder
    private func navigationDestinationView(for destination: MindscapeDestination) -> some View {
        switch destination {
        case .therapistDetail(let therapistId):
            if let therapist = appState.discoveryState.therapists.first(where: { $0.id == therapistId }) {
                TherapistDetailView(appState: appState, therapist: therapist)
            } else {
                ContentUnavailableView("Therapist not found", systemImage: "person.slash")
            }
        case .checkout(let bookingId):
            CheckoutView(appState: appState, bookingId: bookingId)
        case .sessionDetail(let bookingId):
            SessionDetailView(appState: appState, bookingId: bookingId)
        case .liveSession(let bookingId):
            LiveSessionView(appState: appState, bookingId: bookingId)
        }
    }
}
