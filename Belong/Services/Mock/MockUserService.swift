import Foundation

@MainActor
final class MockUserService: UserServiceProtocol {
    private var currentUser: User?
    private var followingIds: Set<String> = []
    private var blockedIds: Set<String> = []
    private var savedGatheringIds: Set<String> = []
    private var savedPostIds: Set<String> = []

    nonisolated init() {}

    private func ensureUser() -> User {
        if currentUser == nil {
            currentUser = SampleData.currentUser
        }
        return currentUser!
    }

    nonisolated func fetchMyProfile() async throws -> User {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run { ensureUser() }
    }

    nonisolated func fetchProfile(userId: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(500))
        return SampleData.allUsers.first(where: { $0.id == userId }) ?? SampleData.allUsers[0]
    }

    nonisolated func updateProfile(displayName: String?, bio: String?, city: String?, school: String?) async throws -> User {
        try await Task.sleep(for: .milliseconds(700))
        return await MainActor.run {
            var user = ensureUser()
            if let displayName { user.displayName = displayName }
            if let bio { user.bio = bio }
            if let city { user.city = city }
            if let school { user.school = school }
            currentUser = user
            return user
        }
    }

    nonisolated func updateAvatar(imageData: Data) async throws -> URL {
        try await Task.sleep(for: .milliseconds(800))
        return URL(string: "https://picsum.photos/200")!
    }

    nonisolated func updateTags(_ tags: [UserTag]) async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    nonisolated func checkUsernameAvailability(_ username: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(400))
        return username.lowercased() != "taken"
    }

    nonisolated func follow(userId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            followingIds.insert(userId)
            if currentUser != nil {
                currentUser!.followingCount += 1
            }
        }
    }

    nonisolated func unfollow(userId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            followingIds.remove(userId)
            if currentUser != nil {
                currentUser!.followingCount = max(0, currentUser!.followingCount - 1)
            }
        }
    }

    nonisolated func block(userId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            blockedIds.insert(userId)
            followingIds.remove(userId)
        }
    }

    nonisolated func unblock(userId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            blockedIds.remove(userId)
        }
    }

    nonisolated func fetchFollowers(userId: String, page: Int) async throws -> [User] {
        try await Task.sleep(for: .milliseconds(600))
        return Array(SampleData.allUsers.prefix(5))
    }

    nonisolated func fetchFollowing(userId: String, page: Int) async throws -> [User] {
        try await Task.sleep(for: .milliseconds(600))
        return Array(SampleData.allUsers.prefix(3))
    }

    nonisolated func fetchMutuals(page: Int) async throws -> [User] {
        try await Task.sleep(for: .milliseconds(600))
        return Array(SampleData.allUsers.prefix(2))
    }

    nonisolated func fetchBlockedUsers() async throws -> [User] {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run {
            SampleData.allUsers.filter { blockedIds.contains($0.id) }
        }
    }

    nonisolated func fetchSavedGatherings() async throws -> [Gathering] {
        try await Task.sleep(for: .milliseconds(600))
        return SampleData.gatherings.filter { $0.isBookmarked }
    }

    nonisolated func fetchSavedPosts() async throws -> [Post] {
        try await Task.sleep(for: .milliseconds(600))
        return SampleData.posts.filter { $0.isSaved }
    }

    nonisolated func fetchBrowseHistory(type: BrowseTargetType?) async throws -> [BrowseHistoryEntry] {
        try await Task.sleep(for: .milliseconds(500))
        let history = SampleData.browseHistoryEntries
        if let type {
            return history.filter { $0.targetType == type }
        }
        return history
    }

    nonisolated func clearBrowseHistory() async throws {
        try await Task.sleep(for: .milliseconds(400))
    }

    nonisolated func fetchMyGatherings(role: String?) async throws -> [Gathering] {
        try await Task.sleep(for: .milliseconds(600))
        return SampleData.gatherings.filter { $0.isJoined }
    }

    nonisolated func fetchMyPosts() async throws -> [Post] {
        try await Task.sleep(for: .milliseconds(600))
        return SampleData.posts.filter { $0.authorId == SampleData.currentUser.id }
    }

    nonisolated func fetchCities(query: String) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(400))
        let cities = SampleData.cities
        if query.isEmpty { return cities }
        return cities.filter { $0.lowercased().contains(query.lowercased()) }
    }

    nonisolated func fetchSchools(city: String) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(400))
        return SampleData.schoolsByCity[city] ?? []
    }

    nonisolated func fetchTagPresets(category: TagCategory) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(400))
        switch category {
        case .culturalBackground: return SampleData.culturalBackgrounds
        case .language: return SampleData.languages
        case .interestVibe: return SampleData.interestVibes
        }
    }
}
