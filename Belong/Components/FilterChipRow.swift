import SwiftUI

struct FilterChipRow: View {
    let filters: [String]
    @Binding var selected: String

    private var allFilters: [String] {
        ["All"] + filters
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(allFilters, id: \.self) { filter in
                    ChipView(
                        title: filter,
                        isSelected: filter == selected,
                        action: { selected = filter }
                    )
                }
            }
            .padding(.horizontal, Layout.screenPadding)
        }
    }
}

#Preview {
    struct FilterChipRowPreview: View {
        @State private var selected = "All"
        var body: some View {
            FilterChipRow(
                filters: ["Food", "Study", "Cultural", "Active", "Faith"],
                selected: $selected
            )
            .background(BelongColor.background)
        }
    }
    return FilterChipRowPreview()
}
