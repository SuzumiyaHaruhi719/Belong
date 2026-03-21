import Foundation

// MARK: - Gathering Model

struct Gathering: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var description: String
    var imageURL: URL?
    var hostName: String
    var hostAvatarEmoji: String
    var hostRating: Double
    var date: Date
    var location: String
    var attendeeCount: Int
    var maxAttendees: Int
    var attendeeAvatars: [String]  // Emoji strings for face pile
    var culturalTags: [String]
    var isBookmarked: Bool
    var status: GatheringStatus

    var isFull: Bool { attendeeCount >= maxAttendees }
    var spotsRemaining: Int { max(0, maxAttendees - attendeeCount) }
    var isPast: Bool { date < Date() }

    var formattedSpotsText: String {
        if isFull { return "Full" }
        let remaining = spotsRemaining
        if remaining <= 3 { return "\(remaining) spot\(remaining == 1 ? "" : "s") left" }
        return "\(attendeeCount) / \(maxAttendees) spots"
    }
}

enum GatheringStatus: String, Codable, CaseIterable {
    case upcoming
    case past
    case draft
    case cancelled
}
