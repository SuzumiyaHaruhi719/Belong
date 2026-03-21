import SwiftUI

// MARK: - EventsViewModel
// Drives My Events (S14) with three segments: Upcoming, Past, Saved.
// Also handles Group Chat (S16) state.

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

    // Chat
    var messages: [Message] = []
    var newMessageText = ""
    var isSendingMessage = false

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

    func sendMessage() {
        let text = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let message = Message(
            id: UUID().uuidString,
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            text: text,
            timestamp: Date(),
            isCurrentUser: true,
            isPinned: false
        )
        messages.append(message)
        newMessageText = ""
    }

    func toggleBookmark(for gathering: Gathering) {
        guard let index = allGatherings.firstIndex(where: { $0.id == gathering.id }) else { return }
        allGatherings[index].isBookmarked.toggle()
    }
}
