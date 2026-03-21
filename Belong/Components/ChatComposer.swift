import SwiftUI

struct ChatComposer: View {
    @Binding var text: String
    var onSend: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            ChatComposerTextField(text: $text, isFocused: $isFocused)
            ChatComposerSendButton(
                isEnabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                action: onSend
            )
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.sm)
        .background(BelongColor.surface)
    }
}

struct ChatComposerTextField: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        TextField("Message...", text: $text, axis: .vertical)
            .font(BelongFont.body())
            .foregroundStyle(BelongColor.textPrimary)
            .lineLimit(1...4)
            .focused(isFocused)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(BelongColor.surfaceAlt)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusXl))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusXl)
                    .stroke(isFocused.wrappedValue ? BelongColor.borderFocused : BelongColor.border, lineWidth: 1)
            )
            .accessibilityLabel("Message input")
    }
}

struct ChatComposerSendButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(isEnabled ? BelongColor.primary : BelongColor.disabled)
        }
        .disabled(!isEnabled)
        .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
        .accessibilityLabel("Send message")
    }
}

#Preview {
    struct ChatComposerPreview: View {
        @State private var text = ""
        var body: some View {
            VStack {
                Spacer()
                ChatComposer(text: $text, onSend: {})
            }
            .background(BelongColor.background)
        }
    }
    return ChatComposerPreview()
}
