import SwiftUI

struct ProgressBarView: View {
    let totalSegments: Int
    let filledSegments: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<totalSegments, id: \.self) { index in
                ProgressBarSegment(isFilled: index < filledSegments)
            }
        }
        .frame(height: 4)
        .accessibilityLabel("Progress: step \(filledSegments) of \(totalSegments)")
    }
}

struct ProgressBarSegment: View {
    let isFilled: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isFilled ? BelongColor.primary : BelongColor.divider)
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        ProgressBarView(totalSegments: 4, filledSegments: 1)
        ProgressBarView(totalSegments: 4, filledSegments: 2)
        ProgressBarView(totalSegments: 4, filledSegments: 3)
        ProgressBarView(totalSegments: 4, filledSegments: 4)
    }
    .padding()
    .background(BelongColor.background)
}
