import Foundation

@MainActor
final class MockNotificationService: NotificationServiceProtocol {
    private var notifications: [AppNotification] = []

    nonisolated init() {}

    private func ensureLoaded() {
        if notifications.isEmpty {
            notifications = SampleData.notifications
        }
    }

    nonisolated func fetchNotifications(page: Int) async throws -> [AppNotification] {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            ensureLoaded()
            return notifications
        }
    }

    nonisolated func markAsRead(notificationId: String) async throws {
        try await Task.sleep(for: .milliseconds(300))
        await MainActor.run {
            ensureLoaded()
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                notifications[index].isRead = true
            }
        }
    }

    nonisolated func markAllAsRead() async throws {
        try await Task.sleep(for: .milliseconds(500))
        await MainActor.run {
            ensureLoaded()
            for index in notifications.indices {
                notifications[index].isRead = true
            }
        }
    }

    nonisolated func getUnreadCount() async throws -> Int {
        try await Task.sleep(for: .milliseconds(300))
        return await MainActor.run {
            ensureLoaded()
            return notifications.filter { !$0.isRead }.count
        }
    }
}
