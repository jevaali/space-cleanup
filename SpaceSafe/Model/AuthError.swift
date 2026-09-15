import SwiftUI


enum AuthError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case decodingError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL."

        case .invalidResponse:
            return "Invalid server response."

        case .serverError(let message):
            return message

        case .decodingError:
            return "Failed to process server response."

        case .unauthorized:
            return "Invalid email or password."
        }
    }
}
