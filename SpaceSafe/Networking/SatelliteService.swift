import Foundation

final class SatelliteService {

    static let shared = SatelliteService()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        d.dateDecodingStrategy = .formatted(formatter)
        return d
    }()

    func fetchDetails(satelliteId: UUID) async throws -> SatelliteGameDetailsDTO {
        guard let url = URL(string: "\(API.Endpoints.satelliteDetails)/\(satelliteId.uuidString)") else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, http) = try await AuthenticatedSession.data(for: request)

        printJson(data)

        switch http.statusCode {
        case 200...299:
            return try decoder.decode(SatelliteGameDetailsDTO.self, from: data)
        case 404:
            throw ServiceError.notFound
        default:
            let msg = (try? decoder.decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Failed to fetch satellite details.")
        }
    }

    func unlock(satelliteId: UUID) async throws -> UnlockSatelliteResponseDTO {
        guard let url = URL(string: "\(API.Endpoints.satelliteUnlock)/\(satelliteId.uuidString)") else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, http) = try await AuthenticatedSession.data(for: request)

        printJson(data)

        switch http.statusCode {
        case 200...299:
            return try decoder.decode(UnlockSatelliteResponseDTO.self, from: data)
        case 400:
            let msg = (try? decoder.decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Failed to unlock satellite.")
        default:
            let msg = (try? decoder.decode(APIErrorResponse.self, from: data))?.message
            throw ServiceError.serverError(msg ?? "Unexpected error.")
        }
    }
}
