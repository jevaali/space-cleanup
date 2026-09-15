// MARK: - AuthService

import Foundation

final class AuthService {

    static let shared = AuthService()
    private init() {}

    func register(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        username: String
    ) async throws {

        guard let url = URL(string: API.Endpoints.register) else {
            throw AuthError.invalidURL
        }

        let body = RegisterRequestDTO(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            username: username
        )

        let encoded = try JSONEncoder().encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        printJson(data)

        switch httpResponse.statusCode {

        case 200...299:

            guard let dto = try? JSONDecoder().decode(LoginResponseDTO.self, from: data) else {
                throw AuthError.decodingError
            }

            // SAVE ONLY AFTER SUCCESS
            saveToken(dto.jwt)
            saveRefreshToken(dto.refreshToken)

            UserDefaults.standard.set(email, forKey: "user_email")
            UserDefaults.standard.set(firstName, forKey: "user_firstName")
            UserDefaults.standard.set(lastName, forKey: "user_lastName")
            UserDefaults.standard.set(username, forKey: "user_username")

        case 401:
            throw AuthError.unauthorized

        default:

            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw AuthError.serverError(apiError.message)
            }

            throw AuthError.serverError("Registration failed.")
        }
    }

    func login(email: String, password: String) async throws {

        guard let url = URL(string: API.Endpoints.login) else {
            throw AuthError.invalidURL
        }

        let body = LoginRequestDTO(email: email, password: password)

        let encoded = try JSONEncoder().encode(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        printJson(data)

        switch httpResponse.statusCode {

        case 200...299:

            guard let dto = try? JSONDecoder().decode(LoginResponseDTO.self, from: data) else {
                throw AuthError.decodingError
            }

            // SAVE ONLY AFTER SUCCESS
            saveToken(dto.jwt)
            saveRefreshToken(dto.refreshToken)

            UserDefaults.standard.set(email, forKey: "user_email")

        case 401:
            throw AuthError.unauthorized

        default:

            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw AuthError.serverError(apiError.message)
            }

            throw AuthError.serverError("Login failed.")
        }
    }

    // MARK: - Private helpers

    private func saveToken(_ jwt: String) {
        UserDefaults.standard.set(jwt, forKey: "jwt_token")
        NotificationCenter.default.post(name: .didLogin, object: nil)
        print("JWT saved successfully")
    }

    private func saveRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "refresh_token")
        print("Refresh token saved successfully")
    }
    
    func logout() async {
        guard let storedRefreshToken = UserDefaults.standard.string(forKey: "refresh_token") else {
            print("No refresh token found")
            return
        }

        guard let url = URL(string: API.Endpoints.logout) else { return }

        let body = LogoutDTO(refreshToken: storedRefreshToken)
        guard let encoded = try? JSONEncoder().encode(body) else {
            print("Failed to encode logout body")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (_, response) = try await URLSession.shared.upload(for: request, from: encoded)
            print(response)
        } catch {
            print("Logout error:", error)
        }

        // Always clear local data even if request fails
        clearLocalData()
    }

    private func clearLocalData() {
        UserDefaults.standard.removeObject(forKey: "jwt_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "user_firstName")
        UserDefaults.standard.removeObject(forKey: "user_lastName")
        UserDefaults.standard.removeObject(forKey: "user_username")
        print("Local data cleared")
    }
}

extension Notification.Name {
    static let didLogin = Notification.Name("didLogin")
}
