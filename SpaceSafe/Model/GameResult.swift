import Foundation

struct GameResult {
    let sessionId: UUID
    let satelliteId: UUID
    let score: Int
    let coinsEarned: Int
    let durationSeconds: Int
    let debrisCollectedCount: Int
}
