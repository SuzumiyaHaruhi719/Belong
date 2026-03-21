import SwiftUI
import Combine

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onDebouncedChange: ((String) -> Void)? = nil
    @FocusState private var isFocused: Bool
    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(BelongColor.textTertiary)
                .font(.system(size: 16))

            TextField(placeholder, text: $text)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    debounceTask?.cancel()
                    debounceTask = Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        if !Task.isCancelled {
                            onDebouncedChange?(newValue)
                        }
                    }
                }
                .accessibilityLabel("Search input")

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onDebouncedChange?("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(BelongColor.textTertiary)
                        .font(.system(size: 16))
                        .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: Layout.touchTargetMin)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(isFocused ? BelongColor.borderFocused : BelongColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    struct SearchBarPreview: View {
        @State private var text = ""
        var body: some View {
            SearchBar(text: $text, placeholder: "Search gatherings...")
                .padding()
                .background(BelongColor.background)
        }
    }
    return SearchBarPreview()
}
