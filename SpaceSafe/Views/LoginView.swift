import SwiftUI

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var appeared = false

    var body: some View {
        ZStack {
            SpaceBackground()

            ScrollView {
                VStack(spacing: 32) {

                    // Header
                    VStack(spacing: 8) {
                        Text("🛸")
                            .font(.system(size: 64))
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                        Text("Sign in to continue your mission")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 60)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.easeOut(duration: 0.4), value: appeared)

                    // Fields
                    VStack(spacing: 16) {
                        SpaceTextField(icon: "envelope", placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        SpaceSecureField(icon: "lock", placeholder: "Password", text: $password)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

                    // Error
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Login button
                    SpacePrimaryButton(
                        title: isLoading ? "Launching..." : "Launch Mission 🚀",
                        color: .cyan,
                        isLoading: isLoading
                    ) {
                        Task { await handleLogin() }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

                    // Register link
                    Button {
                        appState.screen = .register
                    } label: {
                        HStack(spacing: 4) {
                            Text("New recruit?")
                                .foregroundColor(.white.opacity(0.6))
                            Text("Create Account")
                                .foregroundColor(.cyan)
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 15, design: .rounded))
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear { appeared = true }
    }

    func handleLogin() async {

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            try await AuthService.shared.login(
                email: email,
                password: password
            )

            appState.isLoggedIn = true
            appState.screen = .main

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
