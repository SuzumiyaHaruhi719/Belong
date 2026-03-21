import Foundation

struct GatheringMember: Identifiable, Codable, Hashable {
    var id: String { "\(gatheringId)_\(userId)" }
    let gatheringId: String
    let userId: String
    var status: MemberStatus
    let joinedAt: Date
    // Denormalized for display
    var userName: String
    var userAvatarEmoji: String
    var sharedTags: [String]
}

enum MemberStatus: String, Codable {
    case joined, maybe, saved, left
}
