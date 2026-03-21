import SwiftUI

struct LocationSuggestion: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
}

struct LocationSearchField: View {
    let label: String
    @Binding var text: String
    @Binding var suggestions: [LocationSuggestion]
    var onSelect: ((LocationSuggestion) -> Void)? = nil
    var onSearchChanged: ((String) -> Void)? = nil
    @State private var showSuggestions: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LocationSearchFieldInput(
                label: label,
                text: $text,
                isFocused: $isFocused,
                onTextChange: { newValue in
                    showSuggestions = !newValue.isEmpty
                    onSearchChanged?(newValue)
                }
            )
            if showSuggestions && !suggestions.isEmpty {
                LocationSuggestionsList(
                    suggestions: suggestions,
                    onSelect: { suggestion in
                        text = suggestion.name
                        showSuggestions = false
                        isFocused = false
                        onSelect?(suggestion)
                    }
                )
            }
        }
    }
}

struct LocationSearchFieldInput: View {
    let label: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    var onTextChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            HStack(spacing: Spacing.sm) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(BelongColor.textTertiary)
                    .font(.system(size: 16))
                TextField("Search for a location...", text: $text)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
                    .focused(isFocused)
                    .onChange(of: text) { _, newValue in
                        onTextChange(newValue)
                    }
                    .accessibilityLabel("Location search input")
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: Layout.inputHeight)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMd)
                    .stroke(isFocused.wrappedValue ? BelongColor.borderFocused : BelongColor.border, lineWidth: 1)
            )
        }
    }
}

struct LocationSuggestionsList: View {
    let suggestions: [LocationSuggestion]
    let onSelect: (LocationSuggestion) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions) { suggestion in
                LocationSuggestionRow(suggestion: suggestion, onSelect: { onSelect(suggestion) })
                if suggestion.id != suggestions.last?.id {
                    Divider().padding(.leading, Spacing.xxxl)
                }
            }
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(BelongColor.border, lineWidth: 1)
        )
        .shadow(
            color: BelongShadow.level1.color,
            radius: BelongShadow.level1.radius,
            x: BelongShadow.level1.x,
            y: BelongShadow.level1.y
        )
    }
}

struct LocationSuggestionRow: View {
    let suggestion: LocationSuggestion
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(BelongColor.primary)
                    .font(.system(size: 20))
                VStack(alignment: .leading, spacing: 1) {
                    Text(suggestion.name)
                        .font(BelongFont.secondaryMedium())
                        .foregroundStyle(BelongColor.textPrimary)
                    Text(suggestion.address)
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .frame(minHeight: Layout.touchTargetMin)
        }
        .accessibilityLabel("\(suggestion.name), \(suggestion.address)")
    }
}

#Preview {
    struct LocationSearchPreview: View {
        @State private var text = "Korean"
        @State private var suggestions: [LocationSuggestion] = [
            LocationSuggestion(id: "1", name: "Kang Ho-dong Baekjeong", address: "3465 W 6th St, Los Angeles, CA"),
            LocationSuggestion(id: "2", name: "Korean BBQ House", address: "1234 Sawtelle Blvd, Los Angeles, CA"),
            LocationSuggestion(id: "3", name: "Korea Town Plaza", address: "928 S Western Ave, Los Angeles, CA")
        ]
        var body: some View {
            LocationSearchField(
                label: "Location",
                text: $text,
                suggestions: $suggestions
            )
            .padding()
            .background(BelongColor.background)
        }
    }
    return LocationSearchPreview()
}
