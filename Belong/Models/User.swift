import Foundation

// MARK: - User Model

struct User: Identifiable, Codable, Hashable {
    let id: String
    var email: String
    var username: String
    var displayName: String
    var avatarURL: URL?
    var avatarEmoji: String   // Default avatar if no photo
    var city: String
    var school: String
    var language: String
    var culturalTags: CulturalTags
    var stats: UserStats

    var isOnboardingComplete: Bool {
        !city.isEmpty && !school.isEmpty
    }
}

struct CulturalTags: Codable, Hashable {
    var background: [String]
    var languages: [String]
    var interests: [String]

    var isEmpty: Bool {
        background.isEmpty && languages.isEmpty && interests.isEmpty
    }

    var allTags: [String] {
        background + languages + interests
    }

    static let empty = CulturalTags(background: [], languages: [], interests: [])
}

struct UserStats: Codable, Hashable {
    var attended: Int
    var hosted: Int
    var connections: Int
}
