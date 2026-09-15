import Foundation

final class ProgressService {

    static let shared = ProgressService()
    private init() {}

    func fetchProgress() async throws -> UserProgressOverviewDTO {
        guard let url = URL(string: API.Endpoints.progress) else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, http) = try await AuthenticatedSession.data(for: request)

        printJson(data)

        switch http.statusCode {
        case 200...299:
            return try JSONDecoder().decode(UserProgressOverviewDTO.self, from: data)
        case 404:
            throw ServiceError.notFound
        default:
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Failed to fetch progress.")
        }
    }
}
