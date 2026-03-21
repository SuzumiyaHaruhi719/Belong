import SwiftUI

/// Reusable drag handle indicator for bottom sheets.
struct SheetDragHandle: View {
    var body: some View {
        Capsule()
            .fill(BelongColor.border)
            .frame(width: 36, height: 5)
            .padding(.top, Spacing.sm)
            .accessibilityHidden(true)
    }
}

#Preview {
    SheetDragHandle()
        .padding()
        .background(BelongColor.background)
}
