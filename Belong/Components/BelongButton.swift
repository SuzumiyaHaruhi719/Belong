import SwiftUI

enum BelongButtonStyle {
    case primary, secondary, tertiary, destructive
}

struct BelongButton: View {
    let title: String
    let style: BelongButtonStyle
    var isFullWidth: Bool = false
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var leadingIcon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BelongButtonContent(
                title: title,
                style: style,
                isFullWidth: isFullWidth,
                isLoading: isLoading,
                leadingIcon: leadingIcon
            )
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }
}

struct BelongButtonContent: View {
    let title: String
    let style: BelongButtonStyle
    let isFullWidth: Bool
    let isLoading: Bool
    let leadingIcon: String?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                ProgressView()
                    .tint(foregroundColor)
            } else {
                if let icon = leadingIcon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(BelongFont.button())
            }
        }
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .frame(height: Layout.buttonHeight)
        .padding(.horizontal, Spacing.xl)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .overlay(borderOverlay)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: BelongColor.textOnPrimary
        case .secondary: BelongColor.primary
        case .tertiary: BelongColor.primary
        case .destructive: BelongColor.textOnPrimary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: BelongColor.primary
        case .secondary: BelongColor.surface
        case .tertiary: Color.clear
        case .destructive: BelongColor.error
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if style == .secondary {
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(BelongColor.primary, lineWidth: 1.5)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.base) {
        BelongButton(title: "Primary", style: .primary, isFullWidth: true, action: {})
        BelongButton(title: "Secondary", style: .secondary, isFullWidth: true, action: {})
        BelongButton(title: "Tertiary", style: .tertiary, action: {})
        BelongButton(title: "Destructive", style: .destructive, isFullWidth: true, action: {})
        BelongButton(title: "Loading", style: .primary, isFullWidth: true, isLoading: true, action: {})
        BelongButton(title: "Disabled", style: .primary, isFullWidth: true, isDisabled: true, action: {})
        BelongButton(title: "With Icon", style: .primary, leadingIcon: "plus", action: {})
    }
    .padding()
    .background(BelongColor.background)
}
