import Foundation

struct Block: Identifiable, Codable, Hashable {
    var id: String { "\(blockerId)_\(blockedId)" }
    let blockerId: String
    let blockedId: String
    let createdAt: Date
}
