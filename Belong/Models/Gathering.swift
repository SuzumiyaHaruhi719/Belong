import Foundation

struct Gathering: Identifiable, Codable, Hashable {
    let id: String
    let hostId: String
    var title: String
    var description: String
    var templateType: GatheringTemplate
    var emoji: String
    var imageURL: URL?
    var city: String
    var school: String?
    var locationName: String
    var latitude: Double?
    var longitude: Double?
    var startsAt: Date
    var endsAt: Date?
    var maxAttendees: Int
    var visibility: GatheringVisibility
    var vibe: GatheringVibe
    var status: GatheringStatus
    var isDraft: Bool
    var tags: [String]
    var attendeeCount: Int
    var attendeeAvatars: [String]  // first 5 avatar URLs/emojis for face pile
    var hostName: String
    var hostAvatarEmoji: String
    var hostRating: Double
    var isBookmarked: Bool
    var isJoined: Bool
    var isMaybe: Bool
    var createdAt: Date

    var isFull: Bool { attendeeCount >= maxAttendees }
    var spotsRemaining: Int { max(0, maxAttendees - attendeeCount) }
    var isPast: Bool { startsAt < Date() }
    var formattedSpots: String {
        if isFull { return "Full" }
        let r = spotsRemaining
        if r <= 3 { return "\(r) spot\(r == 1 ? "" : "s") left" }
        return "\(attendeeCount)/\(maxAttendees) spots"
    }
}

enum GatheringTemplate: String, Codable, CaseIterable {
    case food, study, hangout, cultural, faith, active
}

enum GatheringVisibility: String, Codable, CaseIterable {
    case open
    case matchingTags = "matching_tags"
    case inviteOnly = "invite_only"
}

enum GatheringVibe: String, Codable, CaseIterable {
    case lowKey = "low_key"
    case hype, chill, welcoming
}

enum GatheringStatus: String, Codable, CaseIterable {
    case upcoming, ongoing, completed, cancelled
}
