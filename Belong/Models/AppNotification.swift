import Foundation

struct AppNotification: Identifiable, Codable, Hashable {
    let id: String
    let recipientId: String
    var actorId: String?
    var type: NotificationType
    var targetType: String?  // "post", "gathering", "comment", "user"
    var targetId: String?
    var message: String
    var isRead: Bool
    let createdAt: Date
    // Denormalized
    var actorName: String?
    var actorAvatarEmoji: String?
    var thumbnailURL: URL?
}

enum NotificationType: String, Codable, CaseIterable {
    case like, comment, follow, mention
    case gatheringReminder = "gathering_reminder"
    case gatheringJoined = "gathering_joined"
    case newPostFromFollowing = "new_post_from_following"
    case newGatheringFromFollowing = "new_gathering_from_following"
    case dmMessage = "dm_message"
    case followSuggestion = "follow_suggestion"

    var icon: String {
        switch self {
        case .like: "heart.fill"
        case .comment: "bubble.left.fill"
        case .follow: "person.badge.plus"
        case .mention: "at"
        case .gatheringReminder: "bell.fill"
        case .gatheringJoined: "person.3.fill"
        case .newPostFromFollowing: "doc.richtext"
        case .newGatheringFromFollowing: "calendar.badge.plus"
        case .dmMessage: "envelope.fill"
        case .followSuggestion: "person.2.fill"
        }
    }
}
