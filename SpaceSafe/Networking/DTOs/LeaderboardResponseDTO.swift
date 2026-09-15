import Foundation

struct LeaderboardResponseDTO: Codable {
    let entries: [LeaderboardEntry]
}

struct LeaderboardEntry: Codable, Identifiable {
    let username: String
    let score: Int
    let rank: Int

    var id: Int { rank }
}
