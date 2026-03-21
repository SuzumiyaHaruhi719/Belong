import Foundation

// MARK: - Chat Message

struct Message: Identifiable, Codable, Hashable {
    let id: String
    let senderName: String
    let senderAvatarEmoji: String
    let text: String
    let timestamp: Date
    let isCurrentUser: Bool
    let isPinned: Bool

    // Rich message features
    var messageType: MessageType
    var replyTo: ReplyReference?
    var reactions: [MessageReaction]
    var readByCount: Int
    var status: MessageStatus

    init(
        id: String,
        senderName: String,
        senderAvatarEmoji: String,
        text: String,
        timestamp: Date,
        isCurrentUser: Bool,
        isPinned: Bool,
        messageType: MessageType = .text,
        replyTo: ReplyReference? = nil,
        reactions: [MessageReaction] = [],
        readByCount: Int = 0,
        status: MessageStatus = .sent
    ) {
        self.id = id
        self.senderName = senderName
        self.senderAvatarEmoji = senderAvatarEmoji
        self.text = text
        self.timestamp = timestamp
        self.isCurrentUser = isCurrentUser
        self.isPinned = isPinned
        self.messageType = messageType
        self.replyTo = replyTo
        self.reactions = reactions
        self.readByCount = readByCount
        self.status = status
    }
}

// MARK: - Message Type

enum MessageType: String, Codable, Hashable {
    case text
    case image
    case system   // "Mai joined the group", "Event starts in 1 hour"
}

// MARK: - Reply Reference
/// Lightweight reference to a parent message for threading.

struct ReplyReference: Codable, Hashable {
    let messageId: String
    let senderName: String
    let previewText: String  // Truncated to ~60 chars
}

// MARK: - Message Reaction

struct MessageReaction: Codable, Hashable {
    let emoji: String
    var count: Int
    var hasReacted: Bool  // Current user reacted
}

// MARK: - Message Status

enum MessageStatus: String, Codable, Hashable {
    case sending
    case sent
    case delivered
    case read
    case failed
}
