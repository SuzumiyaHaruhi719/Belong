import Foundation

struct HostingTemplate: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    let emoji: String
    let description: String
    let defaultTags: [String]
    let defaultMaxAttendees: Int
    let defaultVisibility: GatheringVisibility
    let defaultVibe: GatheringVibe
}
