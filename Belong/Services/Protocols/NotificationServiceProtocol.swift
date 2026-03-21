import Foundation

protocol NotificationServiceProtocol: Sendable {
    func fetchNotifications(page: Int) async throws -> [AppNotification]
    func markAsRead(notificationId: String) async throws
    func markAllAsRead() async throws
    func getUnreadCount() async throws -> Int
}
