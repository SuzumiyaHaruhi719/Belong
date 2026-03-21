import SwiftUI

// MARK: - BelongButton
// Spec: 56pt height, 16pt radius, 4 variants.
// UX Decision: Loading state disables tap and replaces label with spinner
// to prevent duplicate submissions. Always full-width unless compact is set.

enum BelongButtonStyle {
    case primary      // Terracotta fill, white text
    case secondary    // White fill, terracotta border & text
    case tertiary     // No fill, no border, terracotta text
    case destructive  // Red text, no fill
}

struct BelongButton: View {
    let title: String
    let style: BelongButtonStyle
    var systemImage: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var isFullWidth: Bool = true
    let action: () -> Void

    private var isInteractive: Bool { !isLoading && !isDisabled }

    var body: some View {
        Button(action: {
            guard isInteractive else { return }
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(textColor)
                } else {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(BelongFont.button())
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: Layout.buttonHeight)
            .foregroundStyle(isDisabled ? BelongColor.disabledText : textColor)
            .background(isDisabled ? BelongColor.disabled : backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
            .overlay {
                if style == .secondary && !isDisabled {
                    RoundedRectangle(cornerRadius: Layout.radiusLg)
                        .strokeBorder(BelongColor.primary, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(isLoading ? 0.8 : 1)
        .allowsHitTesting(isInteractive)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityRemoveTraits(isInteractive ? [] : .isButton)
        .accessibilityHint(isLoading ? "Loading" : isDisabled ? "Disabled" : "")
    }

    private var textColor: Color {
        switch style {
        case .primary: return BelongColor.textOnPrimary
        case .secondary: return BelongColor.primary
        case .tertiary: return BelongColor.primary
        case .destructive: return BelongColor.error
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return BelongColor.primary
        case .secondary: return BelongColor.surface
        case .tertiary: return .clear
        case .destructive: return .clear
        }
    }
}

#Preview("Button Variants") {
    VStack(spacing: 16) {
        BelongButton(title: "Continue", style: .primary) {}
        BelongButton(title: "Maybe Later", style: .secondary) {}
        BelongButton(title: "Skip for now", style: .tertiary) {}
        BelongButton(title: "Delete Account", style: .destructive) {}
        BelongButton(title: "Loading...", style: .primary, isLoading: true) {}
        BelongButton(title: "Disabled", style: .primary, isDisabled: true) {}
    }
    .padding()
    .background(BelongColor.background)
}
