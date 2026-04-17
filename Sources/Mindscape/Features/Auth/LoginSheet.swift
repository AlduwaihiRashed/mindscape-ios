import SwiftUI

struct LoginSheet: View {
    @ObservedObject var appState: MindscapeAppState
    let prompt: LoginPrompt

    @State private var mode: SheetMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @Environment(\.dismiss) private var dismiss

    enum SheetMode { case signIn, signUp, resetPassword }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                    VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                        Text(prompt.title)
                            .font(.title2.bold())
                            .foregroundStyle(BrandPalette.textPrimary)
                        Text(prompt.subtitle)
                            .foregroundStyle(BrandPalette.textSecondary)
                    }

                    Picker("Mode", selection: $mode) {
                        Text("Sign in").tag(SheetMode.signIn)
                        Text("Create account").tag(SheetMode.signUp)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: mode) { _, _ in
                        appState.dismissLoginPrompt()
                    }

                    VStack(spacing: MindscapeSpacing.small) {
                        if mode == .signUp {
                            MindscapeTextField(placeholder: "Full name", text: $fullName)
                        }

                        MindscapeTextField(
                            placeholder: "Email address",
                            text: $email,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        if mode != .resetPassword {
                            MindscapeTextField(placeholder: "Password", text: $password, isSecure: true)
                        }
                    }

                    if let statusMessage = appState.authState.statusMessage {
                        MindscapeBanner(message: statusMessage, style: .success)
                    }

                    if let errorMessage = appState.authState.errorMessage {
                        MindscapeBanner(message: errorMessage, style: .error)
                    }

                    VStack(spacing: MindscapeSpacing.small) {
                        Button {
                            Task { await submit() }
                        } label: {
                            Group {
                                if appState.authState.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(primaryButtonTitle)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(BrandPalette.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .disabled(appState.authState.isLoading)

                        if mode == .signIn {
                            Button("Forgot password?") {
                                mode = .resetPassword
                            }
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.primaryDeep)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if mode == .resetPassword {
                            Button("Back to sign in") {
                                mode = .signIn
                            }
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.primaryDeep)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .padding(MindscapeSpacing.medium)
            }
            .background(BrandPalette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        appState.dismissLoginPrompt()
                        dismiss()
                    }
                }
            }
            .onChange(of: appState.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
        }
    }

    private var primaryButtonTitle: String {
        switch mode {
        case .signIn: return "Sign in"
        case .signUp: return "Create account"
        case .resetPassword: return "Send reset email"
        }
    }

    private func submit() async {
        switch mode {
        case .signIn:
            await appState.signIn(email: email, password: password)
        case .signUp:
            await appState.signUp(email: email, password: password, fullName: fullName.isEmpty ? nil : fullName)
        case .resetPassword:
            await appState.resetPassword(email: email)
        }
    }
}

// MARK: - Shared Input Components

struct MindscapeTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(BrandPalette.outline, lineWidth: 1))
    }
}

struct MindscapeBanner: View {
    enum Style { case success, error }

    let message: String
    let style: Style

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(style == .success ? BrandPalette.primaryDeep : BrandPalette.error)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background((style == .success ? BrandPalette.primaryLight : BrandPalette.error.opacity(0.08)))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
