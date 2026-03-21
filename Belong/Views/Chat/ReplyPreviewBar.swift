import SwiftUI

// MARK: - Reply Preview Bar
// Shown above the composer when user is replying to a message.
// UX: Clear visual connection to what's being replied to.
// X button lets users cancel without disrupting their draft text.

struct ReplyPreviewBar: View {
    let replyingTo: Message?
    let onCancel: () -> Void

    var body: some View {
        if let message = replyingTo {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(BelongColor.divider)
                    .frame(height: 1)

                HStack(spacing: Spacing.sm) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BelongColor.primary)
                        .frame(width: 3, height: 32)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Replying to \(message.senderName)")
                            .font(BelongFont.captionMedium())
                            .foregroundStyle(BelongColor.primary)
                        Text(message.text)
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.textTertiary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button("Cancel reply", systemImage: "xmark.circle.fill", action: onCancel)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 20))
                        .foregroundStyle(BelongColor.textTertiary)
                        .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.vertical, Spacing.sm)
                .background(BelongColor.surface)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.2), value: replyingTo?.id)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Replying to \(message.senderName). \(message.text)")
        }
    }
}
