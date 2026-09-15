import SwiftUI

struct LeaderboardView: View {

    @EnvironmentObject var appState: AppState

    @State private var entries: [LeaderboardEntry] = []
    @State private var loading = true
    @State private var animateRows = false
    @State private var animateSpinner = false

    @State private var rocketOffset: CGFloat = -40
    @State private var glowPulse = false

    var body: some View {

        ZStack {
            SpaceBackground()

            VStack(spacing: 0) {

                // HEADER
                HStack {

                    Button {
                        appState.screen = .main
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(.white.opacity(0.12)))
                    }

                    Spacer()

                    Text("🏆 Leaderboard")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing)
                        )

                    Spacer()

                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // CONTENT
                if loading {
                    loadingView
                }
                else if entries.isEmpty {
                    emptyView
                }
                else {
                    leaderboardList
                }
            }
        }
        .task {
            await load()
        }
    }
}


extension LeaderboardView {

    var loadingView: some View {
        VStack(spacing: 18) {

            Spacer()

            ZStack {

                // ORBIT SPINNER
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 2)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(animateSpinner ? 360 : 0))
                    .animation(
                        .linear(duration: 2.8)
                        .repeatForever(autoreverses: false),
                        value: animateSpinner
                    )

                // ROCKET
                Text("🚀")
                    .font(.system(size: 70))
                    .offset(y: rocketOffset)
            }

            Text("Calling our best space cleaners…")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.75))

            Text("Scanning orbital debris fields")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.white.opacity(0.5))

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    
    func startLoadingAnimation() {

        // reset
        rocketOffset = 0
        glowPulse = false
        animateSpinner = false

        // IMPORTANT: initial pause BEFORE anything moves
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {

            // rocket gentle drift (very slow)
            withAnimation(
                .easeInOut(duration: 4.2)
                .repeatForever(autoreverses: true)
            ) {
                rocketOffset = -18
            }

            // glow breathing (slow presence effect)
            withAnimation(
                .easeInOut(duration: 3.8)
                .repeatForever(autoreverses: true)
            ) {
                glowPulse = true
            }

            // spinner starts slightly later (feels “system booting”)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                animateSpinner = true
            }
        }
    }
}

extension LeaderboardView {

    var emptyView: some View {
        VStack(spacing: 12) {

            Spacer()

            Text("🛰️")
                .font(.system(size: 60))

            Text("No pilots yet")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text("Be the first to clean Earth’s orbit")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            Spacer()
        }
    }
}

extension LeaderboardView {

    var leaderboardList: some View {
        ScrollView(showsIndicators: false) {

            VStack(spacing: 14) {

                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in

                    LeaderboardRow(entry: entry)
                        .opacity(animateRows ? 1 : 0)
                        .offset(y: animateRows ? 0 : 25)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.07),
                            value: animateRows
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                animateRows = true
            }
        }
    }
}

extension LeaderboardView {

    func load() async {
        loading = true
        entries = await LeaderboardService.shared.fetchLeaderboard()
        loading = false
    }
}
