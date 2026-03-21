import Foundation

// MARK: - Notifications
extension SampleData {

    static let notifications: [AppNotification] = [
        // 1. Jin liked your post (pho recipe) — 1 hour ago, unread
        AppNotification(
            id: "notif-001",
            recipientId: userIdMai,
            actorId: userIdJin,
            type: .like,
            targetType: "post",
            targetId: postIdPhoRecipe,
            message: "Jin Park liked your post",
            isRead: false,
            createdAt: cal(.hour, -1),
            actorName: "Jin Park",
            actorAvatarEmoji: "⭐",
            thumbnailURL: URL(string: "https://picsum.photos/seed/pho-bowl/80/80")
        ),
        // 2. Priya commented on your post — 2 hours ago, unread
        AppNotification(
            id: "notif-002",
            recipientId: userIdMai,
            actorId: userIdPriya,
            type: .comment,
            targetType: "post",
            targetId: postIdPhoRecipe,
            message: "Priya Sharma commented: \"This looks amazing!\"",
            isRead: false,
            createdAt: cal(.hour, -2),
            actorName: "Priya Sharma",
            actorAvatarEmoji: "🔥",
            thumbnailURL: URL(string: "https://picsum.photos/seed/pho-broth/80/80")
        ),
        // 3. Yuki started following you — 3 hours ago, unread
        AppNotification(
            id: "notif-003",
            recipientId: userIdMai,
            actorId: userIdYuki,
            type: .follow,
            targetType: "user",
            targetId: userIdYuki,
            message: "Yuki Tanaka started following you",
            isRead: false,
            createdAt: cal(.hour, -3),
            actorName: "Yuki Tanaka",
            actorAvatarEmoji: "🌺",
            thumbnailURL: nil
        ),
        // 4. Carlos mentioned you in a comment — 5 hours ago, read
        AppNotification(
            id: "notif-004",
            recipientId: userIdMai,
            actorId: userIdCarlos,
            type: .mention,
            targetType: "comment",
            targetId: "c-00000004",
            message: "Carlos Mendez mentioned you in a comment",
            isRead: true,
            createdAt: cal(.hour, -5),
            actorName: "Carlos Mendez",
            actorAvatarEmoji: "🍊",
            thumbnailURL: nil
        ),
        // 5. Pho cooking class starts in 1 hour — reminder, 6 hours ago, read
        AppNotification(
            id: "notif-005",
            recipientId: userIdMai,
            actorId: nil,
            type: .gatheringReminder,
            targetType: "gathering",
            targetId: gatheringIdPho,
            message: "\"Vietnamese Pho Cooking Class\" starts in 1 hour",
            isRead: true,
            createdAt: cal(.hour, -6),
            actorName: nil,
            actorAvatarEmoji: "🍜",
            thumbnailURL: URL(string: "https://picsum.photos/seed/pho-cooking/80/80")
        ),
        // 6. Amira joined your gathering — 8 hours ago, read
        AppNotification(
            id: "notif-006",
            recipientId: userIdMai,
            actorId: userIdAmira,
            type: .gatheringJoined,
            targetType: "gathering",
            targetId: gatheringIdPotluck,
            message: "Amira Hassan joined your gathering \"Mixed Culture Potluck\"",
            isRead: true,
            createdAt: cal(.hour, -8),
            actorName: "Amira Hassan",
            actorAvatarEmoji: "🌙",
            thumbnailURL: nil
        ),
        // 7. Abel shared a new post — 12 hours ago, read
        AppNotification(
            id: "notif-007",
            recipientId: userIdMai,
            actorId: userIdAbel,
            type: .newPostFromFollowing,
            targetType: "post",
            targetId: postIdInjera,
            message: "Abel Tesfaye shared a new post",
            isRead: true,
            createdAt: cal(.hour, -12),
            actorName: "Abel Tesfaye",
            actorAvatarEmoji: "💜",
            thumbnailURL: URL(string: "https://picsum.photos/seed/injera-plate/80/80")
        ),
        // 8. Maria liked your post (hiking adventure) — 1 day ago, read
        AppNotification(
            id: "notif-008",
            recipientId: userIdMai,
            actorId: userIdMaria,
            type: .like,
            targetType: "post",
            targetId: postIdHiking,
            message: "Maria Santos liked your post",
            isRead: true,
            createdAt: cal(.day, -1),
            actorName: "Maria Santos",
            actorAvatarEmoji: "🦋",
            thumbnailURL: URL(string: "https://picsum.photos/seed/hiking-cliff/80/80")
        ),
        // 9. Wei started following you — 2 days ago, read
        AppNotification(
            id: "notif-009",
            recipientId: userIdMai,
            actorId: userIdWei,
            type: .follow,
            targetType: "user",
            targetId: userIdWei,
            message: "Wei Chen started following you",
            isRead: true,
            createdAt: cal(.day, -2),
            actorName: "Wei Chen",
            actorAvatarEmoji: "🌊",
            thumbnailURL: nil
        ),
        // 10. Latin Dance Social is tomorrow — reminder, 2 days ago, read
        AppNotification(
            id: "notif-010",
            recipientId: userIdMai,
            actorId: nil,
            type: .gatheringReminder,
            targetType: "gathering",
            targetId: gatheringIdLatinDance,
            message: "\"Latin Dance Social\" is tomorrow!",
            isRead: true,
            createdAt: cal(.day, -2),
            actorName: nil,
            actorAvatarEmoji: "💃",
            thumbnailURL: URL(string: "https://picsum.photos/seed/latin-dance/80/80")
        ),
        // 11. Sade commented on your post — 3 days ago, read
        AppNotification(
            id: "notif-011",
            recipientId: userIdMai,
            actorId: userIdSade,
            type: .comment,
            targetType: "post",
            targetId: postIdPhoRecipe,
            message: "Sade Okafor commented: \"I need this recipe!\"",
            isRead: true,
            createdAt: cal(.day, -3),
            actorName: "Sade Okafor",
            actorAvatarEmoji: "✨",
            thumbnailURL: URL(string: "https://picsum.photos/seed/pho-bowl/80/80")
        ),
        // 12. Jin shared a new gathering — 4 days ago, read
        AppNotification(
            id: "notif-012",
            recipientId: userIdMai,
            actorId: userIdJin,
            type: .newGatheringFromFollowing,
            targetType: "gathering",
            targetId: gatheringIdKpop,
            message: "Jin Park shared a new gathering \"K-pop Dance Workshop\"",
            isRead: true,
            createdAt: cal(.day, -4),
            actorName: "Jin Park",
            actorAvatarEmoji: "⭐",
            thumbnailURL: URL(string: "https://picsum.photos/seed/kpop-dance/80/80")
        ),
    ]

    // MARK: - Private Helpers

    private static func cal(_ component: Calendar.Component, _ value: Int) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: Date())!
    }
}
