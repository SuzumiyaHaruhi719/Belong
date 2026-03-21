import SwiftUI

@Observable @MainActor
final class NotificationListViewModel {
    private let notificationService: any NotificationServiceProtocol
    private let filter: NotificationFilter

    var notifications: [AppNotification] = []
    var isLoading = false
    var error: String?

    var unread: [AppNotification] {
        notifications.filter { !$0.isRead }
    }

    var read: [AppNotification] {
        notifications.filter { $0.isRead }
    }

    var hasUnread: Bool {
        !unread.isEmpty
    }

    init(notificationService: any NotificationServiceProtocol, filter: NotificationFilter) {
        self.notificationService = notificationService
        self.filter = filter
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            let all = try await notificationService.fetchNotifications(page: 1)
            notifications = all.filter { filter.matchingTypes.contains($0.type) }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func markRead(id: String) async {
        do {
            try await notificationService.markAsRead(notificationId: id)
            if let index = notifications.firstIndex(where: { $0.id == id }) {
                notifications[index].isRead = true
            }
        } catch {
            // Silent fail — notification still shows, just unread
        }
    }

    func markAllRead() async {
        do {
            try await notificationService.markAllAsRead()
            for index in notifications.indices {
                notifications[index].isRead = true
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
