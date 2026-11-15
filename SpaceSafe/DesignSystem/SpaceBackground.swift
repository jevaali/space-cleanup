import SwiftUI

struct SpaceBackground: View {
    @State private var stars: [Star] = (0..<80).map { _ in Star() }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.03, blue: 0.15),
                    Color(red: 0.08, green: 0.02, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ForEach(stars) { star in
                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x, y: star.y)
            }
        }
    }
}

struct Star: Identifiable {
    let id = UUID()
    let x = CGFloat.random(in: 0...1200)
    let y = CGFloat.random(in: 0...900)
    let size = CGFloat.random(in: 1...3)
    let opacity = Double.random(in: 0.2...0.8)
}
