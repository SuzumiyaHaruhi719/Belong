import Foundation

enum SampleData {
    // MARK: - User Convenience
    static var currentUser: User { users[0] }
    static var topPick: Gathering { upcomingGatherings[0] }
    static var upcomingGatherings: [Gathering] { gatherings.filter { $0.status == .upcoming } }
    static var pastGatherings: [Gathering] { gatherings.filter { $0.status == .completed } }
    static var savedGatherings: [Gathering] { gatherings.filter { $0.isBookmarked } }

    /// Look up a sample user by their stable ID (used by MockAuthService).
    static func user(byId id: String) -> User? {
        allUsers.first { $0.id == id }
    }

    // MARK: - Profile Background Presets
    // Picsum seeded URLs for deterministic, beautiful cover photos.
    // Users can pick from these or upload their own.
    static let profileBackgrounds: [URL] = [
        URL(string: "https://picsum.photos/seed/belong-bg1/800/300")!,  // nature
        URL(string: "https://picsum.photos/seed/belong-bg2/800/300")!,  // city
        URL(string: "https://picsum.photos/seed/belong-bg3/800/300")!,  // sky
        URL(string: "https://picsum.photos/seed/belong-bg4/800/300")!,  // ocean
        URL(string: "https://picsum.photos/seed/belong-bg5/800/300")!,  // forest
        URL(string: "https://picsum.photos/seed/belong-bg6/800/300")!,  // mountain
    ]
}
