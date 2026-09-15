import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var lobby = LobbyViewModel()

    @State private var appeared = false
    @State private var showLearn = false
    @State private var showCollection = false
    @State private var showLeaderboard = false
    @State private var titlePulse = false
    @State private var coinSpin = false
    @State private var headerGlow = false
    @State private var showEduSatellite: SatelliteCardDTO? = nil
    @State private var eduAlienAppeared = false

    // Unlocked & playable first → locked & playable (cheapest first) → not playable last
    private var sortedSatellites: [SatelliteCardDTO] {
        lobby.satellites.sorted { a, b in
            let aUnlocked = a.isUnlocked ?? false
            let bUnlocked = b.isUnlocked ?? false
            let aPlayable = a.isPlayable ?? true
            let bPlayable = b.isPlayable ?? true

            // 1. Unlocked before locked
            if aUnlocked != bUnlocked { return aUnlocked }
            // 2. Playable before not-playable
            if aPlayable != bPlayable { return aPlayable }
            // 3. Within same tier: cheapest unlock cost first
            return (a.unlockCost ?? 0) < (b.unlockCost ?? 0)
        }
    }

    var body: some View {
        ZStack {
            SpaceBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Header ──────────────────────────────────────────
                    VStack(spacing: 6) {
                        VStack(spacing: 4) {
                            Text("🛸")
                                .font(.system(size: 48))
                                .scaleEffect(titlePulse ? 1.08 : 1.0)
                                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: titlePulse)

                            Text("SPACE DEBRIS")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .tracking(3)
                                .foregroundStyle(
                                    LinearGradient(colors: [.cyan, .white, .purple],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .shadow(color: .cyan.opacity(headerGlow ? 0.8 : 0.3), radius: headerGlow ? 12 : 4)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: headerGlow)

                            Text("RESCUE")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .tracking(6)
                                .foregroundStyle(
                                    LinearGradient(colors: [.purple, .cyan],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .shadow(color: .purple.opacity(headerGlow ? 0.8 : 0.3), radius: headerGlow ? 12 : 4)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.3), value: headerGlow)

                            Text("Protect the satellites. Save Earth.")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 2)
                        }

                        HStack(spacing: 12) {
                            if let username = UserDefaults.standard.string(forKey: "user_username") {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.cyan.opacity(0.8))
                                    Text(username)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            Spacer()
                            Button {
                                Task {
                                    await AuthService.shared.logout()
                                    appState.isLoggedIn = false
                                    appState.screen = .intro
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("Sign Out")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.red.opacity(0.1))
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(.red.opacity(0.3), lineWidth: 1))
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    }
                    .padding(.top, 48)
                    .padding(.bottom, 20)

                    // ── Stats bar ────────────────────────────────────────
                    HStack(spacing: 12) {
                        StatPill(icon: "star.fill", label: "SCORE", value: lobby.totalScore.formatted(), color: .yellow)
                        StatPill(icon: "circle.hexagongrid.fill", label: "COINS", value: lobby.coins.formatted(), color: .orange)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    // ── Quick nav cards ──────────────────────────────────
                    HStack(spacing: 10) {
                        MenuCard(emoji: "📚", title: "LEARN", color: .purple) { showLearn = true }
                            .sheet(isPresented: $showLearn) { LearnView() }

                        MenuCard(emoji: "🪨", title: "COLLECT", color: .orange) { showCollection = true }
                            .sheet(isPresented: $showCollection) { CollectionView() }

                        MenuCard(emoji: "🏆", title: "RANKS", color: .yellow) {
                            showLeaderboard = true
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    // ── Satellites section header ─────────────────────────
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SATELLITES")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .tracking(3)
                                .foregroundColor(.white.opacity(0.4))
                            Text("Choose your mission")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        if !lobby.isLoading && lobby.errorMessage == nil {
                            Text("\(lobby.satellites.count) available")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.cyan.opacity(0.7))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.cyan.opacity(0.1))
                                        .overlay(Capsule().stroke(Color.cyan.opacity(0.3), lineWidth: 1))
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                    .opacity(appeared ? 1 : 0)

                    // ── Satellites grid ───────────────────────────────────
                    VStack(spacing: 0) {
                        if lobby.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .tint(.cyan)
                                    .scaleEffect(1.4)
                                Text("Scanning orbit...")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .frame(height: 210)

                        } else if let err = lobby.errorMessage {
                            VStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.orange)
                                Text(err)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                Button("Retry") { Task { await lobby.load() } }
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.cyan))
                            }
                            .frame(height: 210)

                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 14),
                                    GridItem(.flexible(), spacing: 14)
                                ],
                                spacing: 14
                            ) {
                                ForEach(sortedSatellites, id: \.satelliteId) { sat in
                                    SatelliteCardView(
                                        satellite: sat,
                                        isUnlocking: lobby.isUnlocking == sat.satelliteId,
                                        onUnlock: { Task { await lobby.unlock(satelliteId: sat.satelliteId) } },
                                        onPlay: {
                                            appState.selectedSatelliteId = sat.satelliteId
                                            appState.selectedSatelliteName = sat.name        // ← add this
                                            appState.selectedDifficultyTier = sat.difficultyTier
                                            appState.screen = .gameLoading
                                        },
                                        onDiscover: {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                                showEduSatellite = sat
                                            }
                                        }
                                    )
                                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)

                    // ── Unlock error toast ───────────────────────────────
                    if let unlockErr = lobby.unlockError {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.octagon.fill")
                                .foregroundColor(.white)
                            Text(unlockErr)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.red.opacity(0.85)))
                        .padding(.top, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
            }

            // ── Leaderboard overlay ──────────────────────────────────
            if showLeaderboard {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { withAnimation { showLeaderboard = false } }

                LeaderboardCard(onClose: { withAnimation { showLeaderboard = false } })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // ── Edu overlay ──────────────────────────────────────────
            if let sat = showEduSatellite {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            showEduSatellite = nil
                            eduAlienAppeared = false
                        }
                    }

                ZStack(alignment: .bottomTrailing) {
                    SatelliteEduSheet(
                        satelliteId: sat.satelliteId,
                        name: sat.name,
                        onClose: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                showEduSatellite = nil
                                eduAlienAppeared = false
                            }
                        }
                    )
                    .frame(
                        width: UIScreen.main.bounds.width * 0.92,
                        height: UIScreen.main.bounds.height * 0.78
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.5), radius: 30)

                    Image("alienlearn")
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height * 0.28)
                        .offset(x: eduAlienAppeared ? 10 : 120, y: 10)
                        .opacity(eduAlienAppeared ? 1 : 0)
                        .allowsHitTesting(false)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.65).delay(0.25),
                            value: eduAlienAppeared
                        )
                }
                .transition(.scale(scale: 0.95).combined(with: .opacity))
                .onAppear {
                    withAnimation {
                        eduAlienAppeared = true
                    }
                }
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: showLeaderboard)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: showEduSatellite?.satelliteId)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true }
            titlePulse = true
            headerGlow = true
            Task { await lobby.load() }
        }
        .animation(.spring(response: 0.4), value: lobby.unlockError)
    }
}

// MARK: - Supporting views

struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    @State private var shine = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(color.opacity(0.7))
                Text(value)
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.35), lineWidth: 1.5))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                shine = true
            }
        }
    }
}

struct MenuCard: View {
    let emoji: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 26))
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(color.opacity(0.5), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(GameButtonStyle())
    }
}

struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
