import SwiftUI

struct OTPField: View {
    @Binding var code: String
    var digitCount: Int = 6
    var onComplete: ((String) -> Void)? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            HiddenOTPTextField(
                code: $code,
                digitCount: digitCount,
                isFocused: $isFocused,
                onComplete: onComplete
            )
            OTPCellRow(
                code: code,
                digitCount: digitCount,
                isFocused: isFocused,
                onTap: { isFocused = true }
            )
        }
    }
}

struct HiddenOTPTextField: View {
    @Binding var code: String
    let digitCount: Int
    var isFocused: FocusState<Bool>.Binding
    var onComplete: ((String) -> Void)?

    var body: some View {
        TextField("", text: $code)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused(isFocused)
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .onChange(of: code) { _, newValue in
                let filtered = String(newValue.prefix(digitCount).filter(\.isNumber))
                if filtered != newValue {
                    code = filtered
                }
                if filtered.count == digitCount {
                    onComplete?(filtered)
                }
            }
            .accessibilityLabel("Enter verification code")
    }
}

struct OTPCellRow: View {
    let code: String
    let digitCount: Int
    let isFocused: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<digitCount, id: \.self) { index in
                OTPCell(
                    character: character(at: index),
                    isActive: isFocused && index == code.count
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private func character(at index: Int) -> String {
        guard index < code.count else { return "" }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}

struct OTPCell: View {
    let character: String
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .fill(BelongColor.surface)
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(isActive ? BelongColor.borderFocused : BelongColor.border, lineWidth: isActive ? 2 : 1)
            Text(character)
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
        }
        .frame(width: 52, height: 64)
    }
}

#Preview {
    struct OTPPreview: View {
        @State private var code = "123"
        var body: some View {
            OTPField(code: $code, onComplete: { _ in })
                .padding()
                .background(BelongColor.background)
        }
    }
    return OTPPreview()
}
