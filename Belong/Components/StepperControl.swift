import SwiftUI

struct StepperControl: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...99
    var label: String? = nil

    var body: some View {
        HStack(spacing: Spacing.base) {
            if let label = label {
                Text(label)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                Spacer()
            }
            StepperControlButtons(value: $value, range: range)
        }
    }
}

struct StepperControlButtons: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 0) {
            StepperButton(
                icon: "minus",
                isDisabled: value <= range.lowerBound,
                action: { value = max(range.lowerBound, value - 1) },
                label: "Decrease"
            )

            Text("\(value)")
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.textPrimary)
                .frame(width: 44)
                .frame(height: Layout.touchTargetMin)

            StepperButton(
                icon: "plus",
                isDisabled: value >= range.upperBound,
                action: { value = min(range.upperBound, value + 1) },
                label: "Increase"
            )
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(BelongColor.border, lineWidth: 1)
        )
    }
}

struct StepperButton: View {
    let icon: String
    let isDisabled: Bool
    let action: () -> Void
    let label: String

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isDisabled ? BelongColor.disabled : BelongColor.primary)
                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
        }
        .disabled(isDisabled)
        .accessibilityLabel(label)
    }
}

#Preview {
    struct StepperPreview: View {
        @State private var count = 4
        var body: some View {
            VStack(spacing: Spacing.lg) {
                StepperControl(value: $count, range: 1...20, label: "Attendees")
                StepperControl(value: $count, range: 1...20)
            }
            .padding()
            .background(BelongColor.background)
        }
    }
    return StepperPreview()
}
