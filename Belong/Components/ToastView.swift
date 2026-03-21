import SwiftUI

enum ToastVariant {
    case success, error
}

struct ToastView: View {
    let message: String
    let variant: ToastVariant
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            ToastContent(message: message, variant: variant)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }
                }
        }
    }
}

struct ToastContent: View {
    let message: String
    let variant: ToastVariant

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
            Text(message)
                .font(BelongFont.secondaryMedium())
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .padding(.horizontal, Layout.screenPadding)
    }

    private var icon: String {
        switch variant {
        case .success: "checkmark.circle.fill"
        case .error: "exclamationmark.circle.fill"
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .success: BelongColor.success
        case .error: BelongColor.error
        }
    }
}

#Preview {
    struct ToastPreview: View {
        @State private var showSuccess = true
        @State private var showError = true
        var body: some View {
            VStack(spacing: Spacing.lg) {
                ToastView(message: "Gathering created successfully!", variant: .success, isPresented: $showSuccess)
                ToastView(message: "Failed to save changes.", variant: .error, isPresented: $showError)
            }
            .padding(.top, Spacing.xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(BelongColor.background)
        }
    }
    return ToastPreview()
}
