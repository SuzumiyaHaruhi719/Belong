import Foundation

struct GatheringFeedback: Identifiable, Codable, Hashable {
    let id: String
    let gatheringId: String
    let userId: String
    var emojiRating: FeedbackLevel
    var ratingScore: Int  // 1-5
    let createdAt: Date
}

enum FeedbackLevel: String, Codable, CaseIterable {
    case meh, okay, good, great, amazing
}
