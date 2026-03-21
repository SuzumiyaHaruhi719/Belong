import Foundation

struct Conversation: Identifiable, Codable, Hashable {
    let id: String
    var type: ConversationType
    var gatheringId: String?  // non-nil for gathering groups
    var title: String?  // gathering title or other user's name
    var lastMessageText: String?
    var lastMessageAt: Date?
    var unreadCount: Int
    var members: [ConversationMemberInfo]
    let createdAt: Date
    var isMutualFollow: Bool  // for DM gating

    var displayTitle: String {
        if let title { return title }
        return members.map(\.displayName).joined(separator: ", ")
    }
    var displayAvatar: String {
        members.first?.avatarEmoji ?? "💬"
    }
}

enum ConversationType: String, Codable {
    case dm
    case gatheringGroup = "gathering_group"
}

struct ConversationMemberInfo: Codable, Hashable {
    let userId: String
    var displayName: String
    var avatarEmoji: String
    var avatarURL: URL?
}
