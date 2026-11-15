import SwiftUI

struct SatelliteCardView: View {

    let satellite: SatelliteCard
    let onUnlock: () throws -> Void
    let onPlay: () -> Void
    let onDiscover: () -> Void

    @State private var glowing = false
    @State private var pulse = false
    @State private var appeared = false
    @State private var showUnlockConfirm = false
    @State private var satelliteRotation: Double = 0
    @State private var starScale: CGFloat = 1.0
    @State private var playButtonScale: CGFloat = 1.0

    private var tierColor: Color {
        switch satellite.difficultyTier {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        default: return .cyan
        }
    }

    private var tierLabel: String {
        switch satellite.difficultyTier {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Hard"
        case 4: return "Expert"
        default: return "Unknown"
        }
    }

    private var tierEmoji: String {
        switch satellite.difficultyTier {
        case 1: return "🟢"
        case 2: return "🟡"
        case 3: return "🟠"
        case 4: return "🔴"
        default: return "🔵"
        }
    }

    private var tierGradientColors: [Color] {
        switch satellite.difficultyTier {
        case 1: return [.green.opacity(0.3), .teal.opacity(0.15), .black.opacity(0.6)]
        case 2: return [.yellow.opacity(0.25), .orange.opacity(0.1), .black.opacity(0.6)]
        case 3: return [.orange.opacity(0.3), .red.opacity(0.1), .black.opacity(0.6)]
        case 4: return [.red.opacity(0.3), .pink.opacity(0.1), .black.opacity(0.6)]
        default: return [.cyan.opacity(0.2), .blue.opacity(0.1), .black.opacity(0.6)]
        }
    }

    private var cardGradient: LinearGradient {
        if satellite.isUnlocked {
            return LinearGradient(colors: tierGradientColors, startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.07), Color.black.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    private var borderColor: Color {
        guard satellite.isUnlocked else { return Color.white.opacity(0.1) }
        return tierColor.opacity(glowing ? 0.75 : 0.3)
    }

    private var shadowColor: Color {
        guard satellite.isUnlocked else { return .clear }
        return tierColor.opacity(glowing ? 0.4 : 0.15)
    }

    private var shadowRadius: CGFloat { glowing ? 14 : 6 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Satellite icon + lock/signal indicator ──────────────
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .stroke(tierColor.opacity(0.15), lineWidth: 1)
                        .frame(width: 88, height: 88)
                        .scaleEffect(pulse ? 1.2 : 1.0)
                        .opacity(pulse ? 0 : 0.6)
                        .animation(
                            satellite.isUnlocked
                                ? .easeOut(duration: 1.8).repeatForever(autoreverses: false)
                                : .default,
                            value: pulse
                        )

                    Circle()
                        .fill(tierColor.opacity(0.18))
                        .frame(width: 72, height: 72)
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .opacity(pulse ? 0.25 : 0.18)
                        .animation(
                            satellite.isUnlocked
                                ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                                : .default,
                            value: pulse
                        )

                    Image("Sat1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .opacity(satellite.isUnlocked ? 1.0 : 0.3)
                        .rotationEffect(.degrees(satelliteRotation))
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 18)
                .padding(.bottom, 10)

                Image(systemName: satellite.isUnlocked ? "dot.radiowaves.up.forward" : "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(satellite.isUnlocked ? .cyan : .white.opacity(0.3))
                    .padding(7)
                    .background(
                        Circle()
                            .fill(satellite.isUnlocked ? Color.cyan.opacity(0.15) : Color.white.opacity(0.06))
                            .overlay(Circle().stroke(
                                satellite.isUnlocked ? Color.cyan.opacity(0.4) : Color.white.opacity(0.15),
                                lineWidth: 1))
                    )
                    .padding([.top, .trailing], 12)
            }

            // ── Tier badge ───────────────────────────────────────────
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text(tierEmoji).font(.system(size: 8))
                    Text(tierLabel.uppercased())
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(tierColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(tierColor.opacity(0.12))
                        .overlay(Capsule().stroke(tierColor.opacity(0.45), lineWidth: 1))
                )
                Spacer()
            }
            .padding(.bottom, 8)

            // ── Name ──────────────────────────────────────────────────
            Text(satellite.name)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)

            // ── High score ────────────────────────────────────────────
            if satellite.isUnlocked && satellite.highScore > 0 {
                VStack(spacing: 2) {
                    Text("BEST")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.4))
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                            .scaleEffect(starScale)
                        Text("\(satellite.highScore)")
                            .font(.system(size: 26, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: .yellow.opacity(0.4), radius: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow.opacity(0.07))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1))
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }

            // ── Divider ───────────────────────────────────────────────
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)

            // ── Action buttons ────────────────────────────────────────
            actionButtons
                .padding(.horizontal, 10)
                .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20).fill(cardGradient))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(borderColor, lineWidth: 1.5))
        .shadow(color: shadowColor, radius: shadowRadius)
        .scaleEffect(appeared ? 1.0 : 0.88)
        .opacity(appeared ? 1.0 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.72), value: appeared)
        // Attached to the whole card so it stays open when the card flips to "unlocked"
        .sheet(isPresented: $showUnlockConfirm) {
            UnlockConfirmSheet(
                satellite: satellite,
                onConfirm: onUnlock,
                isPresented: $showUnlockConfirm
            )
        }
        .onAppear {
            appeared = true
            if satellite.isUnlocked {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    glowing = true
                    pulse = true
                }
                withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                    satelliteRotation = 360
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.5)) {
                    starScale = 1.3
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    playButtonScale = 1.04
                }
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if !satellite.isPlayable {
            Text("Coming Soon")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))

        } else if satellite.isUnlocked {
            VStack(spacing: 8) {
                Button(action: onPlay) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .black))
                        Text("Play Now")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading, endPoint: .trailing))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                }
                .scaleEffect(playButtonScale)

                Button(action: onDiscover) {
                    HStack(spacing: 4) {
                        Text("🔭").font(.system(size: 11))
                        Text("Discover")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.purple.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 1))
                    )
                }
            }

        } else {
            Button { showUnlockConfirm = true } label: {
                HStack(spacing: 5) {
                    Text("🪙").font(.system(size: 12))
                    Text("\(satellite.unlockCost)")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Unlock")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.18))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.55), lineWidth: 1))
                )
            }
        }
    }
}
