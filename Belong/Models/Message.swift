import Foundation

struct Message: Identifiable, Codable, Hashable {
    let id: String
    let conversationId: String
    let senderId: String
    var content: String?
    var imageURL: URL?
    var sharedPostId: String?
    var messageType: MessageType
    var reactions: [MessageReaction]
    var replyTo: ReplyReference?
    var status: MessageDeliveryStatus
    let createdAt: Date
    // Denormalized
    var senderName: String
    var senderAvatarEmoji: String
    var isCurrentUser: Bool
    var sharedPostPreview: SharedPostPreview?
}

enum MessageType: String, Codable {
    case text, image
    case sharedPost = "shared_post"
    case system
}

enum MessageDeliveryStatus: String, Codable {
    case sending, sent, delivered, read, failed
}

struct MessageReaction: Codable, Hashable {
    let emoji: String
    var count: Int
    var hasReacted: Bool
}

struct ReplyReference: Codable, Hashable {
    let messageId: String
    let senderName: String
    let previewText: String
}

struct SharedPostPreview: Codable, Hashable {
    let postId: String
    let imageURL: URL?
    let title: String
    let authorName: String
}
