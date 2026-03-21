import SwiftUI

// MARK: - BS02: Post-Event Feedback Sheet
// Spec: 5 emojis (64×64pt) with labels. Auto-transitions to BS03
// (Save Connections) after 800ms delay.
//
// UX Decision: Emoji feedback is low-stakes and fast. One tap = done.
// No star ratings, no text forms — just an emotional pulse check.
// The auto-transition to connections feels like a natural continuation
// rather than a separate task.

struct PostEventFeedbackSheet: View {
    let gathering: Gathering
    var onComplete: ((Int) -> Void)? = nil  // feedback value
    var onShowConnections: (() -> Void)? = nil

    @State private var selectedEmoji: FeedbackEmoji?
    @State private var hasSubmitted = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Drag handle
            Capsule()
                .fill(BelongColor.border)
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.sm)

            // Prompt
            Text("How was it?")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            // Event reference
            VStack(spacing: Spacing.xs) {
                Text(gathering.title)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                Text("Hosted by \(gathering.hostName)")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
            }

            Spacer()

            if hasSubmitted {
                // Thank you state
                VStack(spacing: Spacing.base) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(BelongColor.primary)

                    Text("Thanks for sharing!")
                        .font(BelongFont.h2())
                        .foregroundStyle(BelongColor.textPrimary)

                    Text("Your feedback helps us improve recommendations.")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                // Emoji row
                HStack(spacing: Spacing.lg) {
                    ForEach(FeedbackEmoji.options) { option in
                        Button {
                            selectFeedback(option)
                        } label: {
                            VStack(spacing: Spacing.xs) {
                                Text(option.emoji)
                                    .font(.system(size: 44))
                                    .scaleEffect(selectedEmoji?.id == option.id ? 1.2 : 1)

                                Text(option.label)
                                    .font(BelongFont.caption())
                                    .foregroundStyle(BelongColor.textSecondary)
                            }
                            .frame(width: 64)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(option.label)
                        .accessibilityAddTraits(.isButton)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, Layout.screenPadding)
        .background(BelongColor.background)
        .animation(.easeInOut(duration: 0.3), value: hasSubmitted)
    }

    private func selectFeedback(_ emoji: FeedbackEmoji) {
        selectedEmoji = emoji

        // Brief haptic + visual confirmation, then transition
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            withAnimation {
                hasSubmitted = true
            }
            onComplete?(emoji.value)

            // Auto-advance to connections sheet after a moment
            try? await Task.sleep(for: .seconds(1.5))
            onShowConnections?()
        }
    }
}

#Preview {
    PostEventFeedbackSheet(gathering: SampleData.pastGatherings.first ?? SampleData.topPick)
        .presentationDetents([.medium])
}
