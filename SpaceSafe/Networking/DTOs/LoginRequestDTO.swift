

struct LoginRequestDTO: Codable {
    let email: String
    let password: String
}


struct LoginResponseDTO: Codable {
    let jwt: String
    let refreshToken: String
}
