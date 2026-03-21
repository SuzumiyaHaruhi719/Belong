import SwiftUI

// MARK: - BelongTextField
// Spec: 56pt height, 12pt radius, border changes on focus/error.
// UX Decision: Error messages appear inline below the field (never as alerts)
// to keep context visible. Character counter shown when limit is set.

struct BelongTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var errorMessage: String? = nil
    var helperText: String? = nil
    var characterLimit: Int? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var isSecure: Bool = false
    var isDisabled: Bool = false
    var autocapitalization: TextInputAutocapitalization = .sentences
    var leadingIcon: String? = nil

    @FocusState private var isFocused: Bool
    @State private var showSecureText = false

    private var hasError: Bool { errorMessage != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Label
            Text(label)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)

            // Input field
            HStack(spacing: Spacing.sm) {
                if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .foregroundStyle(BelongColor.textTertiary)
                        .frame(width: 20)
                }

                Group {
                    if isSecure && !showSecureText {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .textContentType(textContentType)
                            .textInputAutocapitalization(autocapitalization)
                    }
                }
                .font(BelongFont.body())
                .focused($isFocused)

                if isSecure {
                    Button {
                        showSecureText.toggle()
                    } label: {
                        Image(systemName: showSecureText ? "eye.slash" : "eye")
                            .foregroundStyle(BelongColor.textTertiary)
                            .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                    }
                    .accessibilityLabel(showSecureText ? "Hide password" : "Show password")
                }
            }
            .padding(.horizontal, Spacing.base)
            .frame(height: Layout.inputHeight)
            .background(isDisabled ? BelongColor.disabled.opacity(0.3) : BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
            .overlay {
                RoundedRectangle(cornerRadius: Layout.radiusMd)
                    .strokeBorder(borderColor, lineWidth: hasError ? 1.5 : 1)
            }
            .disabled(isDisabled)

            // Helper / error / character count row
            HStack {
                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.error)
                } else if let helperText {
                    Text(helperText)
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textTertiary)
                }

                Spacer()

                if let characterLimit {
                    Text("\(text.count) / \(characterLimit)")
                        .font(BelongFont.caption())
                        .foregroundStyle(text.count > characterLimit ? BelongColor.error : BelongColor.textTertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(text.isEmpty ? placeholder : text)
        .accessibilityHint(errorMessage ?? helperText ?? "")
    }

    private var borderColor: Color {
        if hasError { return BelongColor.error }
        if isFocused { return BelongColor.borderFocused }
        return BelongColor.border
    }
}

#Preview("Text Fields") {
    VStack(spacing: 24) {
        BelongTextField(label: "Email", text: .constant(""), placeholder: "you@example.com",
                        keyboardType: .emailAddress, leadingIcon: "envelope")
        BelongTextField(label: "Username", text: .constant("mai_nguyen"),
                        characterLimit: 20, autocapitalization: .never)
        BelongTextField(label: "Password", text: .constant("abc"),
                        errorMessage: "At least 8 characters", isSecure: true)
    }
    .padding()
    .background(BelongColor.background)
}
