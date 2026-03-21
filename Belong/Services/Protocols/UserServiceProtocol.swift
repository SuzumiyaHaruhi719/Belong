import Foundation

protocol UserServiceProtocol: Sendable {
    func fetchMyProfile() async throws -> User
    func fetchProfile(userId: String) async throws -> User
    func updateProfile(displayName: String?, bio: String?, city: String?, school: String?) async throws -> User
    func updateAvatar(imageData: Data) async throws -> URL
    func updateTags(_ tags: [UserTag]) async throws
    func checkUsernameAvailability(_ username: String) async throws -> Bool
    func follow(userId: String) async throws
    func unfollow(userId: String) async throws
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
    func fetchCities(query: String) async throws -> [String]
    func fetchSchools(city: String) async throws -> [String]
    func fetchTagPresets(category: TagCategory) async throws -> [String]
}
