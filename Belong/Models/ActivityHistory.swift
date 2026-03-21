import Foundation

// MARK: - Activity History
// Tracks user engagement: browsing, joining, and hosting events.
// UX Decision: Showing history builds a sense of personal investment
// and helps users rediscover events they've interacted with.

struct BrowsingHistoryItem: Identifiable, Hashable {
    let id: String
    let gatheringId: String
    let gatheringTitle: String
    let gatheringImageURL: URL?
    let culturalTags: [String]
    let viewedAt: Date
    let hostName: String
}

struct EventJoinHistoryItem: Identifiable, Hashable {
    let id: String
    let gatheringId: String
    let gatheringTitle: String
    let gatheringImageURL: URL?
    let hostName: String
    let hostAvatarEmoji: String
    let date: Date
    let location: String
    let attendeeCount: Int
    let culturalTags: [String]
    let ratingGiven: Int?          // 1-5 star equivalent, nil = not rated yet
    let feedbackEmoji: String?     // The emoji they picked in post-event feedback
    var status: JoinStatus
}

enum JoinStatus: String, Codable, Hashable {
    case confirmed     // Actively joined, event upcoming
    case attended      // Event happened, user was there
    case missed        // Event happened, user didn't show (or cancelled)
    case cancelled     // User cancelled before event
}

struct EventHostHistoryItem: Identifiable, Hashable {
    let id: String
    let gatheringId: String
    let gatheringTitle: String
    let gatheringImageURL: URL?
    let date: Date
    let location: String
    let attendeeCount: Int
    let maxAttendees: Int
    let culturalTags: [String]
    let averageRating: Double?    // nil if no ratings yet
    let status: HostedEventStatus
}

enum HostedEventStatus: String, Codable, Hashable {
    case draft
    case published      // Upcoming, live
    case completed      // Past, went ahead
    case cancelled      // Host cancelled
}
