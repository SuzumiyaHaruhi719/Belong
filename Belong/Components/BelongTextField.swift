import SwiftUI

struct BelongTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var helperText: String? = nil
    var errorMessage: String? = nil
    var characterLimit: Int? = nil
    var leadingIcon: String? = nil
    var isSecure: Bool = false
    @State private var isFocused: Bool = false
    @State private var showSecureText: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            BelongTextFieldLabel(label: label)
            BelongTextFieldInputRow(
                text: $text,
                placeholder: placeholder,
                leadingIcon: leadingIcon,
                isSecure: isSecure,
                showSecureText: showSecureText,
                isFocused: isFocused,
                hasError: errorMessage != nil,
                onFocusChange: { isFocused = $0 },
                onToggleSecure: { showSecureText.toggle() }
            )
            BelongTextFieldFooter(
                helperText: helperText,
                errorMessage: errorMessage,
                characterLimit: characterLimit,
                currentCount: text.count
            )
        }
    }
}

struct BelongTextFieldLabel: View {
    let label: String

    var body: some View {
        Text(label)
            .font(BelongFont.secondaryMedium())
            .foregroundStyle(BelongColor.textSecondary)
    }
}

struct BelongTextFieldInputRow: View {
    @Binding var text: String
    let placeholder: String
    let leadingIcon: String?
    let isSecure: Bool
    let showSecureText: Bool
    let isFocused: Bool
    let hasError: Bool
    let onFocusChange: (Bool) -> Void
    let onToggleSecure: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = leadingIcon {
                Image(systemName: icon)
                    .foregroundStyle(BelongColor.textTertiary)
                    .frame(width: 20)
            }
            Group {
                if isSecure && !showSecureText {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text, onEditingChanged: onFocusChange)
                }
            }
            .font(BelongFont.body())
            .foregroundStyle(BelongColor.textPrimary)

            if isSecure {
                Button(action: onToggleSecure) {
                    Image(systemName: showSecureText ? "eye.slash" : "eye")
                        .foregroundStyle(BelongColor.textTertiary)
                }
                .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
                .accessibilityLabel(showSecureText ? "Hide password" : "Show password")
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: Layout.inputHeight)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(borderColor, lineWidth: hasError ? 1.5 : 1)
        )
    }

    private var borderColor: Color {
        if hasError { return BelongColor.error }
        if isFocused { return BelongColor.borderFocused }
        return BelongColor.border
    }
}

struct BelongTextFieldFooter: View {
    let helperText: String?
    let errorMessage: String?
    let characterLimit: Int?
    let currentCount: Int

    var body: some View {
        HStack {
            if let error = errorMessage {
                Text(error)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.error)
            } else if let helper = helperText {
                Text(helper)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }
            Spacer()
            if let limit = characterLimit {
                Text("\(currentCount)/\(limit)")
                    .font(BelongFont.caption())
                    .foregroundStyle(currentCount > limit ? BelongColor.error : BelongColor.textTertiary)
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        BelongTextField(label: "Email", text: .constant(""), placeholder: "you@example.com", leadingIcon: "envelope")
        BelongTextField(label: "Password", text: .constant("secret"), isSecure: true)
        BelongTextField(label: "Bio", text: .constant("Hello world"), helperText: "Tell us about yourself", characterLimit: 150)
        BelongTextField(label: "Username", text: .constant("bad!"), errorMessage: "Invalid characters")
    }
    .padding()
    .background(BelongColor.background)
}
