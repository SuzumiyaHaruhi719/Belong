import SwiftUI

// MARK: - ProgressBarView
// Spec S02–S05: 4-segment progress bar for onboarding account creation.
// UX Decision: Segmented (not continuous) to show distinct steps.
// Completed segments fill with primary color; upcoming are border-only.

struct ProgressBarView: View {
    let totalSteps: Int
    let currentStep: Int  // 1-based

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? BelongColor.primary : BelongColor.border)
                    .frame(height: 4)
            }
        }
        .accessibilityLabel("Step \(currentStep) of \(totalSteps)")
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressBarView(totalSteps: 4, currentStep: 1)
        ProgressBarView(totalSteps: 4, currentStep: 2)
        ProgressBarView(totalSteps: 4, currentStep: 3)
        ProgressBarView(totalSteps: 4, currentStep: 4)
    }
    .padding()
    .background(BelongColor.background)
}
