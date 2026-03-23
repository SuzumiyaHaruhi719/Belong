import SwiftUI
import Supabase
import Realtime

// MARK: - Banner Data Model

struct InAppBanner: Identifiable, Equatable {
    let id = UUID()
    let senderName: String
    let senderAvatarURL: URL?
    let senderAvatarEmoji: String
    let messagePreview: String
    let conversationId: String
    let senderId: String
    let conversation: Conversation?
    let timestamp: Date

    static func == (lhs: InAppBanner, rhs: InAppBanner) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Banner Manager

@Observable @MainActor
final class InAppBannerManager {
    var currentBanner: InAppBanner?
    var isVisible = false

    /// Conversation the user is currently viewing (set by ChatDetailScreen)
    var activeConversationId: String?

    private var dismissTask: Task<Void, Never>?
    private var pendingBanners: [InAppBanner] = []
    private let autoDismissDelay: TimeInterval = 4.0

    func show(_ banner: InAppBanner) {
        // Don't show banner if user is already in that conversation
        if banner.conversationId == activeConversationId {
            return
        }

        // If a banner is currently showing from the same sender in same conversation,
        // update it rather than queuing
        if let current = currentBanner,
           current.conversationId == banner.conversationId,
           current.senderId == banner.senderId {
            dismissTask?.cancel()
            currentBanner = banner
            scheduleAutoDismiss()
            return
        }

        // If a banner is already showing, queue this one
        if isVisible {
            // Keep queue small — only last 3
            if pendingBanners.count >= 3 {
                pendingBanners.removeFirst()
            }
            pendingBanners.append(banner)
            return
        }

        // Show immediately
        presentBanner(banner)
    }

    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.spring(duration: 0.3)) {
            isVisible = false
        }
        // After animation, clear and show next
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            currentBanner = nil
            showNextIfAvailable()
        }
    }

    func dismissAll() {
        dismissTask?.cancel()
        pendingBanners.removeAll()
        withAnimation(.spring(duration: 0.3)) {
            isVisible = false
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            currentBanner = nil
        }
    }

    private func presentBanner(_ banner: InAppBanner) {
        currentBanner = banner
        withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
            isVisible = true
        }
        scheduleAutoDismiss()
    }

    private func scheduleAutoDismiss() {
        dismissTask?.cancel()
        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(autoDismissDelay))
            guard !Task.isCancelled else { return }
            dismiss()
        }
    }

    private func showNextIfAvailable() {
        guard !pendingBanners.isEmpty else { return }
        let next = pendingBanners.removeFirst()
        // Skip if user entered that conversation while queued
        if next.conversationId == activeConversationId {
            showNextIfAvailable()
            return
        }
        presentBanner(next)
    }
}
