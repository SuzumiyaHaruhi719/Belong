import SwiftUI

struct TemplatePickerScreen: View {
    let viewModel: CreateGatheringViewModel
    @Binding var path: NavigationPath
    @State private var templates: [HostingTemplate] = []
    @State private var isLoading = true

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.base),
        GridItem(.flexible(), spacing: Spacing.base),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                TemplatePickerHeader()

                if isLoading {
                    TemplatePickerSkeleton(columns: columns)
                } else {
                    LazyVGrid(columns: columns, spacing: Spacing.base) {
                        ForEach(templates) { template in
                            TemplatePickerCard(template: template) {
                                viewModel.selectTemplate(template)
                                path.append(CreateRoute.customizeGathering(template))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.base)
        }
        .background(BelongColor.background)
        .task {
            await loadTemplates()
        }
    }

    private func loadTemplates() async {
        isLoading = true
        do {
            templates = try await viewModel.container.gatheringService.fetchTemplates()
        } catch {
            // Fallback to empty on failure
            templates = []
        }
        isLoading = false
    }
}

// MARK: - Header

private struct TemplatePickerHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Pick a template")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
            Text("We'll pre-fill the details for you")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

// MARK: - Template Card

struct TemplatePickerCard: View {
    let template: HostingTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Text(template.emoji)
                    .font(.system(size: 48))
                    .frame(height: 56)

                Text(template.title)
                    .font(BelongFont.h3())
                    .foregroundStyle(BelongColor.textPrimary)

                Text(template.description)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
            .shadow(
                color: BelongShadow.level1.color,
                radius: BelongShadow.level1.radius,
                x: BelongShadow.level1.x,
                y: BelongShadow.level1.y
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(template.title) template")
    }
}

// MARK: - Skeleton

private struct TemplatePickerSkeleton: View {
    let columns: [GridItem]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.base) {
            ForEach(0..<6, id: \.self) { _ in
                SkeletonView(height: 180, cornerRadius: Layout.radiusLg)
            }
        }
    }
}

#Preview {
    struct TemplatePickerPreview: View {
        @State private var path = NavigationPath()

        var body: some View {
            NavigationStack {
                TemplatePickerScreen(
                    viewModel: CreateGatheringViewModel(container: DependencyContainer()),
                    path: $path
                )
            }
        }
    }
    return TemplatePickerPreview()
}
