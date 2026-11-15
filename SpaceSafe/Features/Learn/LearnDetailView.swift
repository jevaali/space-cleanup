import SwiftUI

struct LearnDetailView: View {
    @Environment(\.dismiss) var dismiss

    let fact: LearnFact

    @State private var animate = false

    // Quiz state
    @State private var selectedAnswer: String?
    @State private var answered = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                colors: [
                    fact.color.opacity(0.35),
                    .black,
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            SpaceBackground()

            ScrollView(showsIndicators: false) {

                VStack(spacing: 32) {

                    // Top bar
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.15))
                                )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Hero section
                    VStack(spacing: 24) {

                        Text(fact.emoji)
                            .font(.system(size: 120))
                            .scaleEffect(animate ? 1 : 0.7)
                            .opacity(animate ? 1 : 0)
                            .shadow(color: fact.color, radius: 30)

                        VStack(spacing: 18) {

                            Text(fact.title)
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            RoundedRectangle(cornerRadius: 10)
                                .fill(fact.color)
                                .frame(width: 80, height: 6)

                            Text(fact.body)
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.white.opacity(0.88))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(8)
                        }
                        .padding(.horizontal, 28)
                    }

                    // QUIZ SECTION
                    VStack(spacing: 22) {

                        HStack(spacing: 10) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(fact.color)

                            Text("Knowledge Check")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Text(fact.quiz.question)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 14) {

                            ForEach(fact.quiz.answers, id: \.self) { answer in

                                Button {

                                    guard !answered else { return }

                                    selectedAnswer = answer
                                    answered = true

                                    if answer == fact.quiz.correctAnswer {
                                        withAnimation(.spring()) {
                                            showSuccess = true
                                        }
                                    }

                                } label: {

                                    HStack(spacing: 14) {

                                        Text(answer)
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)

                                        Spacer()

                                        if answered {

                                            if answer == fact.quiz.correctAnswer {

                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 24))

                                            } else if answer == selectedAnswer {

                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 24))
                                            }
                                        }
                                    }
                                    .padding(18)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .fill(cardColor(for: answer))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(borderColor(for: answer), lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Success message
                        if answered {

                            VStack(spacing: 10) {

                                if selectedAnswer == fact.quiz.correctAnswer {

                                    Text("✅ Correct!")
                                        .font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundColor(.green)

                                    Text("Great job space cadet. You protected orbital knowledge.")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.white.opacity(0.75))
                                        .multilineTextAlignment(.center)

                                } else {

                                    Text("❌ Not Quite")
                                        .font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundColor(.red)

                                    Text("Correct answer:")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))

                                    Text(fact.quiz.correctAnswer)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(fact.color.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                    .padding(.horizontal, 24)

                    Spacer(minLength: 60)
                }
            }
        }
        .onAppear {

            withAnimation(
                .spring(response: 0.7, dampingFraction: 0.8)
            ) {
                animate = true
            }
        }
    }

    // MARK: - Colors

    func cardColor(for answer: String) -> Color {

        guard answered else {
            return .white.opacity(0.08)
        }

        if answer == fact.quiz.correctAnswer {
            return .green.opacity(0.22)
        }

        if answer == selectedAnswer {
            return .red.opacity(0.22)
        }

        return .white.opacity(0.05)
    }

    func borderColor(for answer: String) -> Color {

        guard answered else {
            return .white.opacity(0.12)
        }

        if answer == fact.quiz.correctAnswer {
            return .green.opacity(0.8)
        }

        if answer == selectedAnswer {
            return .red.opacity(0.8)
        }

        return .clear
    }
}
