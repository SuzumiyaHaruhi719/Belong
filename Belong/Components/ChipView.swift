import SwiftUI

struct ChipView: View {
    let title: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        if let action = action {
            Button(action: action) {
                ChipContent(title: title, isSelected: isSelected)
            }
            .buttonStyle(BelongPressStyle())
            .accessibilityLabel("\(title), \(isSelected ? "selected" : "not selected")")
        } else {
            ChipContent(title: title, isSelected: isSelected)
        }
    }
}

struct ChipContent: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(BelongFont.secondaryMedium())
            .foregroundStyle(isSelected ? BelongColor.tagChipText : BelongColor.textSecondary)
            .padding(.horizontal, Spacing.base)
            .frame(height: Layout.chipHeight)
            .background(isSelected ? BelongColor.tagChipBackground : BelongColor.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? BelongColor.tagChipBackground : BelongColor.border, lineWidth: 1)
            )
            .animation(BelongMotion.quick, value: isSelected)
    }
}

#Preview {
    HStack(spacing: Spacing.sm) {
        ChipView(title: "Korean", isSelected: true, action: {})
        ChipView(title: "Japanese", isSelected: false, action: {})
        ChipView(title: "Food", isSelected: false)
    }
    .padding()
    .background(BelongColor.background)
}
