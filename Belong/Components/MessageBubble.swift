import SwiftUI

struct MessageBubble: View {
    let message: Message

    var body: some View {
        switch message.messageType {
        case .system:
            MessageBubbleSystem(content: message.content ?? "")
        default:
            if message.isCurrentUser {
                MessageBubbleOutgoing(message: message)
            } else {
                MessageBubbleIncoming(message: message)
            }
        }
    }
}

// MARK: - System Message

struct MessageBubbleSystem: View {
    let content: String

    var body: some View {
        Text(content)
            .font(BelongFont.caption())
            .foregroundStyle(BelongColor.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Outgoing (Current User)

struct MessageBubbleOutgoing: View {
    let message: Message

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.xs) {
            if let reply = message.replyTo {
                MessageReplyReference(senderName: reply.senderName, preview: reply.previewText, isOutgoing: true)
            }

            MessageBubbleOutgoingContent(message: message)

            if !message.reactions.isEmpty {
                ReactionsRow(reactions: message.reactions, onToggle: { _ in })
            }

            MessageTimestamp(date: message.createdAt, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.leading, 60)
    }
}

struct MessageBubbleOutgoingContent: View {
    let message: Message

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.sm) {
            if let preview = message.sharedPostPreview {
                SharedPostMiniCard(preview: preview)
            }
            if let content = message.content, !content.isEmpty {
                Text(content)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textOnPrimary)
            }
        }
        .padding(Spacing.md)
        .background(BelongColor.primary)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: Layout.radiusLg,
                bottomLeadingRadius: Layout.radiusLg,
                bottomTrailingRadius: Spacing.xs,
                topTrailingRadius: Layout.radiusLg
            )
        )
    }
}

// MARK: - Incoming (Other User)

struct MessageBubbleIncoming: View {
    let message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            AvatarView(emoji: message.senderAvatarEmoji, size: .small)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(message.senderName)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textSecondary)

                if let reply = message.replyTo {
                    MessageReplyReference(senderName: reply.senderName, preview: reply.previewText, isOutgoing: false)
                }

                MessageBubbleIncomingContent(message: message)

                if !message.reactions.isEmpty {
                    ReactionsRow(reactions: message.reactions, onToggle: { _ in })
                }

                MessageTimestamp(date: message.createdAt, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 60)
    }
}

struct MessageBubbleIncomingContent: View {
    let message: Message

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let preview = message.sharedPostPreview {
                SharedPostMiniCard(preview: preview)
            }
            if let content = message.content, !content.isEmpty {
                Text(content)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
            }
        }
        .padding(Spacing.md)
        .background(BelongColor.surface)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: Layout.radiusLg,
                bottomLeadingRadius: Spacing.xs,
                bottomTrailingRadius: Layout.radiusLg,
                topTrailingRadius: Layout.radiusLg
            )
        )
    }
}

// MARK: - Shared Post Mini Card

struct SharedPostMiniCard: View {
    let preview: SharedPostPreview

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let url = preview.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        BelongColor.skeleton
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(preview.title)
                    .font(BelongFont.captionMedium())
                    .lineLimit(1)
                Text(preview.authorName)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
            }
        }
        .padding(Spacing.sm)
        .background(BelongColor.surfaceSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
    }
}

// MARK: - Reply Reference

struct MessageReplyReference: View {
    let senderName: String
    let preview: String
    let isOutgoing: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(isOutgoing ? BelongColor.textOnPrimary.opacity(0.5) : BelongColor.primary)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 1) {
                Text(senderName)
                    .font(BelongFont.captionMedium())
                Text(preview)
                    .font(BelongFont.caption())
                    .lineLimit(1)
            }
            .foregroundStyle(isOutgoing ? BelongColor.textOnPrimary.opacity(0.8) : BelongColor.textSecondary)
        }
        .frame(height: 32)
    }
}

// MARK: - Timestamp

struct MessageTimestamp: View {
    let date: Date
    let alignment: HorizontalAlignment

    var body: some View {
        Text(formatted)
            .font(BelongFont.caption())
            .foregroundStyle(BelongColor.textTertiary)
    }

    private var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    let incoming = Message(
        id: "1", conversationId: "c1", senderId: "u2",
        content: "Are you coming to the Korean BBQ tonight?",
        messageType: .text, reactions: [MessageReaction(emoji: "👍", count: 2, hasReacted: true)],
        replyTo: nil, status: .read, createdAt: Date(),
        senderName: "Min-Jun", senderAvatarEmoji: "🧑‍🍳",
        isCurrentUser: false
    )
    let outgoing = Message(
        id: "2", conversationId: "c1", senderId: "u1",
        content: "Yes! Can't wait 🔥",
        messageType: .text, reactions: [],
        replyTo: ReplyReference(messageId: "1", senderName: "Min-Jun", previewText: "Are you coming to the Korean BBQ tonight?"),
        status: .delivered, createdAt: Date(),
        senderName: "Me", senderAvatarEmoji: "🎎",
        isCurrentUser: true
    )
    let system = Message(
        id: "3", conversationId: "c1", senderId: "system",
        content: "Min-Jun created this group",
        messageType: .system, reactions: [], replyTo: nil,
        status: .read, createdAt: Date(),
        senderName: "System", senderAvatarEmoji: "",
        isCurrentUser: false
    )
    return ScrollView {
        VStack(spacing: Spacing.sm) {
            MessageBubble(message: system)
            MessageBubble(message: incoming)
            MessageBubble(message: outgoing)
        }
        .padding()
    }
    .background(BelongColor.background)
}
