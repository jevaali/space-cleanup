import Foundation

final class CollectionService {

    static let shared = CollectionService()
    private init() {}

    func fetchCollection() async throws -> [UserCollectionItemDTO] {
        guard let url = URL(string: API.Endpoints.collection) else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, http) = try await AuthenticatedSession.data(for: request)
        

        printJson(data)

        switch http.statusCode {
        case 200...299:
            let decoder = JSONDecoder()

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            decoder.dateDecodingStrategy = .formatted(formatter)

            return try decoder.decode([UserCollectionItemDTO].self, from: data)
        default:
            let msg = (try? JSONDecoder().decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Failed to fetch collection.")
        }
    }
}
