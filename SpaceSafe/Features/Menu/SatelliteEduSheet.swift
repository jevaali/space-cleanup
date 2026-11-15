import SwiftUI

struct SatelliteEduSheet: View {

    let satellite: SatelliteCard
    let onClose: () -> Void

    @State private var showFunFact = false

    private var d: SatelliteCard { satellite }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.03, blue: 0.18), Color.black],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(0..<30, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.5)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                }
            }
            .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("🛰️").font(.system(size: 40))
                                Spacer()
                                Button(action: onClose) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }

                            Text(d.name)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)

                            Text("Operated by \(d.operatorName)")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.purple.opacity(0.8))
                        }

                        // Orbital stats
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(icon: "globe.americas.fill", title: "Orbital Data")
                            StatsGrid(items: [
                                ("NORAD ID",        "#\(d.noradId)"),
                                ("Difficulty",      d.difficultyLabel),
                                ("Launch Date",     formattedDate(d.launchDate)),
                                ("Altitude",        d.altitude),
                                ("High Score",      "\(d.highScore)"),
                            ])
                        }

                        // Educational info
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(icon: "book.fill", title: "About This Satellite")
                            Text(d.educationalInfo)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                                .lineSpacing(5)
                        }

                        // Fun fact
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(icon: "sparkles", title: "Fun Fact")
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.purple.opacity(0.12))
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1))

                                if showFunFact {
                                    Text(d.funFact)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineSpacing(5)
                                        .padding(16)
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                } else {
                                    Button {
                                        withAnimation(.spring(response: 0.4)) { showFunFact = true }
                                    } label: {
                                        VStack(spacing: 8) {
                                            Text("🔮").font(.system(size: 32))
                                            Text("Tap to reveal")
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                .foregroundColor(.purple.opacity(0.8))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 24)
                                    }
                                }
                            }
                            .animation(.spring(response: 0.4), value: showFunFact)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

// MARK: - Sub-components

struct SectionHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.purple)
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.2)
        }
    }
}

struct StatsGrid: View {
    let items: [(String, String)]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.0)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .textCase(.uppercase)
                        .tracking(0.8)
                    Text(item.1)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05)))
            }
        }
    }
}
