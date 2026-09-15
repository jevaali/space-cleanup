import Foundation

final class LeaderboardService {

    static let shared = LeaderboardService()
    private init() {}

    func fetchLeaderboard() async -> [LeaderboardEntry] {
        guard let url = URL(string: API.Endpoints.leaderboard) else {
            print("Invalid leaderboard URL")
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // ✅ Replaces URLSession.shared.data(for:)
            let (data, _) = try await AuthenticatedSession.data(for: request)
            printJson(data)
            let decoded = try JSONDecoder().decode(LeaderboardResponseDTO.self, from: data)
            return decoded.entries
        } catch {
            print("Leaderboard fetch error:", error)
            return []
        }
    }
}
