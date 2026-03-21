import SwiftUI

// MARK: - ChipView
// Spec: 36pt height, 18pt radius (capsule), selection states.
// UX Decision: Selected chips use Soft Peach (#FFF5EE) background with
// terracotta border — warm and non-clinical. Multi-select by default.

struct ChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(isSelected ? BelongColor.primary : BelongColor.textPrimary)
                .padding(.horizontal, Spacing.base)
                .frame(height: Layout.chipHeight)
                .background(isSelected ? BelongColor.surfaceSecondary : BelongColor.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(isSelected ? BelongColor.primary : BelongColor.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - ChipGroup
// Wrapping layout for a collection of chips using FlowLayout.

struct ChipGroup: View {
    let title: String
    let options: [String]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.textPrimary)

            FlowLayout(spacing: Spacing.sm) {
                ForEach(options, id: \.self) { option in
                    ChipView(
                        title: option,
                        isSelected: selected.contains(option)
                    ) {
                        if selected.contains(option) {
                            selected.removeAll { $0 == option }
                        } else {
                            selected.append(option)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - FlowLayout
// Horizontal wrapping layout — chips flow to next line when row is full.

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

#Preview("Chips") {
    struct ChipPreview: View {
        @State var selected: [String] = ["Vietnamese", "Cooking"]
        var body: some View {
            ChipGroup(
                title: "Cultural background",
                options: SampleData.culturalTagOptions.background,
                selected: $selected
            )
            .padding()
            .background(BelongColor.background)
        }
    }
    return ChipPreview()
}
