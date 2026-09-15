import SwiftUI


struct LearnFact: Identifiable {
    let id = UUID()

    let emoji: String
    let title: String
    let body: String
    let color: Color

    let quiz: QuizQuestion
}
