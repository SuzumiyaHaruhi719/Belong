import SwiftUI

struct PostEventFeedbackSheet: View {
    let gatheringTitle: String
    let hostName: String
    var onSubmit: ((FeedbackEmoji) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmoji: FeedbackEmoji? = nil
    @State private var showThanks = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            SheetDragHandle()

            Text("How was it?")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            PostFeedbackEventInfo(title: gatheringTitle, hostName: hostName)

            PostFeedbackEmojiRow(
                selectedEmoji: $selectedEmoji,
                showThanks: $showThanks,
                onSubmit: onSubmit,
                dismiss: dismiss
            )

            Spacer()

            if showThanks {
                Text("Thanks!")
                    .font(BelongFont.h3())
                    .foregroundStyle(BelongColor.success)
                    .transition(.opacity.combined(with: .scale))
            }

            Button(action: { dismiss() }) {
                Text("Skip")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .accessibilityLabel("Skip feedback")
            .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.md)
        .background(BelongColor.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Event Info

private struct PostFeedbackEventInfo: View {
    let title: String
    let hostName: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(title)
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.textPrimary)
            Text("Hosted by \(hostName)")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

// MARK: - Emoji Row

private struct PostFeedbackEmojiRow: View {
    @Binding var selectedEmoji: FeedbackEmoji?
    @Binding var showThanks: Bool
    var onSubmit: ((FeedbackEmoji) -> Void)?
    let dismiss: DismissAction

    var body: some View {
        HStack(spacing: Spacing.md) {
            ForEach(FeedbackEmoji.options) { option in
                PostFeedbackEmojiButton(
                    option: option,
                    isSelected: selectedEmoji?.id == option.id,
                    isDisabled: selectedEmoji != nil && selectedEmoji?.id != option.id
                ) {
                    selectEmoji(option)
                }
            }
        }
        .padding(.vertical, Spacing.md)
    }

    private func selectEmoji(_ option: FeedbackEmoji) {
        guard selectedEmoji == nil else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            selectedEmoji = option
        }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        onSubmit?(option)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                showThanks = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            dismiss()
        }
    }
}

private struct PostFeedbackEmojiButton: View {
    let option: FeedbackEmoji
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(option.emoji)
                    .font(.system(size: 64))
                    .scaleEffect(isSelected ? 1.2 : 1.0)

                Text(option.label)
                    .font(BelongFont.caption())
                    .foregroundStyle(
                        isSelected ? BelongColor.primary : BelongColor.textSecondary
                    )
            }
        }
        .buttonStyle(.plain)
        .opacity(isDisabled ? 0.4 : 1.0)
        .disabled(isDisabled)
        .accessibilityLabel("\(option.label), rate \(option.score) out of 5")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            PostEventFeedbackSheet(
                gatheringTitle: "Korean BBQ Night",
                hostName: "Min-Jun Park"
            )
        }
}
