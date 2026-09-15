
import SwiftUI

struct LearnView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedFact: LearnFact?

    var body: some View {
        ZStack {
            SpaceBackground()

            VStack(spacing: 24) {

                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(.white.opacity(0.12)))
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Text("📚 Learn")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("Explore real space debris facts")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    Circle()
                        .fill(.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // Horizontal carousel
                TabView {
                    ForEach(spaceFacts) { fact in
                        LearnPreviewCard(fact: fact)
                            .padding(.horizontal, 24)
                            .onTapGesture {
                                selectedFact = fact
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 420)

                Spacer()
            }
        }
        .fullScreenCover(item: $selectedFact) { fact in
            LearnDetailView(fact: fact)
        }
    }
}
