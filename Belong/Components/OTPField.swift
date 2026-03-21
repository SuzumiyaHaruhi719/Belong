import SwiftUI

// MARK: - OTPField
// Spec S03: 6-digit code input with individual cells (52×64pt each).
// UX Decision: Single hidden text field drives visual cells.
// Auto-advances and auto-submits when all 6 digits entered.
// Paste support: if user pastes 6 digits, it fills all cells.

struct OTPField: View {
    @Binding var code: String
    let digitCount: Int = 6
    var onComplete: ((String) -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Hidden text field that captures keyboard input
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .onChange(of: code) { _, newValue in
                    // Limit to digits only, max 6
                    let filtered = String(newValue.filter(\.isNumber).prefix(digitCount))
                    if filtered != newValue { code = filtered }
                    if filtered.count == digitCount { onComplete?(filtered) }
                }

            // Visual cells
            HStack(spacing: Spacing.sm) {
                ForEach(0..<digitCount, id: \.self) { index in
                    let digit = index < code.count
                        ? String(code[code.index(code.startIndex, offsetBy: index)])
                        : ""

                    Text(digit)
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundStyle(BelongColor.textPrimary)
                        .frame(width: 52, height: 64)
                        .background(BelongColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                        .overlay {
                            RoundedRectangle(cornerRadius: Layout.radiusMd)
                                .strokeBorder(
                                    index == code.count && isFocused
                                        ? BelongColor.borderFocused
                                        : BelongColor.border,
                                    lineWidth: index == code.count && isFocused ? 2 : 1
                                )
                        }
                }
            }
            .onTapGesture { isFocused = true }
        }
        .onAppear { isFocused = true }
        .accessibilityLabel("Verification code, \(code.count) of \(digitCount) digits entered")
    }
}

#Preview {
    struct Preview: View {
        @State var code = "123"
        var body: some View {
            OTPField(code: $code)
                .padding()
                .background(BelongColor.background)
        }
    }
    return Preview()
}
