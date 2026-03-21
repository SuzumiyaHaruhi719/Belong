import SwiftUI

// MARK: - GroupChatScreen (S16)
// Rich group chat for a gathering with pinned messages, reactions, replies,
// typing indicator, date separators, and message context actions.
//
// UX Decisions:
// - Current user messages right-aligned with primary-color bubbles for clear ownership.
// - Pinned host message stays visible for key announcements (meeting point, dietary info).
// - Long-press reveals quick reactions — low friction, no modal needed.
// - Reply context shown inline so threaded conversations are easy to follow.
// - Typing indicator gives social presence cues — event feels alive.
// - System messages (join/leave/reminders) use muted centered style to avoid clutter.
// - Scroll-to-bottom FAB appears when user has scrolled up, with unread badge.
// - Failed messages show inline retry — never silently swallow send failures.

struct GroupChatScreen: View {
    let gathering: Gathering
    @Bindable var viewModel: EventsViewModel

    var body: some View {
        VStack(spacing: 0) {
            PinnedHostMessageBanner(messages: viewModel.messages)

            ChatMessageList(viewModel: viewModel)

            TypingIndicatorBar(
                isVisible: viewModel.isOtherUserTyping,
                userName: viewModel.typingUserName
            )

            ReplyPreviewBar(
                replyingTo: viewModel.replyingTo,
                onCancel: viewModel.cancelReply
            )

            ChatComposer(viewModel: viewModel)
        }
        .background(BelongColor.background)
        .navigationTitle(gathering.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(gathering.attendeeCount) attending")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
            }
        }
    }
}

#Preview("Group Chat") {
    NavigationStack {
        GroupChatScreen(
            gathering: SampleData.topPick,
            viewModel: {
                let vm = EventsViewModel()
                vm.allGatherings = SampleData.gatherings
                vm.messages = SampleData.messages
                vm.isLoading = false
                return vm
            }()
        )
    }
}
