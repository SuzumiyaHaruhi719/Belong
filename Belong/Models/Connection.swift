import Foundation

// MARK: - Connection (post-event save)

struct Connection: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let avatarEmoji: String
    let mutualEvents: Int
    var isConnected: Bool = false
}
