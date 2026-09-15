import SwiftUI


struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
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
                        Text("👨‍🚀")
                            .font(.system(size: 64))
                        Text("Join the Mission")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                        Text("Create your account and start saving Earth")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.easeOut(duration: 0.4), value: appeared)

                    // Fields
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            SpaceTextField(icon: "person", placeholder: "First Name", text: $firstName)
                            SpaceTextField(icon: "person", placeholder: "Last Name", text: $lastName)
                        }

                        SpaceTextField(icon: "at", placeholder: "Username", text: $username)
                            .textInputAutocapitalization(.never)

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

                    // Register button
                    SpacePrimaryButton(
                        title: isLoading ? "Preparing launch..." : "Begin Mission 🛸",
                        color: .purple,
                        isLoading: isLoading
                    ) {
                        Task { await handleRegister() }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

                    // Login link
                    Button {
                        appState.screen = .login
                    } label: {
                        HStack(spacing: 4) {
                            Text("Already a pilot?")
                                .foregroundColor(.white.opacity(0.6))
                            Text("Sign In")
                                .foregroundColor(.purple)
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

    func handleRegister() async {

        guard !email.isEmpty,
              !password.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !username.isEmpty else {

            errorMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            try await AuthService.shared.register(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
                username: username
            )

            appState.isLoggedIn = true
            appState.screen = .main

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Shared Components

struct SpaceTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.cyan.opacity(0.8))
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.white)
                .tint(.cyan)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.15), lineWidth: 1))
        )
    }
}

struct SpaceSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.cyan.opacity(0.8))
                .frame(width: 20)

            if isVisible {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white)
                    .tint(.cyan)
            } else {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white)
                    .tint(.cyan)
            }

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.15), lineWidth: 1))
        )
    }
}

struct SpacePrimaryButton: View {
    let title: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(0.85)
                }
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isLoading ? color.opacity(0.6) : color)
            )
        }
        .disabled(isLoading)
    }
}
