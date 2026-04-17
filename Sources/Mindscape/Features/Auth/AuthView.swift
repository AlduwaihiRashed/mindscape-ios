import SwiftUI

struct AuthView: View {
    @ObservedObject var appState: MindscapeAppState
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""

    var body: some View {
        Form {
            if let statusMessage = appState.authState.statusMessage {
                Section {
                    Text(statusMessage)
                        .foregroundStyle(BrandPalette.primaryDeep)
                }
            }

            if let errorMessage = appState.authState.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(BrandPalette.error)
                }
            }

            Section("Sign in") {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)

                Button("Sign in") {
                    Task {
                        await appState.signIn(email: email, password: password)
                    }
                }
                .disabled(appState.authState.isLoading)
            }

            Section("Sign up") {
                TextField("Full name", text: $fullName)
                Button("Create account") {
                    Task {
                        await appState.signUp(email: email, password: password, fullName: fullName)
                    }
                }
                .disabled(appState.authState.isLoading)
            }

            Section("Reset password") {
                Button("Send reset email") {
                    Task {
                        await appState.resetPassword(email: email)
                    }
                }
                .disabled(appState.authState.isLoading)
            }

            if appState.authState.isLoading {
                Section {
                    ProgressView("Working...")
                }
            }
        }
        .navigationTitle("Auth")
    }
}
