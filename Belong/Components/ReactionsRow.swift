import SwiftUI

struct ReactionsRow: View {
    let reactions: [MessageReaction]
    var onToggle: ((String) -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(reactions, id: \.emoji) { reaction in
                ReactionPill(reaction: reaction, onToggle: onToggle)
            }
        }
    }
}

struct ReactionPill: View {
    let reaction: MessageReaction
    var onToggle: ((String) -> Void)?

    var body: some View {
        Button(action: { onToggle?(reaction.emoji) }) {
            HStack(spacing: Spacing.xs) {
                Text(reaction.emoji)
                    .font(.system(size: 14))
                Text("\(reaction.count)")
                    .font(BelongFont.caption())
                    .foregroundStyle(reaction.hasReacted ? BelongColor.primary : BelongColor.textSecondary)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(reaction.hasReacted ? BelongColor.surfaceSecondary : BelongColor.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(reaction.hasReacted ? BelongColor.primary : BelongColor.border, lineWidth: 1)
            )
        }
        .frame(minHeight: Layout.touchTargetMin)
        .accessibilityLabel("\(reaction.emoji) reaction, \(reaction.count)")
    }
}

#Preview {
    ReactionsRow(
        reactions: [
            MessageReaction(emoji: "👍", count: 3, hasReacted: true),
            MessageReaction(emoji: "❤️", count: 1, hasReacted: false),
            MessageReaction(emoji: "😂", count: 5, hasReacted: true)
        ],
        onToggle: { _ in }
    )
    .padding()
    .background(BelongColor.background)
}
