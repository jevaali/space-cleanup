import SwiftUI

struct IntroView: View {
    @EnvironmentObject var appState: AppState
    @State private var appeared = false
    @State private var showLearn = false


    var body: some View {
        ZStack {
            SpaceBackground()

            VStack(spacing: 32) {

                // Title
                VStack(spacing: 12) {
                    Text("🌍 Earth Needs You!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Thousands of debris objects are threatening working satellites right now. Drag debris into Earth's atmosphere to burn it up — and tap comets before they cause damage!")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                // Login banner (only when logged out)
                if !appState.isLoggedIn {
                    VStack(spacing: 14) {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.yellow)
                            Text("Sign in to play and collect debris")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.yellow.opacity(0.1))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.yellow.opacity(0.4), lineWidth: 1.5))
                        )

                        HStack(spacing: 12) {
                            IntroButton(title: "🔑  Sign In", color: .cyan) {
                                appState.screen = .login
                            }
                            IntroButton(title: "👨‍🚀  Register", color: .purple) {
                                appState.screen = .register
                            }
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)
                }

                // Main buttons
                VStack(spacing: 16) {
                    IntroButton(title: "🚀  Play Now", color: appState.isLoggedIn ? .cyan : .gray, disabled: !appState.isLoggedIn) {
                        appState.screen = .main
                    }
                    IntroButton(title: "📚  Learn About Space Debris", color: .purple) {
                        showLearn = true
                    }
                    IntroButton(title: "🏆  Leaderboard", color: .orange) {
                        appState.screen = .leaderboard
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
            .padding()
        }
        .sheet(isPresented: $showLearn) {
            LearnView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) { appeared = true }
        }
    }
}

struct IntroButton: View {
    let title: String
    let color: Color
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: { if !disabled { action() } }) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(disabled ? .white.opacity(0.3) : .white)
                .frame(maxWidth: 360)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(disabled ? 0.08 : 0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(color.opacity(disabled ? 0.2 : 1), lineWidth: 2)
                        )
                )
        }
        .allowsHitTesting(!disabled)
    }
}
