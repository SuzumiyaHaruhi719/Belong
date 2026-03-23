import Foundation
import Supabase

@MainActor
final class SupabaseNotificationService: NotificationServiceProtocol {
    private let manager = SupabaseManager.shared

    func fetchNotifications(page: Int) async throws -> [AppNotification] {
        let myId = try manager.requireUserId()
        let rows: [DBNotification] = try await manager.client.from("notifications")
            .select()
            .eq("recipient_id", value: myId)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * 30, to: page * 30 - 1)
            .execute()
            .value

        // Fetch actor info
        let actorIds = Array(Set(rows.compactMap(\.actorId)))
        var actorMap: [String: DBUser] = [:]
        if !actorIds.isEmpty {
            let actors: [DBUser] = try await manager.client.from("users")
                .select("id, display_name, username, avatar_url, default_avatar_id")
                .in("id", values: actorIds)
                .execute()
                .value
            actorMap = Dictionary(uniqueKeysWithValues: actors.map { ($0.id, $0) })
        }

        return rows.map { row in
            let actor = row.actorId.flatMap { actorMap[$0] }
            return AppNotification(
                id: row.id,
                recipientId: row.recipientId,
                actorId: row.actorId,
                type: NotificationType(rawValue: row.type) ?? .like,
                targetType: row.targetType,
                targetId: row.targetId,
                message: row.message ?? "",
                isRead: row.isRead,
                createdAt: parseSupabaseDate(row.createdAt),
                actorName: actor?.displayName ?? actor?.username,
                actorAvatarEmoji: "🙂",
                thumbnailURL: nil
            )
        }
    }

    func markAsRead(notificationId: String) async throws {
        try await manager.client.from("notifications")
            .update(IsReadUpdate(isRead: true))
            .eq("id", value: notificationId)
            .execute()
    }

    func markAllAsRead() async throws {
        let myId = try manager.requireUserId()
        try await manager.client.from("notifications")
            .update(IsReadUpdate(isRead: true))
            .eq("recipient_id", value: myId)
            .eq("is_read", value: false)
            .execute()
    }

    func getUnreadCount() async throws -> Int {
        let myId = try manager.requireUserId()
        let rows: [DBNotification] = try await manager.client.from("notifications")
            .select("id")
            .eq("recipient_id", value: myId)
            .eq("is_read", value: false)
            .execute()
            .value
        return rows.count
    }
}
