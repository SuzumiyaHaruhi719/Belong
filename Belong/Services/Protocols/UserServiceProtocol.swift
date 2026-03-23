import Foundation

protocol UserServiceProtocol: Sendable {
    func fetchMyProfile() async throws -> User
    func fetchProfile(userId: String) async throws -> User
    func updateProfile(displayName: String?, bio: String?, city: String?, school: String?) async throws -> User
    /// Generic field update for profile (avatar_url, profile_background_url, etc.)
    func updateProfile(_ fields: [String: String]) async throws
    func updateAvatar(imageData: Data) async throws -> URL
    func updateTags(_ tags: [UserTag]) async throws
    func checkUsernameAvailability(_ username: String) async throws -> Bool
    func follow(userId: String) async throws
    func unfollow(userId: String) async throws
    func isFollowing(userId: String) async throws -> Bool
    func block(userId: String) async throws
    func unblock(userId: String) async throws
    func fetchFollowers(userId: String, page: Int) async throws -> [User]
    func fetchFollowing(userId: String, page: Int) async throws -> [User]
    func fetchMutuals(page: Int) async throws -> [User]
    func fetchBlockedUsers() async throws -> [User]
    func fetchSavedGatherings() async throws -> [Gathering]
    func fetchSavedPosts() async throws -> [Post]
    func fetchBrowseHistory(type: BrowseTargetType?) async throws -> [BrowseHistoryEntry]
    func clearBrowseHistory() async throws
    func fetchMyGatherings(role: String?) async throws -> [Gathering]
    func fetchMyPosts() async throws -> [Post]
    func fetchUserPosts(userId: String) async throws -> [Post]
    func fetchUserGatherings(userId: String) async throws -> [Gathering]
    func fetchCities(query: String) async throws -> [String]
    func fetchSchools(city: String) async throws -> [String]
    func fetchTagPresets(category: TagCategory) async throws -> [String]
}
