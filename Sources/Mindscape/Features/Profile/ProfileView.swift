import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: MindscapeAppState
    @State private var editingFullName = ""
    @State private var editingPhone = ""
    @State private var isEditing = false

    var body: some View {
        List {
            // Profile header
            Section {
                HStack(spacing: MindscapeSpacing.medium) {
                    Text(appState.drawerProfileSummary.initials)
                        .font(.title2.bold())
                        .frame(width: 64, height: 64)
                        .background(BrandPalette.primaryLight)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(appState.drawerProfileSummary.title)
                            .font(.headline)
                        Text(appState.drawerProfileSummary.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.textSecondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 6)
            }

            // Personal details
            if appState.isAuthenticated {
                Section("Personal details") {
                    if appState.profileState.isLoading {
                        ProgressView("Loading profile...")
                    } else if let profile = appState.profileState.profile {
                        if isEditing {
                            TextField("Full name", text: $editingFullName)
                            TextField("Phone (optional)", text: $editingPhone)
                                .keyboardType(.phonePad)
                        } else {
                            LabeledContent("Email", value: profile.email)
                            if let fullName = profile.fullName {
                                LabeledContent("Name", value: fullName)
                            }
                            if let phone = profile.phone {
                                LabeledContent("Phone", value: phone)
                            }
                        }
                    }

                    if let statusMessage = appState.profileState.statusMessage {
                        Text(statusMessage)
                            .foregroundStyle(BrandPalette.primaryDeep)
                            .font(.subheadline)
                    }

                    if let errorMessage = appState.profileState.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(BrandPalette.error)
                            .font(.subheadline)
                    }

                    if isEditing {
                        Button {
                            Task { await saveProfile() }
                        } label: {
                            if appState.profileState.isSaving {
                                ProgressView("Saving...")
                            } else {
                                Text("Save changes")
                            }
                        }
                        .disabled(appState.profileState.isSaving)

                        Button("Cancel", role: .cancel) {
                            isEditing = false
                        }
                    } else if appState.profileState.profile != nil {
                        Button("Edit profile") {
                            startEditing()
                        }
                    }
                }

                // Language
                Section("Language") {
                    Button {
                        Task {
                            let newLocale = appState.profileState.profile?.locale == "ar-KW" ? "en-KW" : "ar-KW"
                            await appState.updateLocale(newLocale)
                        }
                    } label: {
                        HStack {
                            Text("Language")
                            Spacer()
                            Text(appState.profileState.profile?.locale == "ar-KW" ? "Arabic" : "English")
                                .foregroundStyle(BrandPalette.primaryDeep)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            // Preferences
            Section("Preferences") {
                Toggle("Notifications", isOn: $appState.notificationsEnabled)
            }

            // Backend status (debug)
            Section("Backend") {
                LabeledContent(
                    "Supabase",
                    value: appState.supabaseConfiguration.isConfigured ? "Configured" : "Missing config"
                )

                if !appState.supabaseConfiguration.isConfigured {
                    Text(appState.supabaseConfiguration.missingConfigurationMessage())
                        .font(.footnote)
                        .foregroundStyle(BrandPalette.error)
                }
            }

            // Auth actions
            Section {
                if appState.isAuthenticated {
                    Button(role: .destructive) {
                        Task { await appState.signOut() }
                    } label: {
                        if appState.authState.isLoading {
                            ProgressView()
                        } else {
                            Text("Sign out")
                        }
                    }
                } else {
                    NavigationLink {
                        AuthView(appState: appState)
                    } label: {
                        Text("Sign in or create account")
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .scrollContentBackground(.visible)
    }

    private func startEditing() {
        let profile = appState.profileState.profile
        editingFullName = profile?.fullName ?? ""
        editingPhone = profile?.phone ?? ""
        isEditing = true
        appState.clearProfileMessages()
    }

    private func saveProfile() async {
        await appState.updateProfile(
            fullName: editingFullName,
            phone: editingPhone.isEmpty ? nil : editingPhone
        )
        if appState.profileState.errorMessage == nil {
            isEditing = false
        }
    }
}
