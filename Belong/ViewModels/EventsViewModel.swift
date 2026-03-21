import SwiftUI

// MARK: - EventsViewModel
// Drives My Events (S14) with three segments: Upcoming, Past, Saved.
// Also handles Group Chat (S16) state including reactions, replies, and typing.

@Observable
final class EventsViewModel {
    enum Segment: String, CaseIterable {
        case upcoming = "Upcoming"
        case past = "Past"
        case saved = "Saved"
    }

    var selectedSegment: Segment = .upcoming
    var allGatherings: [Gathering] = []
    var isLoading = true

    // MARK: - Chat State
    var messages: [Message] = []
    var newMessageText = ""
    var isSendingMessage = false
    var replyingTo: Message? = nil  // Active reply context
    var showReactionPicker = false
    var reactionTargetMessage: Message? = nil
    var isOtherUserTyping = false
    var typingUserName: String = ""
    var hasNewMessagesBelow = false
    var chatError: String? = nil

    // Quick reaction options shown on long-press
    static let quickReactions = ["👍", "❤️", "😂", "🎉", "🤔", "👏"]

    // Feedback
    var showFeedbackSheet = false
    var feedbackGathering: Gathering?
    var showConnectionsSheet = false

    var displayedGatherings: [Gathering] {
        switch selectedSegment {
        case .upcoming: return allGatherings.filter { $0.status == .upcoming }
        case .past: return allGatherings.filter { $0.status == .past }
        case .saved: return allGatherings.filter { $0.isBookmarked }
        }
    }

    var emptyStateConfig: (image: String, title: String, message: String) {
        switch selectedSegment {
        case .upcoming:
            return ("calendar.badge.plus", "No upcoming events", "Join a gathering from the Home tab to see it here")
        case .past:
            return ("clock.arrow.circlepath", "No past events", "Events you've attended will appear here")
        case .saved:
            return ("bookmark", "No saved events", "Bookmark gatherings you're interested in")
        }
    }

    func load() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(0.8))
        allGatherings = SampleData.gatherings
        messages = SampleData.messages
        isLoading = false
    }

    // MARK: - Send Message

    func sendMessage() {
        let text = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let replyRef: ReplyReference? = if let replyingTo {
            ReplyReference(
                messageId: replyingTo.id,
                senderName: replyingTo.senderName,
                previewText: String(replyingTo.text.prefix(60))
            )
        } else {
            nil
        }

        let message = Message(
            id: UUID().uuidString,
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            text: text,
            timestamp: Date(),
            isCurrentUser: true,
            isPinned: false,
            replyTo: replyRef,
            status: .sending
        )
        messages.append(message)
        newMessageText = ""
        replyingTo = nil

        // Simulate send completion
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].status = .delivered
            }
            // Simulate typing indicator from another user
            try? await Task.sleep(for: .seconds(1.5))
            simulateTypingIndicator()
        }
    }

    // MARK: - Reply

    func beginReply(to message: Message) {
        replyingTo = message
    }

    func cancelReply() {
        replyingTo = nil
    }

    // MARK: - Reactions

    func toggleReaction(_ emoji: String, on message: Message) {
        guard let msgIndex = messages.firstIndex(where: { $0.id == message.id }) else { return }

        if let reactionIndex = messages[msgIndex].reactions.firstIndex(where: { $0.emoji == emoji }) {
            // Toggle existing reaction
            if messages[msgIndex].reactions[reactionIndex].hasReacted {
                messages[msgIndex].reactions[reactionIndex].count -= 1
                messages[msgIndex].reactions[reactionIndex].hasReacted = false
                if messages[msgIndex].reactions[reactionIndex].count <= 0 {
                    messages[msgIndex].reactions.remove(at: reactionIndex)
                }
            } else {
                messages[msgIndex].reactions[reactionIndex].count += 1
                messages[msgIndex].reactions[reactionIndex].hasReacted = true
            }
        } else {
            // Add new reaction
            messages[msgIndex].reactions.append(
                MessageReaction(emoji: emoji, count: 1, hasReacted: true)
            )
        }
        showReactionPicker = false
        reactionTargetMessage = nil
    }

    // MARK: - Retry Failed

    func retryMessage(_ message: Message) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[index].status = .sending
        Task {
            try? await Task.sleep(for: .seconds(1))
            messages[index].status = .delivered
        }
    }

    // MARK: - Typing Indicator (simulated)

    private func simulateTypingIndicator() {
        isOtherUserTyping = true
        typingUserName = "Linh"
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            isOtherUserTyping = false
            typingUserName = ""
        }
    }

    // MARK: - Bookmark

    func toggleBookmark(for gathering: Gathering) {
        guard let index = allGatherings.firstIndex(where: { $0.id == gathering.id }) else { return }
        allGatherings[index].isBookmarked.toggle()
    }
}
