import Foundation

final class SessionService {

    static let shared = SessionService()
    private init() {}

    func submitSession(_ session: ProcessGameSessionRequestDTO) async throws -> ProcessGameSessionResponseDTO {
        guard let url = URL(string: API.Endpoints.sessionSubmit) else {
            throw ServiceError.invalidURL
        }

        let encoded = try JSONEncoder().encode(session)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, http) = try await AuthenticatedSession.upload(for: request, from: encoded)

        printJson(data)

        switch http.statusCode {
        case 200...299:
            return try JSONDecoder().decode(ProcessGameSessionResponseDTO.self, from: data)
        case 400:
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Session submission failed.")
        default:
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Unexpected error.")
        }
    }

    func syncOfflineSessions(_ payload: SyncOfflineSessionsRequestDTO) async throws -> SyncOfflineSessionsResponseDTO {
        guard let url = URL(string: API.Endpoints.sessionSync) else {
            throw ServiceError.invalidURL
        }

        let encoded = try JSONEncoder().encode(payload)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, http) = try await AuthenticatedSession.upload(for: request, from: encoded)

        printJson(data)

        switch http.statusCode {
        case 200...299:
            return try JSONDecoder().decode(SyncOfflineSessionsResponseDTO.self, from: data)
        default:
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Sync failed.")
        }
    }
}
