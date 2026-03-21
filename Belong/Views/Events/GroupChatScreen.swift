import SwiftUI

// MARK: - GroupChatScreen (S16)
// Group chat for a gathering with pinned host message, message bubbles, and composer.
// UX Decision: Current user messages are right-aligned with primary-color bubbles.
// Pinned host message stays visible at top for key announcements.

struct GroupChatScreen: View {
    let gathering: Gathering
    @Bindable var viewModel: EventsViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Pinned host message
            pinnedMessage

            // Messages
            messageList

            // Composer
            composer
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

    // MARK: - Pinned Host Message

    @ViewBuilder
    private var pinnedMessage: some View {
        if let pinned = viewModel.messages.first(where: { $0.isPinned }) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(BelongColor.primary)
                    .rotationEffect(.degrees(45))

                VStack(alignment: .leading, spacing: 2) {
                    Text(pinned.senderName)
                        .font(BelongFont.captionMedium())
                        .foregroundStyle(BelongColor.textPrimary)
                    Text(pinned.text)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(Spacing.md)
            .background(BelongColor.surfaceSecondary)

            Rectangle()
                .fill(BelongColor.divider)
                .frame(height: 1)
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.base) {
                ForEach(viewModel.messages.filter { !$0.isPinned }) { message in
                    MessageBubble(message: message)
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.md)
        }
        .defaultScrollAnchor(.bottom)
    }

    // MARK: - Composer

    private var composer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BelongColor.divider)
                .frame(height: 1)

            HStack(alignment: .bottom, spacing: Spacing.sm) {
                TextField("Message...", text: $viewModel.newMessageText, axis: .vertical)
                    .lineLimit(1...4)
                    .font(BelongFont.body())
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                    .overlay {
                        RoundedRectangle(cornerRadius: Layout.radiusLg)
                            .strokeBorder(BelongColor.border, lineWidth: 1)
                    }

                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? BelongColor.disabled
                            : BelongColor.primary
                        )
                }
                .disabled(viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send message")
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)
            .background(BelongColor.surface)
        }
    }
}

// MARK: - MessageBubble

private struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            if message.isCurrentUser {
                Spacer(minLength: 60)
                currentUserBubble
            } else {
                otherUserBubble
                Spacer(minLength: 60)
            }
        }
    }

    private var currentUserBubble: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(message.text)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textOnPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(BelongColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))

            Text(message.timestamp.formatted(.dateTime.hour().minute()))
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
    }

    private var otherUserBubble: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            AvatarView(emoji: message.senderAvatarEmoji, size: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(message.senderName)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textSecondary)

                Text(message.text)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))

                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
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
