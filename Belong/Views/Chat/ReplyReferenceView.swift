import SwiftUI

// MARK: - Reply Reference View
// Shows the quoted message above a reply bubble.
// UX: A thin accent bar + truncated text makes it clear what's being replied to
// without taking too much space. Tappable to scroll to original (future feature).

struct ReplyReferenceView: View {
    let reply: ReplyReference
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(isCurrentUser ? BelongColor.textOnPrimary.opacity(0.5) : BelongColor.primary)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 1) {
                Text(reply.senderName)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(isCurrentUser ? BelongColor.textOnPrimary.opacity(0.8) : BelongColor.primary)

                Text(reply.previewText)
                    .font(BelongFont.caption())
                    .foregroundStyle(isCurrentUser ? BelongColor.textOnPrimary.opacity(0.6) : BelongColor.textTertiary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            isCurrentUser
            ? BelongColor.textOnPrimary.opacity(0.1)
            : BelongColor.surfaceSecondary
        )
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
        .accessibilityLabel("Replying to \(reply.senderName): \(reply.previewText)")
    }
}
