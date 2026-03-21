import SwiftUI

protocol SegmentOption: Hashable {
    var displayTitle: String { get }
}

extension String: SegmentOption {
    var displayTitle: String { self }
}

struct SegmentedControl<T: SegmentOption>: View {
    let options: [T]
    @Binding var selected: T

    var body: some View {
        Picker("", selection: $selected) {
            ForEach(options, id: \.self) { option in
                Text(option.displayTitle)
                    .tag(option)
            }
        }
        .pickerStyle(.segmented)
        .tint(BelongColor.primary)
        .accessibilityLabel("Segment selector")
    }
}

#Preview {
    struct SegmentedPreview: View {
        @State private var selected = "For You"
        var body: some View {
            SegmentedControl(
                options: ["For You", "Following", "Nearby"],
                selected: $selected
            )
            .padding()
            .background(BelongColor.background)
        }
    }
    return SegmentedPreview()
}
