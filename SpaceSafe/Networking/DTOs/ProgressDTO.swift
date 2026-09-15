import Foundation

struct UserProgressOverviewDTO: Decodable {
    let username: String
    let totalScore: Int
    let coins: Int
    let totalSessions: Int
    let unlockedSatellites: Int
    let totalSatellites: Int
    let collectedDebris: Int
    let totalDebris: Int
    let collectionCompletionPercentage: Int
    let bestSatelliteScore: Int
    let lastPlayedAt: Date
}
