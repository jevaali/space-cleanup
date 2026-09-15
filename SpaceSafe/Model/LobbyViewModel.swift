import Foundation
import Combine

@MainActor
final class LobbyViewModel: ObservableObject {

    @Published var coins: Int = 0
    @Published var totalScore: Int = 0
    @Published var satellites: [SatelliteCardDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Unlock state
    @Published var isUnlocking: UUID? = nil
    @Published var unlockError: String? = nil
    @Published var unlockSuccess: UUID? = nil

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let lobby = try await LobbyService.shared.fetchLobby()
            coins = lobby.coins
            totalScore = lobby.totalScore
            satellites = lobby.satellites
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func unlock(satelliteId: UUID) async {
        guard isUnlocking == nil else { return }
        isUnlocking = satelliteId
        unlockError = nil
        unlockSuccess = nil
        do {
            let result = try await SatelliteService.shared.unlock(satelliteId: satelliteId)
            if result.success {
                coins = result.remainingCoins
                if let idx = satellites.firstIndex(where: { $0.satelliteId == satelliteId }) {
                    let old = satellites[idx]
                    satellites[idx] = SatelliteCardDTO(
                        satelliteId: old.satelliteId,
                        name: old.name,
                        isUnlocked: true,
                        isPlayable: old.isPlayable,
                        unlockCost: old.unlockCost,
                        highScore: old.highScore,
                        difficultyTier: old.difficultyTier
                    )
                }
                unlockSuccess = satelliteId
            } else {
                unlockError = result.error ?? "Could not unlock satellite."
            }
        } catch {
            unlockError = error.localizedDescription
        }
        isUnlocking = nil
    }
}
