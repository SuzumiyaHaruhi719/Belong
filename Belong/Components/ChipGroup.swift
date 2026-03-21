import SwiftUI

struct ChipGroup: View {
    let options: [String]
    @Binding var selected: Set<String>
    var spacing: CGFloat = Spacing.sm

    var body: some View {
        FlowLayout(spacing: spacing, data: options) { option in
            ChipView(
                title: option,
                isSelected: selected.contains(option),
                action: { toggle(option) }
            )
        }
    }

    private func toggle(_ option: String) {
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
    }
}

#Preview {
    struct ChipGroupPreview: View {
        @State private var selected: Set<String> = ["Korean"]

        var body: some View {
            ChipGroup(
                options: ["Korean", "Japanese", "Chinese", "Vietnamese", "Thai", "Indian", "Filipino"],
                selected: $selected
            )
            .padding()
            .background(BelongColor.background)
        }
    }
    return ChipGroupPreview()
}
