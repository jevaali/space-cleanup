import Foundation

struct GameLobbyDTO: Decodable {
    let coins: Int
    let totalScore: Int
    let satellites: [SatelliteCardDTO]
}

struct SatelliteCardDTO: Decodable {
    let satelliteId: UUID
    let name: String
    let isUnlocked: Bool
    let isPlayable: Bool
    let unlockCost: Int
    let highScore: Int?
    let difficultyTier: Int
}
