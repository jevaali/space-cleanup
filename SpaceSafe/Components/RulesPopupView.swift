import SwiftUI

struct RulesPopupView: View {
    let satelliteName: String
    let difficultyTier: Int
    let onStart: () -> Void

    @State private var satellitePulse = false
    @State private var appeared = false

    private var tierText: String {
        switch difficultyTier {
        case 1: return "★☆☆☆  EASY"
        case 2: return "★★☆☆  MEDIUM"
        case 3: return "★★★☆  HARD"
        default: return "★★★★  BRUTAL"
        }
    }

    private var tierColor: Color {
        switch difficultyTier {
        case 1: return Color(red: 0.2, green: 0.95, blue: 0.5)
        case 2: return Color(red: 1.0, green: 0.85, blue: 0.2)
        case 3: return Color(red: 1.0, green: 0.5, blue: 0.1)
        default: return Color(red: 1.0, green: 0.2, blue: 0.3)
        }
    }

    private var tierGlow: Color {
        tierColor.opacity(0.25)
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ────────────────────────────────────────────────
            VStack(spacing: 10) {
                // Glowing satellite emoji
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(satellitePulse ? 0.18 : 0.08))
                        .frame(width: 80, height: 80)
                        .scaleEffect(satellitePulse ? 1.12 : 1.0)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: satellitePulse)

                    Text("🛰️")
                        .font(.system(size: 42))
                        .scaleEffect(satellitePulse ? 1.06 : 1.0)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: satellitePulse)
                }

                Text(satelliteName.uppercased())
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .white, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Tier badge
                Text(tierText)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(tierColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(tierColor.opacity(0.12))
                            .overlay(Capsule().stroke(tierColor.opacity(0.5), lineWidth: 1))
                    )
                    .shadow(color: tierGlow, radius: 8)
            }
            .padding(.top, 28)
            .padding(.bottom, 22)

            // ── Divider ───────────────────────────────────────────────
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .cyan.opacity(0.3), .purple.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 20)

            // ── Rules ─────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 12) {
                SpacyRuleRow(icon: "👆", color: .cyan,   text: "Drag debris into Earth's atmosphere to collect coins")
                SpacyRuleRow(icon: "☄️", color: .orange, text: "Tap comets to destroy them before they hit")
                SpacyRuleRow(icon: "🛰️", color: .purple, text: "Don't let debris or comets reach the satellite")
                SpacyRuleRow(icon: "🌍", color: .green,  text: "Comets must not hit Earth or it's game over")
                SpacyRuleRow(icon: "⚡️", color: .yellow, text: "Survive longer — the game keeps speeding up")
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)

            // ── Divider ───────────────────────────────────────────────
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .cyan.opacity(0.3), .purple.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 20)

            // ── Start button ──────────────────────────────────────────
            Button(action: onStart) {
                HStack(spacing: 10) {
                    Text("🚀")
                        .font(.system(size: 18))
                    Text("LAUNCH MISSION")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .tracking(2)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, Color(red: 0.3, green: 0.8, blue: 1.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.4), radius: 12, y: 4)
                )
            }
            .buttonStyle(GameButtonStyle())
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
        }
        .background(
            ZStack {
                // Deep space base
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.04, green: 0.04, blue: 0.14))

                // Subtle nebula tint in corner
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.12),
                                Color.clear,
                                Color.cyan.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Border glow
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.5), .purple.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .padding(.horizontal, 22)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.94)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                appeared = true
            }
            satellitePulse = true
        }
    }
}

// MARK: - Rule Row

struct SpacyRuleRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.35), lineWidth: 1)
                    )
                    .frame(width: 36, height: 36)
                Text(icon)
                    .font(.system(size: 18))
            }

            Text(text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
