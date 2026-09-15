import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    private var rankColor: Color {
        switch entry.rank {
        case 1: return .yellow
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .white.opacity(0.4)
        }
    }

    private var rankEmoji: String {
        switch entry.rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    var body: some View {
        HStack(spacing: 12) {

            // Rank
            if entry.rank <= 3 {
                Text(rankEmoji)
                    .font(.system(size: 24))
                    .frame(width: 40)
            } else {
                Text("#\(entry.rank)")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(rankColor)
                    .frame(width: 40, alignment: .center)
            }

            // Avatar
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.15))
                    .overlay(Circle().stroke(rankColor.opacity(0.35), lineWidth: 1))
                    .frame(width: 40, height: 40)
                Text(String(entry.username.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(rankColor)
            }

            // Username + subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.username)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Space Pilot")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.35))
            }

            Spacer()

            // Score
            VStack(alignment: .trailing, spacing: 1) {
                Text("SCORE")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.35))
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text("\(entry.score)")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(entry.rank <= 3
                      ? rankColor.opacity(0.08)
                      : Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(entry.rank <= 3
                                ? rankColor.opacity(0.3)
                                : Color.white.opacity(0.08),
                                lineWidth: 1)
                )
        )
    }
}
