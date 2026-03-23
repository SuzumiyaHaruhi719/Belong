import Foundation
import Supabase
import Auth

@MainActor
final class SupabaseAuthService: AuthServiceProtocol {
    private let manager = SupabaseManager.shared

    func checkEmail(_ email: String) async throws -> (available: Bool, validEdu: Bool) {
        let isEdu = email.lowercased().hasSuffix(".edu") || email.lowercased().hasSuffix(".edu.au")
        let existing: [DBUser] = try await manager.client.from("users")
            .select("id")
            .eq("email", value: email.lowercased())
            .limit(1)
            .execute()
            .value
        return (available: existing.isEmpty, validEdu: isEdu)
    }

    func sendOTP(to email: String) async throws {
        try await manager.client.auth.signInWithOTP(email: email.lowercased())
    }

    func verifyOTP(email: String, code: String) async throws -> Bool {
        do {
            try await manager.client.auth.verifyOTP(
                email: email.lowercased(),
                token: code,
                type: .email
            )
            return true
        } catch {
            return false
        }
    }

    func checkUsername(_ username: String) async throws -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let existing: [DBUser] = try await manager.client.from("users")
            .select("id")
            .eq("username", value: trimmed)
            .limit(1)
            .execute()
            .value
        return existing.isEmpty
    }

    func register(email: String, password: String, username: String) async throws -> User {
        let response = try await manager.client.auth.signUp(
            email: email.lowercased(),
            password: password,
            data: ["username": .string(username.lowercased())]
        )
        let authUser = response.user
        // The handle_new_user trigger creates the profile row automatically.
        // Update with username since trigger may not set it from metadata.
        let userId = authUser.id.uuidString.lowercased()
        try await manager.client.from("users")
            .update(UsernameUpdate(username: username.lowercased(), displayName: username))
            .eq("id", value: userId)
            .execute()

        return try await fetchUserProfile(userId: userId)
    }

    func login(email: String, password: String) async throws -> User {
        let session = try await manager.client.auth.signIn(
            email: email.lowercased(),
            password: password
        )
        let userId = session.user.id.uuidString.lowercased()
        return try await fetchUserProfile(userId: userId)
    }

    func logout() async throws {
        try await manager.client.auth.signOut()
    }

    func deleteAccount() async throws {
        guard let userId = manager.currentUserId else {
            throw SupabaseServiceError.notFound
        }
        // Delete user data from the users table
        try await manager.client.from("users")
            .delete()
            .eq("id", value: userId)
            .execute()
        // Sign out after deletion
        try await manager.client.auth.signOut()
    }

    // MARK: - Helpers

    private func fetchUserProfile(userId: String) async throws -> User {
        let rows: [DBUser] = try await manager.client.from("users")
            .select()
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value
        guard let row = rows.first else {
            throw SupabaseServiceError.notFound
        }
        return mapUserRow(row)
    }
}

// MARK: - User Mapping

func mapUserRow(_ row: DBUser) -> User {
    User(
        id: row.id,
        email: row.email ?? "",
        username: row.username ?? "",
        displayName: row.displayName ?? row.username ?? "",
        avatarURL: row.avatarUrl.flatMap { URL(string: $0) },
        defaultAvatarId: row.defaultAvatarId,
        profileBackgroundURL: row.profileBackgroundUrl.flatMap { URL(string: $0) },
        bio: row.bio ?? "",
        city: row.city ?? "",
        school: row.school ?? "",
        appLanguage: row.appLanguage ?? "en",
        privacyProfile: PrivacyLevel(rawValue: row.privacyProfile ?? "public") ?? .publicProfile,
        privacyDM: DMPrivacy(rawValue: row.privacyDm ?? "mutual_only") ?? .mutualOnly,
        notificationsEnabled: row.notificationsEnabled ?? true,
        followerCount: 0,
        followingCount: 0,
        mutualCount: 0,
        gatheringsAttended: 0,
        gatheringsHosted: 0,
        postCount: 0,
        createdAt: parseSupabaseDate(row.createdAt),
        lastActiveAt: parseSupabaseDate(row.lastActiveAt)
    )
}
