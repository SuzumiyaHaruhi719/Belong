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
}
