import Foundation

protocol AuthServiceProtocol: Sendable {
    func checkEmail(_ email: String) async throws -> (available: Bool, validEdu: Bool)
    func sendOTP(to email: String) async throws
    func verifyOTP(email: String, code: String) async throws -> Bool
    func checkUsername(_ username: String) async throws -> Bool  // true = available
    func register(email: String, password: String, username: String) async throws -> User
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func deleteAccount() async throws
}
