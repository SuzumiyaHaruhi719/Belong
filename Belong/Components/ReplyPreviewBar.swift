import SwiftUI

struct ReplyPreviewBar: View {
    let senderName: String
    let messagePreview: String
    var onCancel: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(BelongColor.primary)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 1) {
                Text(senderName)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.primary)
                Text(messagePreview)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(BelongColor.textTertiary)
                    .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
            }
            .accessibilityLabel("Cancel reply")
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.xs)
        .background(BelongColor.surface)
    }
}

#Preview {
    ReplyPreviewBar(
        senderName: "Min-Jun",
        messagePreview: "Are you coming to the Korean BBQ tonight? We have 3 spots left.",
        onCancel: {}
    )
}
