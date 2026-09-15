import Foundation

enum AuthenticatedSession {

    /// Performs a request with a valid JWT. On 401, refreshes once and retries.
    static func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var req = request
        try await req.attachValidJWT()

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        // On 401, force-refresh and retry once
        if http.statusCode == 401 {
            let newToken = try await TokenRefreshService.shared.refresh()
            var retryReq = request
            retryReq.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")

            let (retryData, retryResponse) = try await URLSession.shared.data(for: retryReq)
            guard let retryHttp = retryResponse as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            return (retryData, retryHttp)
        }

        return (data, http)
    }

    /// Same but for upload (POST/PUT with body)
    static func upload(for request: URLRequest, from body: Data) async throws -> (Data, HTTPURLResponse) {
        var req = request
        try await req.attachValidJWT()

        let (data, response) = try await URLSession.shared.upload(for: req, from: body)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if http.statusCode == 401 {
            let newToken = try await TokenRefreshService.shared.refresh()
            var retryReq = request
            retryReq.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")

            let (retryData, retryResponse) = try await URLSession.shared.upload(for: retryReq, from: body)
            guard let retryHttp = retryResponse as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            return (retryData, retryHttp)
        }

        return (data, http)
    }
}
