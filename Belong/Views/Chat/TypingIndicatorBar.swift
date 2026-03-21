import SwiftUI

// MARK: - Typing Indicator Bar
// Shown above the composer when another user is typing.
// UX: Subtle animation and muted text — informative without being distracting.
// Disappears after a timeout if no message arrives.

struct TypingIndicatorBar: View {
    let isVisible: Bool
    let userName: String

    var body: some View {
        if isVisible {
            HStack(spacing: Spacing.sm) {
                TypingDots()
                Text("\(userName) is typing...")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
                Spacer()
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.xs)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .animation(.easeInOut(duration: 0.2), value: isVisible)
            .accessibilityLabel("\(userName) is typing")
        }
    }
}

// MARK: - Typing Dots Animation

struct TypingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(BelongColor.textTertiary)
                    .frame(width: 5, height: 5)
                    .offset(y: animating ? -3 : 0)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}
