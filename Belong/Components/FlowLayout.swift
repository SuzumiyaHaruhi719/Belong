import SwiftUI

// MARK: - FlowLayout
// A wrapping layout that places items in rows, breaking to the next row
// when items would exceed the available width.
//
// Uses a two-pass approach: first measures all children to compute row
// breaks and total height, then positions them. This avoids the
// GeometryReader zero-height bug that caused overlap inside ScrollView.

struct FlowLayout: SwiftUI.Layout {
    var spacing: CGFloat

    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: LayoutSubviews,
        cache: inout ()
    ) -> CGSize {
        computeLayout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: LayoutSubviews,
        cache: inout ()
    ) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(subviews[index].sizeThatFits(.unspecified))
            )
        }
    }

    private struct LayoutResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func computeLayout(
        proposal: ProposedViewSize,
        subviews: LayoutSubviews
    ) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // Wrap to next row if this item exceeds available width
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            totalWidth = max(totalWidth, currentX + size.width)
            currentX += size.width + spacing
        }

        let totalHeight = currentY + rowHeight
        return LayoutResult(
            positions: positions,
            size: CGSize(width: totalWidth, height: totalHeight)
        )
    }
}

#Preview {
    let tags = ["Korean", "Food", "Study Group", "Cultural", "Music", "Language Exchange", "Photography", "Hiking"]
    FlowLayout(spacing: 8) {
        ForEach(tags, id: \.self) { tag in
            ChipView(title: tag, isSelected: tag == "Korean")
        }
    }
    .padding()
    .background(BelongColor.background)
}
