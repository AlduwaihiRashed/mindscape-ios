import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        List {
            Section("Account") {
                VStack(alignment: .leading, spacing: 6) {
                    Text(appState.drawerProfileSummary.title)
                        .font(.headline)
                    Text(appState.drawerProfileSummary.subtitle)
                        .foregroundStyle(BrandPalette.textSecondary)
                }

                if let profile = appState.profile {
                    LabeledContent("Email", value: profile.email)
                    LabeledContent("Locale", value: profile.locale)
                }
            }

            Section("Preferences") {
                Toggle("Notifications", isOn: $appState.notificationsEnabled)
            }

            Section("Backend") {
                LabeledContent("Supabase", value: appState.supabaseConfiguration.isConfigured ? "Configured" : "Missing config")

                if !appState.supabaseConfiguration.isConfigured {
                    Text(appState.supabaseConfiguration.missingConfigurationMessage())
                        .font(.footnote)
                        .foregroundStyle(BrandPalette.error)
                }
            }

            Section("Auth") {
                NavigationLink {
                    AuthView()
                } label: {
                    Text("Open auth flow skeleton")
                }
            }
        }
        .navigationTitle("Profile")
    }
}
