import Foundation

extension URLRequest {
    mutating func attachValidJWT() async throws {
        let token = try await TokenRefreshService.shared.validToken()
        setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
