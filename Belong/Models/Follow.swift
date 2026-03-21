import Foundation

struct Follow: Identifiable, Codable, Hashable {
    var id: String { "\(followerId)_\(followingId)" }
    let followerId: String
    let followingId: String
    let createdAt: Date
}
