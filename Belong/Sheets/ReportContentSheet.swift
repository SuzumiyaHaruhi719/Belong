import SwiftUI

struct ReportContentSheet: View {
    var onSubmit: ((ReportReason, String) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: ReportReason? = nil
    @State private var additionalDetails: String = ""
    @State private var isSubmitted = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            SheetDragHandle()

            ReportContentHeader()

            ReportReasonList(selectedReason: $selectedReason)

            ReportDetailsField(text: $additionalDetails)

            Spacer()

            if isSubmitted {
                SuccessBanner(message: "Report submitted")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            BelongButton(
                title: "Submit Report",
                style: .primary,
                isFullWidth: true,
                isDisabled: selectedReason == nil
            ) {
                submitReport()
            }
            .accessibilityLabel("Submit report")
            .accessibilityHint(selectedReason == nil ? "Select a reason first" : "Double tap to submit")
            .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.md)
        .background(BelongColor.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    private func submitReport() {
        guard let reason = selectedReason else { return }
        onSubmit?(reason, additionalDetails)

        withAnimation(.easeIn(duration: 0.3)) {
            isSubmitted = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

// MARK: - Report Reason

enum ReportReason: String, CaseIterable, Identifiable {
    case spam = "Spam"
    case harassment = "Harassment"
    case inappropriate = "Inappropriate content"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .spam: "exclamationmark.bubble"
        case .harassment: "hand.raised"
        case .inappropriate: "eye.slash"
        case .other: "ellipsis.circle"
        }
    }
}

// MARK: - Header

private struct ReportContentHeader: View {
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("Report")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Text("Why are you reporting this?")
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Reason List

private struct ReportReasonList: View {
    @Binding var selectedReason: ReportReason?

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(ReportReason.allCases) { reason in
                ReportReasonRow(
                    reason: reason,
                    isSelected: selectedReason == reason
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedReason = reason
                    }
                }
            }
        }
    }
}

private struct ReportReasonRow: View {
    let reason: ReportReason
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Image(systemName: reason.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? BelongColor.primary : BelongColor.textSecondary)
                    .frame(width: 24)

                Text(reason.rawValue)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(BelongColor.primary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Spacing.md)
            .frame(minHeight: Layout.touchTargetMin)
            .background(
                isSelected ? BelongColor.surfaceSecondary : BelongColor.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMd)
                    .stroke(
                        isSelected ? BelongColor.primary : BelongColor.border,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(reason.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Details Field

private struct ReportDetailsField: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            TextField("Tell us more (optional)", text: $text, axis: .vertical)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
                .lineLimit(3...5)
                .padding(Spacing.md)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusMd)
                        .stroke(BelongColor.border, lineWidth: 1)
                )
                .accessibilityLabel("Additional details, optional")
        }
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ReportContentSheet()
        }
}
