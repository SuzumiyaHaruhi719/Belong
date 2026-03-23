import SwiftUI

struct NotificationRow: View {
    let notification: AppNotification
    var onTap: (() -> Void)? = nil

    var body: some View {
        if let onTap {
            Button(action: { onTap() }) {
                notificationRowBody
            }
            .accessibilityLabel(notification.message)
        } else {
            notificationRowBody
                .accessibilityLabel(notification.message)
        }
    }

    private var notificationRowBody: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            NotificationRowAvatar(emoji: notification.actorAvatarEmoji)
            NotificationRowContent(notification: notification)
            Spacer()
            NotificationRowTrailing(
                thumbnailURL: notification.thumbnailURL,
                createdAt: notification.createdAt
            )
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.md)
        .background(notification.isRead ? Color.clear : BelongColor.surfaceSecondary)
    }
}

struct NotificationRowAvatar: View {
    let emoji: String?

    var body: some View {
        AvatarView(emoji: emoji ?? "?", size: .medium)
            .frame(width: 36, height: 36)
    }
}

struct NotificationRowContent: View {
    let notification: AppNotification

    var body: some View {
        if let actorName = notification.actorName {
            NotificationAttributedText(actorName: actorName, message: notification.message)
        } else {
            Text(notification.message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textPrimary)
                .multilineTextAlignment(.leading)
        }
    }
}

struct NotificationAttributedText: View {
    let actorName: String
    let message: String

    var body: some View {
        Text(attributedMessage)
            .font(BelongFont.secondary())
            .multilineTextAlignment(.leading)
    }

    private var attributedMessage: AttributedString {
        var result = AttributedString(message)
        if let range = result.range(of: actorName) {
            result[range].font = BelongFont.secondaryMedium()
            result[range].foregroundColor = BelongColor.textPrimary
        }
        return result
    }
}

struct NotificationRowTrailing: View {
    let thumbnailURL: URL?
    let createdAt: Date

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.xs) {
            if let url = thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        BelongColor.skeleton
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
            }
            Text(timeAgo)
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
    }

    private var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        if interval < 604800 { return "\(Int(interval / 86400))d" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: createdAt)
    }
}

#Preview {
    let notifications: [AppNotification] = [
        AppNotification(
            id: "1", recipientId: "me", actorId: "u1",
            type: .like, targetType: "post", targetId: "p1",
            message: "Min-Jun liked your post about Korean BBQ",
            isRead: false, createdAt: Date().addingTimeInterval(-300),
            actorName: "Min-Jun", actorAvatarEmoji: "🧑‍🍳"
        ),
        AppNotification(
            id: "2", recipientId: "me", actorId: "u2",
            type: .follow, targetType: "user", targetId: "me",
            message: "Sakura started following you",
            isRead: true, createdAt: Date().addingTimeInterval(-3600),
            actorName: "Sakura", actorAvatarEmoji: "🎎"
        ),
        AppNotification(
            id: "3", recipientId: "me", actorId: "u3",
            type: .gatheringReminder, targetType: "gathering", targetId: "g1",
            message: "Reminder: Lunar New Year Celebration starts in 1 hour",
            isRead: false, createdAt: Date().addingTimeInterval(-1800),
            actorName: nil, actorAvatarEmoji: nil
        )
    ]
    return VStack(spacing: 0) {
        ForEach(notifications) { notification in
            NotificationRow(notification: notification, onTap: {})
            Divider()
        }
    }
    .background(BelongColor.surface)
}
