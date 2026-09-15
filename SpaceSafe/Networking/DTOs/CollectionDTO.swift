import Foundation

struct UserCollectionItemDTO: Decodable {
    let debrisObjectId: UUID
    let name: String
    let riskCategory: String
    let sizeEstimate: Float
    let orbitZone: String
    let educationalInfo: String
    let cleanupImportance: String
    let earnedFromSatelliteId: UUID
    let collectedAt: Date
}
