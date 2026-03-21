import SwiftUI

// MARK: - Reactions Row
// Horizontal row of emoji reactions below a message bubble.
// UX: Each reaction is tappable to toggle the current user's reaction.
// Highlighted state (blue border) shows which reactions the user has added.
// Count is always visible so you can see community engagement at a glance.

struct ReactionsRow: View {
    let reactions: [MessageReaction]
    let onToggle: (String) -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(reactions, id: \.emoji) { reaction in
                Button {
                    onToggle(reaction.emoji)
                } label: {
                    HStack(spacing: 2) {
                        Text(reaction.emoji)
                            .font(.system(size: 14))
                        Text("\(reaction.count)")
                            .font(BelongFont.caption())
                            .foregroundStyle(reaction.hasReacted ? BelongColor.primary : BelongColor.textTertiary)
                    }
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 3)
                    .background(reaction.hasReacted ? BelongColor.surfaceSecondary : BelongColor.surface)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule().strokeBorder(
                            reaction.hasReacted ? BelongColor.primary : BelongColor.border,
                            lineWidth: 1
                        )
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(reaction.emoji) \(reaction.count) reactions\(reaction.hasReacted ? ", you reacted" : "")")
            }
        }
    }
}
