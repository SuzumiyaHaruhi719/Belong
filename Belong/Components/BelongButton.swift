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
    var isCompact: Bool = false
    var leadingIcon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BelongButtonContent(
                title: title,
                style: style,
                isFullWidth: isFullWidth,
                isLoading: isLoading,
                isCompact: isCompact,
                leadingIcon: leadingIcon
            )
        }
        .buttonStyle(BelongPressStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1)
        .accessibilityLabel(title)
    }
}

// Press effect: scale down slightly + reduce opacity. Feels tactile.
struct BelongPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(BelongMotion.quick, value: configuration.isPressed)
    }
}

struct BelongButtonContent: View {
    let title: String
    let style: BelongButtonStyle
    let isFullWidth: Bool
    let isLoading: Bool
    let isCompact: Bool
    let leadingIcon: String?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                ProgressView()
                    .tint(foregroundColor)
            } else {
                if let icon = leadingIcon {
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                }
                Text(title)
                    .font(isCompact ? BelongFont.buttonSmall() : BelongFont.button())
            }
        }
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .frame(height: isCompact ? Layout.buttonHeightCompact : Layout.buttonHeight)
        .padding(.horizontal, Spacing.xl)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .overlay(borderOverlay)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .shadow(
            color: style == .primary ? BelongColor.primary.opacity(0.18) : .clear,
            radius: 8, x: 0, y: 4
        )
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
                .stroke(BelongColor.border, lineWidth: 1)
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
        BelongButton(title: "Compact", style: .secondary, isCompact: true, action: {})
    }
    .padding()
    .background(BelongColor.background)
}
