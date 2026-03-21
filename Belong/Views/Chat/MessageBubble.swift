import SwiftUI

// MARK: - MessageBubble
// Individual chat message with avatar, text, reactions, reply reference,
// delivery status, and long-press context menu.
//
// UX Decisions:
// - Own messages: right-aligned, terracotta background, white text.
// - Others' messages: left-aligned with avatar, light background, dark text.
// - Reactions shown below the bubble as small chips — tappable to toggle.
// - Reply reference shown above the bubble with a connecting bar.
// - Failed messages show a red retry button — explicit, not hidden.
// - Context menu on long-press: Reply, React, Copy — the three actions
//   users actually need. No destructive options in group context.

struct MessageBubble: View {
    let message: Message
    @Bindable var viewModel: EventsViewModel

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            if message.isCurrentUser {
                Spacer(minLength: 60)
                currentUserLayout
            } else {
                otherUserLayout
                Spacer(minLength: 60)
            }
        }
        .contextMenu {
            Button("Reply", systemImage: "arrowshape.turn.up.left") {
                viewModel.beginReply(to: message)
            }

            Menu("React") {
                ForEach(EventsViewModel.quickReactions, id: \.self) { emoji in
                    Button(emoji) {
                        viewModel.toggleReaction(emoji, on: message)
                    }
                }
            }

            Button("Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = message.text
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Current User (Right)

    private var currentUserLayout: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Reply reference
            if let reply = message.replyTo {
                ReplyReferenceView(reply: reply, isCurrentUser: true)
            }

            // Bubble
            Text(message.text)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textOnPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(BelongColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))

            // Reactions
            if !message.reactions.isEmpty {
                ReactionsRow(reactions: message.reactions) { emoji in
                    viewModel.toggleReaction(emoji, on: message)
                }
            }

            // Timestamp + Status
            HStack(spacing: Spacing.xs) {
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)

                MessageStatusIcon(status: message.status)
            }

            // Retry for failed
            if message.status == .failed {
                Button("Retry", systemImage: "arrow.clockwise") {
                    viewModel.retryMessage(message)
                }
                .font(BelongFont.captionMedium())
                .foregroundStyle(BelongColor.error)
            }
        }
    }

    // MARK: - Other User (Left)

    private var otherUserLayout: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            AvatarView(emoji: message.senderAvatarEmoji, size: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(message.senderName)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textSecondary)

                // Reply reference
                if let reply = message.replyTo {
                    ReplyReferenceView(reply: reply, isCurrentUser: false)
                }

                // Bubble
                Text(message.text)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))

                // Reactions
                if !message.reactions.isEmpty {
                    ReactionsRow(reactions: message.reactions) { emoji in
                        viewModel.toggleReaction(emoji, on: message)
                    }
                }

                // Timestamp
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }
        }
    }

    private var accessibilityDescription: String {
        var parts = [message.senderName, message.text]
        if !message.reactions.isEmpty {
            let reactionText = message.reactions.map { "\($0.emoji) \($0.count)" }.joined(separator: ", ")
            parts.append("Reactions: \(reactionText)")
        }
        return parts.joined(separator: ". ")
    }
}
