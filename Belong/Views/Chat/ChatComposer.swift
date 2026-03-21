import SwiftUI

// MARK: - Chat Composer
// Text input with send button for the group chat.
// UX Decisions:
// - Multi-line input (up to 4 lines) so users can write longer messages.
// - Send button is disabled + muted when empty — prevents accidental blank sends.
// - Send button uses SF Symbol arrow.up.circle.fill for iOS-native feel.
// - Input border subtly highlights on focus for clarity.

struct ChatComposer: View {
    @Bindable var viewModel: EventsViewModel
    @FocusState private var isInputFocused: Bool

    private var canSend: Bool {
        !viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BelongColor.divider)
                .frame(height: 1)

            HStack(alignment: .bottom, spacing: Spacing.sm) {
                TextField("Message...", text: $viewModel.newMessageText, axis: .vertical)
                    .lineLimit(1...4)
                    .font(BelongFont.body())
                    .focused($isInputFocused)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                    .overlay {
                        RoundedRectangle(cornerRadius: Layout.radiusLg)
                            .strokeBorder(
                                isInputFocused ? BelongColor.borderFocused : BelongColor.border,
                                lineWidth: isInputFocused ? 1.5 : 1
                            )
                    }
                    .accessibilityLabel("Message input")

                Button("Send message", systemImage: "arrow.up.circle.fill", action: handleSend)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? BelongColor.primary : BelongColor.disabled)
                    .disabled(!canSend)
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)
            .background(BelongColor.surface)
        }
    }

    private func handleSend() {
        viewModel.sendMessage()
    }
}
