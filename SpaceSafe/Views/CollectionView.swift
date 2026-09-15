import SwiftUI

struct CollectionView: View {
    @State private var items: [UserCollectionItemDTO] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var appeared = false

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.12).ignoresSafeArea()

            // Star field
            GeometryReader { geo in
                ForEach(0..<50, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.35)))
                        .frame(width: CGFloat.random(in: 1...2.5))
                        .position(
                            x: CGFloat(i * 37 % Int(geo.size.width)),
                            y: CGFloat(i * 71 % Int(geo.size.height))
                        )
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header ───────────────────────────────────────────
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DEBRIS ARCHIVE")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(3)
                                .foregroundColor(.orange.opacity(0.7))
                            Text("Collection")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [.white, .white.opacity(0.7)],
                                                   startPoint: .top, endPoint: .bottom)
                                )
                        }
                        Spacer()
                        // Item count badge
                        VStack(spacing: 2) {
                            Text("\(items.count)")
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text("items")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .tracking(1)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    // Rarity legend
                    if !items.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(["Common", "Uncommon", "Rare", "Epic", "Legendary"], id: \.self) { rarity in
                                    let count = items.filter { $0.riskCategory == rarity }.count
                                    if count > 0 {
                                        RarityPill(rarity: rarity, count: count)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 16)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -10)

                // ── Content ──────────────────────────────────────────
                if isLoading {
                    Spacer()
                    VStack(spacing: 14) {
                        ProgressView()
                            .tint(.orange)
                            .scaleEffect(1.3)
                        Text("Scanning debris field…")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Spacer()

                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("⚠️").font(.system(size: 44))
                        Text("Signal lost")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(error)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button("Retry") { Task { await loadCollection() } }
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(Color.orange))
                    }
                    Spacer()

                } else if items.isEmpty {
                    Spacer()
                    VStack(spacing: 14) {
                        Text("🪨").font(.system(size: 56))
                        Text("No debris yet")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Play a mission to start\ncollecting space debris")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()

                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(Array(items.enumerated()), id: \.element.debrisObjectId) { index, item in
                                CollectionItemCard(item: item)
                                    .opacity(appeared ? 1 : 0)
                                    .offset(y: appeared ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.8)
                                            .delay(Double(index) * 0.04),
                                        value: appeared
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
        .task { await loadCollection() }
    }

    func loadCollection() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await CollectionService.shared.fetchCollection()
            items = fetched.sorted { $0.collectedAt > $1.collectedAt }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Rarity Pill

struct RarityPill: View {
    let rarity: String
    let count: Int

    var color: Color {
        switch rarity {
        case "Common":    return Color(white: 0.55)
        case "Uncommon":  return Color(red: 0.3, green: 0.9, blue: 0.5)
        case "Rare":      return Color(red: 0.3, green: 0.6, blue: 1.0)
        case "Epic":      return Color(red: 0.8, green: 0.3, blue: 1.0)
        case "Legendary": return .yellow
        default:          return Color(white: 0.55)
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(rarity)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text("×\(count)")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(color.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
                .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
        )
    }
}

// MARK: - Collection Item Card

struct CollectionItemCard: View {
    let item: UserCollectionItemDTO
    @State private var showDetail = false
    @State private var glowing = false

    var imageName: String {
        DebrisImageStore.shared.imageName(for: item.debrisObjectId)
    }

    var rarityColor: Color {
        switch item.riskCategory {
        case "Common":    return Color(white: 0.55)
        case "Uncommon":  return Color(red: 0.3, green: 0.9, blue: 0.5)
        case "Rare":      return Color(red: 0.3, green: 0.6, blue: 1.0)
        case "Epic":      return Color(red: 0.8, green: 0.3, blue: 1.0)
        case "Legendary": return .yellow
        default:          return Color(white: 0.55)
        }
    }

    var isLegendary: Bool { item.riskCategory == "Legendary" }

    var body: some View {
        Button { showDetail = true } label: {
            VStack(spacing: 10) {

                // Image area
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(rarityColor.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(rarityColor.opacity(glowing ? 0.55 : 0.2), lineWidth: 1.5))

                    if isLegendary {
                        // Extra glow ring for legendaries
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(rarityColor.opacity(glowing ? 0.3 : 0.05), lineWidth: 6)
                            .blur(radius: 4)
                    }

                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 68, height: 68)
                        .padding(14)
                }
                .frame(height: 96)

                // Info
                VStack(spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(item.orbitZone.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.white.opacity(0.35))

                    // Rarity badge
                    Text(item.riskCategory)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(0.8)
                        .foregroundColor(rarityColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(rarityColor.opacity(0.12))
                                .overlay(Capsule().stroke(rarityColor.opacity(0.35), lineWidth: 1))
                        )
                }
                .padding(.bottom, 4)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1))
            )
        }
        .buttonStyle(GameButtonStyle())
        .onAppear {
            if item.riskCategory == "Legendary" || item.riskCategory == "Epic" {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    glowing = true
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            CollectionItemDetailView(item: item, imageName: imageName, rarityColor: rarityColor)
        }
    }
}

// MARK: - Detail Sheet

struct CollectionItemDetailView: View {
    let item: UserCollectionItemDTO
    let imageName: String
    let rarityColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var rotate = false

    var collectedDateString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: item.collectedAt)
    }

    var body: some View {
        ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.12).ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Image hero
                        ZStack {
                            Circle()
                                .fill(rarityColor.opacity(0.12))
                                .frame(width: 180, height: 180)
                                .blur(radius: 40)

                            Circle()
                                .stroke(rarityColor.opacity(0.2), lineWidth: 1)
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(rotate ? 360 : 0))
                                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: rotate)

                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                        }
                        .padding(.top, 16)

                        // Name + badges
                        VStack(spacing: 10) {
                            Text(item.name)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 8) {
                                Badge(text: item.riskCategory, color: rarityColor)
                                Badge(text: item.orbitZone, color: .white.opacity(0.45))
                                Badge(text: String(format: "%.0fm", item.sizeEstimate), color: .cyan.opacity(0.7))
                            }
                        }

                        // Stats row
                        HStack(spacing: 12) {
                            MiniStat(icon: "globe", label: "ORBIT", value: item.orbitZone)
                            MiniStat(icon: "ruler", label: "SIZE", value: String(format: "%.0fm", item.sizeEstimate))
                            MiniStat(icon: "calendar", label: "FOUND", value: shortDate(item.collectedAt))
                        }
                        .padding(.horizontal, 20)

                        // Info cards
                        VStack(spacing: 12) {
                            InfoCard(
                                icon: "book.fill",
                                title: "EDUCATIONAL INFO",
                                content: item.educationalInfo,
                                accentColor: .purple
                            )
                            InfoCard(
                                icon: "trash.fill",
                                title: "CLEANUP IMPORTANCE",
                                content: item.cleanupImportance,
                                accentColor: .orange
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 48)
                    }
                }
            }
        }
        .onAppear { rotate = true }
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

// MARK: - Mini stat tile

struct MiniStat: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
            Text(value)
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .tracking(1.2)
                .foregroundColor(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
    }
}

// MARK: - Small helpers

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .tracking(0.8)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
                    .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
            )
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
            }
            Text(content)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.82))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(accentColor.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.2), lineWidth: 1))
        )
    }
}
