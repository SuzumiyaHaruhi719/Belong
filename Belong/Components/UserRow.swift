import SwiftUI

struct UserRow: View {
    var avatarURL: URL? = nil
    var avatarEmoji: String = ""
    let name: String
    var subtitle: String? = nil
    var trailingActionTitle: String? = nil
    var onTrailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(imageURL: avatarURL, emoji: avatarEmoji, size: .medium)
                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)

            UserRowTextStack(name: name, subtitle: subtitle)

            Spacer()

            if let title = trailingActionTitle, let action = onTrailingAction {
                UserRowTrailingButton(title: title, action: action)
            }
        }
        .frame(height: 56)
        .padding(.horizontal, Layout.screenPadding)
    }
}

struct UserRowTextStack: View {
    let name: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.textPrimary)
                .lineLimit(1)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}

struct UserRowTrailingButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.primary)
                .padding(.horizontal, Spacing.md)
                .frame(height: 34)
                .background(BelongColor.surfaceSecondary)
                .clipShape(Capsule())
        }
        .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 0) {
        UserRow(avatarEmoji: "🧑‍🍳", name: "Min-Jun Park", subtitle: "@minjun", trailingActionTitle: "Follow", onTrailingAction: {})
        Divider()
        UserRow(avatarEmoji: "🎎", name: "Sakura Tanaka", subtitle: "@sakura", trailingActionTitle: "Following", onTrailingAction: {})
        Divider()
        UserRow(avatarEmoji: "🌸", name: "Wei Lin", subtitle: "@weilin", trailingActionTitle: "Message", onTrailingAction: {})
    }
    .background(BelongColor.surface)
}
