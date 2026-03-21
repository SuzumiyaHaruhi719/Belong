import SwiftUI

// MARK: - Pinned Host Message Banner
// Stays visible at the top of chat for key announcements.
// UX: Pinned messages reduce repeated questions — host sets expectations once.

struct PinnedHostMessageBanner: View {
    let messages: [Message]

    private var pinned: Message? {
        messages.first { $0.isPinned }
    }

    var body: some View {
        if let pinned {
            VStack(spacing: 0) {
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
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Pinned message from \(pinned.senderName): \(pinned.text)")

                Rectangle()
                    .fill(BelongColor.divider)
                    .frame(height: 1)
            }
        }
    }
}
