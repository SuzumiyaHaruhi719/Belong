import SwiftUI

struct PinnedMessageBanner: View {
    let senderName: String
    let messagePreview: String
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "pin.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(BelongColor.primary)
                    .rotationEffect(.degrees(45))

                VStack(alignment: .leading, spacing: 1) {
                    Text(senderName)
                        .font(BelongFont.captionMedium())
                        .foregroundStyle(BelongColor.textPrimary)
                    Text(messagePreview)
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.sm)
            .background(BelongColor.surfaceSecondary)
        }
        .accessibilityLabel("Pinned message from \(senderName)")
    }
}

#Preview {
    PinnedMessageBanner(
        senderName: "Min-Jun",
        messagePreview: "Meeting at 7pm at the Korean BBQ place on Sawtelle. Don't be late!",
        onTap: {}
    )
}
