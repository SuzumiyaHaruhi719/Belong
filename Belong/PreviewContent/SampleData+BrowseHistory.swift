import Foundation

// MARK: - Browse History
extension SampleData {

    static let browseHistoryEntries: [BrowseHistoryEntry] = [
        BrowseHistoryEntry(
            id: "bh-001",
            userId: userIdMai,
            targetType: .gathering,
            targetId: gatheringIdPho,
            viewedAt: cal(.hour, -1),
            title: "Vietnamese Pho Cooking Class",
            imageURL: URL(string: "https://picsum.photos/seed/pho-cooking/400/250"),
            subtitle: "Starts in 2 days"
        ),
        BrowseHistoryEntry(
            id: "bh-002",
            userId: userIdMai,
            targetType: .post,
            targetId: postIdKdrama,
            viewedAt: cal(.hour, -3),
            title: "Just finished rewatching Crash Landing on You...",
            imageURL: URL(string: "https://picsum.photos/seed/kdrama-snacks/400/250"),
            subtitle: "Jin Park"
        ),
        BrowseHistoryEntry(
            id: "bh-003",
            userId: userIdMai,
            targetType: .gathering,
            targetId: gatheringIdLatinDance,
            viewedAt: cal(.hour, -5),
            title: "Latin Dance Social",
            imageURL: URL(string: "https://picsum.photos/seed/latin-dance/400/250"),
            subtitle: "Tomorrow"
        ),
        BrowseHistoryEntry(
            id: "bh-004",
            userId: userIdMai,
            targetType: .post,
            targetId: postIdMatchaGuide,
            viewedAt: cal(.hour, -8),
            title: "Your complete guide to making matcha...",
            imageURL: URL(string: "https://picsum.photos/seed/matcha-whisk/400/300"),
            subtitle: "Yuki Tanaka"
        ),
        BrowseHistoryEntry(
            id: "bh-005",
            userId: userIdMai,
            targetType: .gathering,
            targetId: gatheringIdHoli,
            viewedAt: cal(.day, -1),
            title: "Holi Festival Celebration",
            imageURL: URL(string: "https://picsum.photos/seed/holi-festival/400/250"),
            subtitle: "In 5 days"
        ),
        BrowseHistoryEntry(
            id: "bh-006",
            userId: userIdMai,
            targetType: .post,
            targetId: postIdJollofDebate,
            viewedAt: cal(.day, -1),
            title: "I said what I said: Nigerian jollof is the original...",
            imageURL: URL(string: "https://picsum.photos/seed/jollof-plated/400/300"),
            subtitle: "Sade Okafor"
        ),
    ]

    // MARK: - Private Helpers

    private static func cal(_ component: Calendar.Component, _ value: Int) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: Date())!
    }
}
