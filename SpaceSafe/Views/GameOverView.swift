import SwiftUI

struct GameOverView: View {
    let response: ProcessGameSessionResponseDTO
    let sessionResult: GameResult
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void

    @State private var appeared = false
    @State private var scoreScale: CGFloat = 0.5
    @State private var starPulse = false
    @State private var glowPulse = false

    var isHighScore: Bool { response.newHighScore }

    private var scoreGradient: LinearGradient {
        if isHighScore {
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom)
        }
    }

    private var cardGradient: LinearGradient {
        if isHighScore {
            return LinearGradient(
                colors: [Color(red: 0.15, green: 0.10, blue: 0.02), Color(red: 0.06, green: 0.06, blue: 0.18)],
                startPoint: .top, endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color(red: 0.06, green: 0.06, blue: 0.18), Color(red: 0.04, green: 0.04, blue: 0.14)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    private var borderColor: Color {
        guard isHighScore else { return Color.white.opacity(0.1) }
        return Color.yellow.opacity(glowPulse ? 0.6 : 0.2)
    }

    private var shadowColor: Color {
        guard isHighScore else { return .clear }
        return Color.yellow.opacity(glowPulse ? 0.3 : 0.1)
    }

    var body: some View {
        // Remove the VStack + Spacer wrapping — GameView now centers this
        VStack(spacing: 0) {
            dragHandle
            headerSection.padding(.bottom, 24)
            statsRow
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)

            if !response.rewardedDebris.isEmpty {
                debrisSection.padding(.bottom, 8)
            }
            buttonSection
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(cardGradient)
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(borderColor, lineWidth: 1.5))
        )
        .shadow(color: shadowColor, radius: 24)
        .onAppear {
            appeared = true
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65).delay(0.1)) { scoreScale = 1.0 }
            if isHighScore {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    starPulse = true; glowPulse = true
                }
            }
        }
    }

    // MARK: - Drag handle

    var dragHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.2))
            .frame(width: 40, height: 4)
            .padding(.top, 16)
            .padding(.bottom, 24)
    }

    // MARK: - Header

    var headerSection: some View {
        VStack(spacing: 8) {

            // Badge
            if isHighScore {
                HStack(spacing: 6) {
                    Text("⭐️")
                        .font(.system(size: 14))
                        .scaleEffect(starPulse ? 1.2 : 1.0)
                    Text("NEW HIGH SCORE")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.yellow)
                    Text("⭐️")
                        .font(.system(size: 14))
                        .scaleEffect(starPulse ? 1.2 : 1.0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.12))
                        .overlay(Capsule().stroke(Color.yellow.opacity(0.4), lineWidth: 1))
                )
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.cyan.opacity(0.8))
                    Text("MISSION COMPLETE")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.cyan.opacity(0.8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.cyan.opacity(0.08))
                        .overlay(Capsule().stroke(Color.cyan.opacity(0.25), lineWidth: 1))
                )
            }

            // Score
            ZStack {
                if isHighScore {
                    Text("\(sessionResult.score)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(.yellow.opacity(0.15))
                        .blur(radius: 12)
                        .scaleEffect(scoreScale)
                }
                Text("\(sessionResult.score)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(scoreGradient)
                    .scaleEffect(scoreScale)
            }

            Text("POINTS SCORED")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(2.5)
                .foregroundColor(.white.opacity(0.35))

            if response.firstCompletionRewardGranted {
                HStack(spacing: 5) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.purple)
                    Text("First completion bonus unlocked!")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.purple.opacity(0.9))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color.purple.opacity(0.1))
                        .overlay(Capsule().stroke(Color.purple.opacity(0.3), lineWidth: 1))
                )
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Stats row

    var statsRow: some View {
        HStack(spacing: 10) {
            GameStatPill(
                icon: "circle.hexagongrid.fill",
                iconColor: .orange,
                value: "+\(sessionResult.coinsEarned)",
                label: "EARNED"
            )
            GameStatPill(
                icon: "banknote.fill",
                iconColor: .yellow,
                value: "\(response.totalCoins)",
                label: "TOTAL COINS"
            )
        }
    }

    // MARK: - Debris section

    var debrisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.orange)
                Text("DEBRIS COLLECTED")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(2.5)
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text("\(response.rewardedDebris.count) pieces")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 24)

            ForEach(Array(response.rewardedDebris.enumerated()), id: \.offset) { index, debris in
                if let id = debris.debrisObjectId {
                    DebrisRewardCard(debris: debris, debrisId: id)
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.75)
                                .delay(0.3 + Double(index) * 0.08),
                            value: appeared
                        )
                }
            }
        }
    }

    // MARK: - Buttons

    var buttonSection: some View {
        VStack(spacing: 10) {
            Button(action: onPlayAgain) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .black))
                    Text("PLAY AGAIN")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .tracking(2)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading, endPoint: .trailing))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(GameButtonStyle())

            Button(action: onMainMenu) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("MAIN MENU")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .tracking(2)
                }
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.07))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1))
                )
            }
            .buttonStyle(GameButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 40)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
    }
}

// MARK: - Debris Reward Card

struct DebrisRewardCard: View {
    let debris: CollectDebrisResponseDTO
    let debrisId: UUID
    @State private var glowing = false

    var imageName: String {
        DebrisImageStore.shared.imageName(for: debrisId)
    }

    var rarityColor: Color {
        switch debris.rarity {
        case "Common":    return Color(white: 0.6)
        case "Uncommon":  return Color(red: 0.3, green: 0.9, blue: 0.5)
        case "Rare":      return Color(red: 0.3, green: 0.6, blue: 1.0)
        case "Epic":      return Color(red: 0.8, green: 0.3, blue: 1.0)
        case "Legendary": return .yellow
        default:          return .white
        }
    }

    var isSpecial: Bool {
        debris.rarity == "Epic" || debris.rarity == "Legendary"
    }

    private var cardBackground: Color {
        isSpecial ? rarityColor.opacity(0.07) : Color.white.opacity(0.04)
    }

    private var borderOpacity: Double {
        glowing ? 0.4 : 0.15
    }

    var body: some View {
        HStack(spacing: 14) {

            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(rarityColor.opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(rarityColor.opacity(glowing ? 0.6 : 0.25), lineWidth: 1.5))
                    .frame(width: 56, height: 56)

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
            }

            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(debris.name ?? "Unknown Debris")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Text(debris.rarity ?? "—")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(0.8)
                        .foregroundColor(rarityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(rarityColor.opacity(0.12))
                                .overlay(Capsule().stroke(rarityColor.opacity(0.35), lineWidth: 1))
                        )

                    if let zone = debris.orbitZone {
                        Text(zone.uppercased())
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.35))
                    }
                }
            }

            Spacer()

            // New badge or checkmark
            Text("NEW")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .tracking(1.2)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(rarityColor))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(rarityColor.opacity(borderOpacity), lineWidth: 1))
        )
        .padding(.horizontal, 24)
        .onAppear {
            if isSpecial {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    glowing = true
                }
            }
        }
    }
}

// MARK: - Game Stat Pill

struct GameStatPill: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.35))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(iconColor.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .stroke(iconColor.opacity(0.2), lineWidth: 1))
        )
    }
}
