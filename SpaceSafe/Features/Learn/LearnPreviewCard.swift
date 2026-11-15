import SwiftUI

struct LearnPreviewCard: View {
    let fact: LearnFact

    @State private var shimmer = false
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [fact.color.opacity(0.22), Color.black.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(fact.color.opacity(shimmer ? 0.7 : 0.35), lineWidth: 1.5)
                )

            VStack(spacing: 0) {

                Spacer()

                // Floating emoji
                Text(fact.emoji)
                    .font(.system(size: 80))
                    .offset(y: floatOffset)
                    .animation(
                        .easeInOut(duration: 2.4).repeatForever(autoreverses: true),
                        value: floatOffset
                    )
                    .padding(.bottom, 20)

                // Title
                Text(fact.title)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                // Body preview
                Text(fact.body.prefix(110) + "…")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 28)

                Spacer()

                // "Tap to explore" pill
                HStack(spacing: 6) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text("TAP TO EXPLORE")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.5)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(fact.color)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(fact.color.opacity(0.12))
                        .overlay(Capsule().stroke(fact.color.opacity(0.4), lineWidth: 1))
                )
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                shimmer = true
            }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                floatOffset = -10
            }
        }
    }
}
