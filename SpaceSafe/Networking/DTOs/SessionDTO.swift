import Foundation

struct ProcessGameSessionRequestDTO: Encodable {
    let sessionId: UUID
    let satelliteId: UUID
    let score: Int
    let coinsEarned: Int
    let durationSeconds: Int
    let debrisCollectedCount: Int
    let syncedOfflineGame: Bool
}

struct ProcessGameSessionResponseDTO: Decodable {
    let success: Bool
    let error: String?
    let totalCoins: Int
    let totalScore: Int
    let newHighScore: Bool
    let firstCompletionRewardGranted: Bool
    let rewardedDebris: [CollectDebrisResponseDTO]
}

struct CollectDebrisResponseDTO: Decodable {
    let success: Bool
    let error: String?
    let debrisObjectId: UUID?
    let name: String?
    let orbitZone: String?
    let rarity: String?
}

struct SyncOfflineSessionsRequestDTO: Encodable {
    let sessions: [ProcessGameSessionRequestDTO]
}

struct SyncOfflineSessionsResponseDTO: Decodable {
    let totalProcessed: Int
    let successful: Int
    let failed: Int
    let errors: [String]
}

extension ProcessGameSessionResponseDTO: Identifiable {
    var id: Int { totalScore }
}
