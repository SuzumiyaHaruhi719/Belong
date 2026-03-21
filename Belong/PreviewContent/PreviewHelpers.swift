import SwiftUI

// MARK: - Preview Container

/// Wraps content with the app's standard preview environment.
/// Usage:
/// ```
/// #Preview {
///     PreviewContainer {
///         MyView()
///     }
/// }
/// ```
struct PreviewContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
    }
}

// MARK: - Preview Modifiers

extension View {
    /// Configures the view for preview with sample data context.
    func previewEnvironment() -> some View {
        self
    }
}

// MARK: - Preview Convenience

extension SampleData {
    /// Returns a random subset of users for preview face piles.
    static func randomUsers(_ count: Int) -> [User] {
        Array(users.shuffled().prefix(count))
    }

    /// Returns a user by their stable ID.
    static func user(id: String) -> User? {
        allUsers.first { $0.id == id }
    }

    /// Returns a gathering by its stable ID.
    static func gathering(id: String) -> Gathering? {
        gatherings.first { $0.id == id }
    }

    /// Returns a post by its stable ID.
    static func post(id: String) -> Post? {
        posts.first { $0.id == id }
    }

    /// Returns messages for a conversation.
    static func messages(for conversationId: String) -> [Message] {
        allMessages[conversationId] ?? []
    }

    /// Returns unread notification count.
    static var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }
}
