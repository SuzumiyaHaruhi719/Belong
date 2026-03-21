import Foundation

@MainActor
final class MockAuthService: AuthServiceProtocol {
    nonisolated init() {}

    // ──────────────────────────────────────────────────────
    // MARK: - Test Accounts
    // These credentials work for login during development.
    // In production, this entire file is replaced by a real
    // AuthService backed by Supabase / Firebase.
    // ──────────────────────────────────────────────────────

    private nonisolated let testAccounts: [(email: String, password: String, userId: String)] = [
        // Primary demo account — Mai Nguyen
        ("mai@unimelb.edu", "Belong123!", "u-00000001-mai-nguyen"),
        // Quick-test shorthand
        ("test@test.edu", "Test1234!", "u-00000001-mai-nguyen"),
        // Sample user accounts (all use same password)
        ("jin@monash.edu", "Belong123!", "u-00000002-jin-park"),
        ("priya@rmit.edu", "Belong123!", "u-00000003-priya-sharma"),
        ("amira@deakin.edu", "Belong123!", "u-00000004-amira-hassan"),
        ("carlos@latrobe.edu", "Belong123!", "u-00000005-carlos-mendez"),
        ("yuki@unimelb.edu", "Belong123!", "u-00000006-yuki-tanaka"),
    ]

    /// OTP code that always works in dev. In production, this is server-generated.
    private nonisolated let validOTPCode = "123456"

    // MARK: - AuthServiceProtocol

    nonisolated func checkEmail(_ email: String) async throws -> (available: Bool, validEdu: Bool) {
        try await Task.sleep(for: .milliseconds(600))
        let lowered = email.lowercased()
        let isEdu = lowered.hasSuffix(".edu") || lowered.hasSuffix(".edu.au")
        // If email matches an existing test account, mark as unavailable (already registered)
        let alreadyRegistered = testAccounts.contains { $0.email.lowercased() == lowered }
        return (available: !alreadyRegistered, validEdu: isEdu)
    }

    nonisolated func sendOTP(to email: String) async throws {
        try await Task.sleep(for: .milliseconds(800))
        // Mock always succeeds — OTP code is "123456"
    }

    nonisolated func verifyOTP(email: String, code: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(500))
        return code == validOTPCode
    }

    nonisolated func checkUsername(_ username: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(500))
        // "taken" and existing sample usernames are unavailable
        let reserved = ["taken", "mai.nguyen", "jin.park", "priya.sharma"]
        return !reserved.contains(username.lowercased())
    }

    nonisolated func register(email: String, password: String, username: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(900))
        return SampleData.currentUser
    }

    nonisolated func login(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(700))

        let lowered = email.lowercased().trimmingCharacters(in: .whitespaces)

        // Check against test accounts
        if let match = testAccounts.first(where: {
            $0.email.lowercased() == lowered && $0.password == password
        }) {
            // Return the matching sample user
            return SampleData.user(byId: match.userId) ?? SampleData.currentUser
        }

        // Wrong credentials → throw an error so the UI shows the error banner
        throw AuthError.invalidCredentials
    }

    nonisolated func logout() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailNotVerified
    case accountLocked

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .emailNotVerified:
            return "Please verify your email first."
        case .accountLocked:
            return "Account temporarily locked. Try again later."
        }
    }
}
