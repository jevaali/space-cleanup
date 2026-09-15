import SwiftUI

struct LeaderboardCard: View {
    let onClose: () -> Void

    @State private var entries: [LeaderboardEntry] = []
    @State private var loading = true
    @State private var animateRows = false
    @State private var animateSpinner = false
    @State private var rocketOffset: CGFloat = 0
    

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                // Header
                HStack {
                    Text("🏆 Leaderboard")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Content
                if loading {
                    loadingView
                } else if entries.isEmpty {
                    emptyView
                } else {
                    listView
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(red: 0.06, green: 0.06, blue: 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .task { await load() }
    }

    // MARK: - Loading

    var loadingView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(
                        LinearGradient(colors: [.cyan, .purple],
                                       startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(animateSpinner ? 360 : 0))
                    .animation(.linear(duration: 2.8).repeatForever(autoreverses: false),
                               value: animateSpinner)

                Text("🚀")
                    .font(.system(size: 40))
                    .offset(y: rocketOffset)
            }

            Text("Scanning orbital debris fields…")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(height: 200)
        .onAppear {
            animateSpinner = true
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                rocketOffset = -10
            }
        }
    }

    // MARK: - Empty

    var emptyView: some View {
        VStack(spacing: 10) {
            Text("🛰️").font(.system(size: 48))
            Text("No pilots yet")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("Be the first to clean Earth's orbit")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(height: 200)
    }

    // MARK: - List

    var listView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    LeaderboardRow(entry: entry)
                        .opacity(animateRows ? 1 : 0)
                        .offset(y: animateRows ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(Double(index) * 0.06),
                            value: animateRows
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateRows = true
            }
        }
    }

    // MARK: - Load

    func load() async {
        loading = true
        entries = await LeaderboardService.shared.fetchLeaderboard()
        loading = false
    }
}
