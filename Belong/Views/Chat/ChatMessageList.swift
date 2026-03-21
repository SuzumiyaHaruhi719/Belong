import SwiftUI

// MARK: - Chat Message List
// Scrollable message feed with date separators, system messages,
// and per-message context menus for reactions and replies.
//
// UX: defaultScrollAnchor(.bottom) keeps newest messages visible.
// Date separators help users orient in long conversations.

struct ChatMessageList: View {
    @Bindable var viewModel: EventsViewModel

    private var visibleMessages: [Message] {
        viewModel.messages.filter { !$0.isPinned }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(Array(visibleMessages.enumerated()), id: \.element.id) { index, message in
                    VStack(spacing: Spacing.sm) {
                        // Date separator when day changes
                        if shouldShowDateSeparator(at: index) {
                            DateSeparator(date: message.timestamp)
                        }

                        // System messages get a distinct centered style
                        if message.messageType == .system {
                            SystemMessageRow(message: message)
                        } else {
                            MessageBubble(message: message, viewModel: viewModel)
                        }
                    }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.md)
        }
        .defaultScrollAnchor(.bottom)
    }

    private func shouldShowDateSeparator(at index: Int) -> Bool {
        guard index > 0 else { return true }
        let current = visibleMessages[index].timestamp
        let previous = visibleMessages[index - 1].timestamp
        return !Calendar.current.isDate(current, inSameDayAs: previous)
    }
}

// MARK: - Date Separator

struct DateSeparator: View {
    let date: Date

    var body: some View {
        HStack {
            line
            Text(formatted)
                .font(BelongFont.captionMedium())
                .foregroundStyle(BelongColor.textTertiary)
                .padding(.horizontal, Spacing.sm)
            line
        }
        .padding(.vertical, Spacing.sm)
        .accessibilityLabel(formatted)
    }

    private var line: some View {
        Rectangle()
            .fill(BelongColor.divider)
            .frame(height: 1)
    }

    private var formatted: String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}

// MARK: - System Message Row

struct SystemMessageRow: View {
    let message: Message

    var body: some View {
        Text(message.text)
            .font(BelongFont.caption())
            .foregroundStyle(BelongColor.textTertiary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(BelongColor.divider.opacity(0.5))
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
            .accessibilityLabel("System: \(message.text)")
    }
}
