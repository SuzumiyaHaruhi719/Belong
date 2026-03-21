import Foundation

struct BrowseHistoryEntry: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    var targetType: BrowseTargetType
    var targetId: String
    let viewedAt: Date
    // Denormalized
    var title: String
    var imageURL: URL?
    var subtitle: String?
}

enum BrowseTargetType: String, Codable {
    case post, gathering
}
