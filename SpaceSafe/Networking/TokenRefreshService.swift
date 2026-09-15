import Foundation

final class TokenRefreshService {

    static let shared = TokenRefreshService()
    private init() {}

    private var refreshTask: Task<String, Error>?

    func validToken() async throws -> String {
        if let token = UserDefaults.standard.string(forKey: "jwt_token"), !isExpired(token) {
            return token
        }
        return try await refresh()
    }

    func refresh() async throws -> String {
        if let existing = refreshTask {
            return try await existing.value
        }

        let task = Task<String, Error> {
            defer { self.refreshTask = nil }

            guard let refreshToken = UserDefaults.standard.string(forKey: "refresh_token"),
                  let jwt = UserDefaults.standard.string(forKey: "jwt_token") else {
                throw AuthError.unauthorized
            }

            guard let url = URL(string: API.Endpoints.refreshToken) else {
                throw AuthError.invalidURL
            }

            let body = RefreshTokenDTO(jwt: jwt, refreshToken: refreshToken)
            let encoded = try JSONEncoder().encode(body)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)

            guard let http = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            printJson(data)

            switch http.statusCode {
            case 200...299:
                guard let dto = try? JSONDecoder().decode(LoginResponseDTO.self, from: data) else {
                    throw AuthError.decodingError
                }
                UserDefaults.standard.set(dto.jwt, forKey: "jwt_token")
                UserDefaults.standard.set(dto.refreshToken, forKey: "refresh_token")
                return dto.jwt

            default:
                self.forceLogout()
                throw AuthError.unauthorized
            }
        }

        refreshTask = task
        return try await task.value
    }

    private func isExpired(_ jwt: String) -> Bool {
        let parts = jwt.split(separator: ".").map(String.init)
        guard parts.count == 3 else { return true }

        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }

        return Date().timeIntervalSince1970 >= exp - 30
    }

    private func forceLogout() {
        UserDefaults.standard.removeObject(forKey: "jwt_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "user_firstName")
        UserDefaults.standard.removeObject(forKey: "user_lastName")
        UserDefaults.standard.removeObject(forKey: "user_username")
        NotificationCenter.default.post(name: .didForceLogout, object: nil)
    }
}

extension Notification.Name {
    static let didForceLogout = Notification.Name("didForceLogout")
}
