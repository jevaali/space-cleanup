import SwiftUI

/// Local leaderboard: your best runs on this device.
struct LeaderboardView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject private var store = LocalStore.shared

    @State private var animateRows = false

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

                    Text("🏆 Best Runs")
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
                if store.runs.isEmpty {
                    emptyView
                } else {
                    runList
                }
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

            Text("No runs yet")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text("Finish a mission to set your first record")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            Spacer()
        }
    }

    var runList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(Array(store.runs.enumerated()), id: \.element.id) { index, run in
                    RunRow(rank: index + 1, run: run)
                        .opacity(animateRows ? 1 : 0)
                        .offset(y: animateRows ? 0 : 25)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(Double(min(index, 12)) * 0.07),
                            value: animateRows
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                animateRows = true
            }
        }
    }
}

// MARK: - Row

struct RunRow: View {
    let rank: Int
    let run: LocalRun

    private var rankLabel: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }

    private var accent: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.8)
        case 3: return .orange
        default: return .cyan
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Text(rankLabel)
                .font(.system(size: rank <= 3 ? 26 : 16, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(run.satelliteName)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("\(run.debrisCollected) debris · \(run.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))
            }

            Spacer()

            Text(run.score.formatted())
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundColor(accent)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(accent.opacity(rank <= 3 ? 0.1 : 0.05))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(accent.opacity(rank <= 3 ? 0.4 : 0.15), lineWidth: 1))
        )
    }
}
