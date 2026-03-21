import SwiftUI

enum ChatSegment: String, CaseIterable {
    case notifications = "Notifications"
    case messages = "Messages"
}

@Observable @MainActor
final class ChatListViewModel {
    // MARK: - Dependencies
    private let chatService: any ChatServiceProtocol
    private let notificationService: any NotificationServiceProtocol

    // MARK: - State
    var conversations: [Conversation] = []
    var notifications: [AppNotification] = []
    var isLoading = false
    var error: String?
    var selectedSegment: ChatSegment = .messages
    var searchText = ""

    var unreadNotifCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var unreadNotifications: [AppNotification] {
        notifications.filter { !$0.isRead }
    }

    var readNotifications: [AppNotification] {
        notifications.filter { $0.isRead }
    }

    var filteredConversations: [Conversation] {
        if searchText.isEmpty { return conversations }
        let query = searchText.lowercased()
        return conversations.filter {
            $0.displayTitle.lowercased().contains(query) ||
            ($0.lastMessageText ?? "").lowercased().contains(query)
        }
    }

    // MARK: - Init
    init(chatService: any ChatServiceProtocol, notificationService: any NotificationServiceProtocol) {
        self.chatService = chatService
        self.notificationService = notificationService
    }

    // MARK: - Actions

    func loadConversations() async {
        isLoading = true
        error = nil
        do {
            conversations = try await chatService.fetchConversations()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadNotifications() async {
        isLoading = true
        error = nil
        do {
            notifications = try await notificationService.fetchNotifications(page: 1)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadAll() async {
        isLoading = true
        error = nil
        do {
            async let convos = chatService.fetchConversations()
            async let notifs = notificationService.fetchNotifications(page: 1)
            conversations = try await convos
            notifications = try await notifs
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func markAllNotificationsRead() async {
        do {
            try await notificationService.markAllAsRead()
            for index in notifications.indices {
                notifications[index].isRead = true
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func markNotificationRead(id: String) async {
        do {
            try await notificationService.markAsRead(notificationId: id)
            if let index = notifications.firstIndex(where: { $0.id == id }) {
                notifications[index].isRead = true
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
