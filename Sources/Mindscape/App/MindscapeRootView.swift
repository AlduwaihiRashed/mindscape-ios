import SwiftUI

struct MindscapeRootView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack {
                HomeView(appState: appState)
            }
            .tabItem {
                Label(MindscapeDestination.home.label, systemImage: "house")
            }
            .tag(MindscapeDestination.home)

            NavigationStack {
                AppointmentsView(appState: appState)
            }
            .tabItem {
                Label(MindscapeDestination.appointments.label, systemImage: "calendar")
            }
            .tag(MindscapeDestination.appointments)

            NavigationStack {
                ProfileView(appState: appState)
            }
            .tabItem {
                Label(MindscapeDestination.profile.label, systemImage: "person")
            }
            .tag(MindscapeDestination.profile)
        }
        .tint(BrandPalette.primary)
    }
}
