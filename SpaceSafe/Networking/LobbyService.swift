import Foundation

final class LobbyService {

    static let shared = LobbyService()
    private init() {}

    func fetchLobby() async throws -> GameLobbyDTO {
        guard let url = URL(string: API.Endpoints.lobby) else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, http) = try await AuthenticatedSession.data(for: request)

        printJson(data)

        switch http.statusCode {
        case 200...299:
            return try JSONDecoder().decode(GameLobbyDTO.self, from: data)
        default:
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Failed to fetch lobby.")
        }
    }
}
