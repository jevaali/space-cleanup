import Foundation

enum ServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorized
    case notFound
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Invalid URL."
        case .invalidResponse:   return "Invalid server response."
        case .decodingError:     return "Failed to decode response."
        case .unauthorized:      return "Unauthorized. Please log in again."
        case .notFound:          return "Resource not found."
        case .serverError(let msg): return msg
        }
    }
}
