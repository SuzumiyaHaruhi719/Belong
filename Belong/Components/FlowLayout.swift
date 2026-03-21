import SwiftUI

struct FlowLayout: View {
    let spacing: CGFloat
    let content: [AnyView]

    init<Data: RandomAccessCollection, Content: View>(
        spacing: CGFloat = 8,
        data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) where Data.Element: Hashable {
        self.spacing = spacing
        self.content = data.map { AnyView(content($0)) }
    }

    var body: some View {
        GeometryReader { geometry in
            FlowLayoutContent(
                maxWidth: geometry.size.width,
                spacing: spacing,
                items: content
            )
        }
        .frame(height: nil)
    }
}

struct FlowLayoutContent: View {
    let maxWidth: CGFloat
    let spacing: CGFloat
    let items: [AnyView]

    @State private var totalHeight: CGFloat = 0

    var body: some View {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                item
                    .alignmentGuide(.leading) { dimension in
                        if abs(currentX - (-dimension.width)) > maxWidth {
                            currentX = 0
                            currentY += rowHeight + spacing
                            rowHeight = 0
                        }
                        let result = currentX
                        rowHeight = max(rowHeight, dimension.height)
                        if index == items.count - 1 {
                            currentX = 0
                        } else {
                            currentX -= (dimension.width + spacing)
                        }
                        return -result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = currentY
                        if index == items.count - 1 {
                            currentY = 0
                        }
                        return -result
                    }
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: FlowHeightKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(FlowHeightKey.self) { totalHeight = $0 }
        .frame(height: totalHeight)
    }
}

private struct FlowHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    let tags = ["Korean", "Food", "Study Group", "Cultural", "Music", "Language Exchange"]
    return FlowLayout(spacing: 8, data: tags) { tag in
        ChipView(title: tag, isSelected: tag == "Korean")
    }
    .padding()
    .background(BelongColor.background)
}
