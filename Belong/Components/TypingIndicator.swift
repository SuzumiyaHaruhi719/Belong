import SwiftUI

struct TypingIndicator: View {
    let name: String
    @State private var animationPhase: Int = 0

    var body: some View {
        HStack(spacing: Spacing.sm) {
            TypingDots(phase: animationPhase)
            Text("\(name) is typing...")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                animationPhase = 1
            }
        }
    }
}

struct TypingDots: View {
    let phase: Int

    var body: some View {
        HStack(spacing: 3) {
            TypingDot(delay: 0.0, isAnimating: phase == 1)
            TypingDot(delay: 0.15, isAnimating: phase == 1)
            TypingDot(delay: 0.3, isAnimating: phase == 1)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(BelongColor.surface)
        .clipShape(Capsule())
    }
}

struct TypingDot: View {
    let delay: Double
    let isAnimating: Bool
    @State private var offsetY: CGFloat = 0

    var body: some View {
        Circle()
            .fill(BelongColor.textTertiary)
            .frame(width: 6, height: 6)
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offsetY = -4
                }
            }
    }
}

#Preview {
    VStack {
        TypingIndicator(name: "Min-Jun")
    }
    .padding()
    .background(BelongColor.background)
}
