import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""

    var body: some View {
        Form {
            Section("Sign in") {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
                Button("Sign in") {}
            }

            Section("Sign up") {
                TextField("Full name", text: $fullName)
                Button("Create account") {}
            }

            Section("Reset password") {
                Button("Send reset email") {}
            }
        }
        .navigationTitle("Auth")
    }
}
