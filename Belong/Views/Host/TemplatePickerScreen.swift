import SwiftUI

// MARK: - TemplatePickerScreen (S19)
// Entry point for hosting flow. Users pick a template or start from scratch.
// UX Decision: 2-column grid gives visual weight to each template type,
// making the choice feel intentional rather than a dropdown afterthought.

struct TemplatePickerScreen: View {
    @State private var viewModel = HostViewModel()
    @State private var navigateToCustomize = false
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.base),
        GridItem(.flexible(), spacing: Spacing.base)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Header text
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("What kind of gathering?")
                            .font(BelongFont.h1())
                            .foregroundStyle(BelongColor.textPrimary)

                        Text("Pick a template to get started, or create from scratch.")
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textSecondary)
                    }

                    // Template grid
                    LazyVGrid(columns: columns, spacing: Spacing.base) {
                        ForEach(SampleData.hostingTemplates) { template in
                            TemplateCard(template: template) {
                                viewModel.selectTemplate(template)
                                navigateToCustomize = true
                            }
                        }
                    }

                    // Start from scratch
                    BelongButton(
                        title: "Start from scratch",
                        style: .tertiary
                    ) {
                        navigateToCustomize = true
                    }
                    .accessibilityLabel("Start from scratch without a template")
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
            }
            .background(BelongColor.background)
            .navigationTitle("Host a gathering")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(BelongColor.textPrimary)
                            .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
            .navigationDestination(isPresented: $navigateToCustomize) {
                CustomizeFormScreen(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Template Card

private struct TemplateCard: View {
    let template: HostingTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.md) {
                Image(systemName: template.systemImage)
                    .font(.system(size: 48))
                    .foregroundStyle(BelongColor.primary)
                    .frame(height: 60)

                Text(template.title)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text(template.description)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(Spacing.base)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 180)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusXl))
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
            .overlay {
                RoundedRectangle(cornerRadius: Layout.radiusXl)
                    .strokeBorder(BelongColor.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(template.title): \(template.description)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    TemplatePickerScreen()
}
