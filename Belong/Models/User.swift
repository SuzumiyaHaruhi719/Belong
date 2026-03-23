import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var email: String
    var username: String
    var displayName: String
    var avatarURL: URL?
    var defaultAvatarId: Int?
    var profileBackgroundURL: URL? = nil    // Custom uploaded cover photo
    var defaultBackgroundId: Int? = nil     // Index into preset backgrounds (nil = warm gradient)
    var bio: String
    var city: String
    var school: String
    var appLanguage: String  // "en", "zh", "ko"
    var privacyProfile: PrivacyLevel  // public, schoolOnly, followersOnly
    var privacyDM: DMPrivacy  // mutualOnly, everyone
    var notificationsEnabled: Bool
    var followerCount: Int
    var followingCount: Int
    var mutualCount: Int
    var gatheringsAttended: Int
    var gatheringsHosted: Int
    var postCount: Int
    var createdAt: Date
    var lastActiveAt: Date

    var isOnboardingComplete: Bool { !city.isEmpty && !school.isEmpty }

    /// Maps `defaultAvatarId` (1-indexed) back to the onboarding emoji set.
    /// Returns nil if the ID is out of range or not set.
    static let avatarEmojis = ["🌿", "⭐", "🔥", "🌙", "🍊", "🌺", "💜", "🦋", "🌊", "✨"]

    var avatarEmoji: String? {
        guard let id = defaultAvatarId, id >= 1, id <= Self.avatarEmojis.count else { return nil }
        return Self.avatarEmojis[id - 1]
    }
}

enum PrivacyLevel: String, Codable, CaseIterable {
    case publicProfile = "public"
    case schoolOnly = "school_only"
    case followersOnly = "followers_only"
}

enum DMPrivacy: String, Codable, CaseIterable {
    case mutualOnly = "mutual_only"
    case everyone = "everyone"
}
