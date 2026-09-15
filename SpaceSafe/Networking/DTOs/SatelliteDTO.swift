import Foundation

struct SatelliteGameDetailsDTO: Decodable {
    let satelliteId: UUID
    let name: String
    let noradId: Int
    let operatorName: String?
    let launchDate: Date
    let semiMajorAxis: Double?
    let isPlayable: Bool
    let isUnlocked: Bool
    let unlockCost: Int
    let highScore: Int
    let difficultyTier: String
    let educationalInfo: String
    let funFact: String
    let imageUrl: String
}

struct UnlockSatelliteResponseDTO: Decodable {
    let success: Bool
    let error: String?
    let remainingCoins: Int
}
