import Foundation

@MainActor
final class MockAuthService: AuthServiceProtocol {
    nonisolated init() {}

    nonisolated func checkEmail(_ email: String) async throws -> (available: Bool, validEdu: Bool) {
        try await Task.sleep(for: .milliseconds(600))
        let isEdu = email.lowercased().hasSuffix(".edu")
        return (available: true, validEdu: isEdu)
    }

    nonisolated func sendOTP(to email: String) async throws {
        try await Task.sleep(for: .milliseconds(800))
        // Mock always succeeds — OTP code is "123456"
    }

    nonisolated func verifyOTP(email: String, code: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(500))
        return code == "123456"
    }

    nonisolated func checkUsername(_ username: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(500))
        // "taken" is the only unavailable username
        return username.lowercased() != "taken"
    }

    nonisolated func register(email: String, password: String, username: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(900))
        return SampleData.currentUser
    }

    nonisolated func login(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(700))
        return SampleData.currentUser
    }

    nonisolated func logout() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }
}
