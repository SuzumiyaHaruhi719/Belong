import SwiftUI

struct TemplatePickerScreen: View {
    let viewModel: CreateGatheringViewModel
    @Binding var path: NavigationPath
    @State private var templates: [HostingTemplate] = []
    @State private var drafts: [Gathering] = []
    @State private var isLoading = true
    @State private var isLoadingDrafts = true

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.base),
        GridItem(.flexible(), spacing: Spacing.base),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // My Drafts section (shown only when drafts exist)
                if !drafts.isEmpty {
                    DraftPickerSection(
                        drafts: drafts,
                        onResume: { draft in
                            viewModel.loadDraft(draft)
                            // Find matching template to pass to customize screen
                            let template = templates.first { $0.id.contains(draft.templateType.rawValue) }
                                ?? templates.first
                            path.append(CreateRoute.customizeGathering(template ?? SampleData.hostingTemplates[0]))
                        },
                        onDelete: { draft in
                            Task { await deleteDraft(draft) }
                        }
                    )
                }

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
            async let templatesTask: () = loadTemplates()
            async let draftsTask: () = loadDrafts()
            _ = await (templatesTask, draftsTask)
        }
    }

    private func loadTemplates() async {
        isLoading = true
        do {
            templates = try await viewModel.container.gatheringService.fetchTemplates()
        } catch {
            templates = []
        }
        isLoading = false
    }

    private func loadDrafts() async {
        isLoadingDrafts = true
        do {
            drafts = try await viewModel.container.gatheringService.fetchDrafts()
        } catch {
            drafts = []
        }
        isLoadingDrafts = false
    }

    private func deleteDraft(_ draft: Gathering) async {
        do {
            try await viewModel.container.gatheringService.deleteDraft(gatheringId: draft.id)
            drafts.removeAll { $0.id == draft.id }
        } catch {
            // Silent failure — draft stays in list
        }
    }
}

// MARK: - Draft Picker Section

private struct DraftPickerSection: View {
    let drafts: [Gathering]
    let onResume: (Gathering) -> Void
    let onDelete: (Gathering) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(BelongColor.primary)
                Text("My Drafts")
                    .font(BelongFont.h3())
                    .foregroundStyle(BelongColor.textPrimary)
            }

            ForEach(drafts) { draft in
                DraftRow(draft: draft, onResume: onResume, onDelete: onDelete)
            }
        }
    }
}

private struct DraftRow: View {
    let draft: Gathering
    let onResume: (Gathering) -> Void
    let onDelete: (Gathering) -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(draft.title.isEmpty ? "Untitled draft" : draft.title)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(1)

                Text(draft.startsAt.formatted(date: .abbreviated, time: .shortened))
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }

            Spacer()

            Button {
                onDelete(draft)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .buttonStyle(.plain)

            Button {
                onResume(draft)
            } label: {
                Text("Resume")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textOnPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(BelongColor.primary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(BelongColor.primary.opacity(0.2), lineWidth: 1)
        )
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

    private static let templateIcons: [String: String] = [
        "template-food": "fork.knife.circle.fill",
        "template-study": "book.circle.fill",
        "template-hangout": "party.popper.fill",
        "template-cultural": "globe.americas.fill",
        "template-faith": "hands.and.sparkles.fill",
        "template-active": "figure.run.circle.fill",
    ]

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: Self.templateIcons[template.id] ?? "questionmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(BelongColor.primary)
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
