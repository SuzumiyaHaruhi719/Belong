import SwiftUI

struct EditCulturalTagsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditProfileViewModel?
    @State private var backgroundPresets: [String] = []
    @State private var languagePresets: [String] = []
    @State private var interestPresets: [String] = []

    var body: some View {
        Group {
            if let vm = viewModel {
                EditCulturalTagsContent(
                    viewModel: vm,
                    backgroundPresets: backgroundPresets,
                    languagePresets: languagePresets,
                    interestPresets: interestPresets,
                    onDismiss: { dismiss() }
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Cultural Tags")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = EditProfileViewModel(userService: container.userService)
                viewModel = vm
                // Load existing tags first so they appear pre-selected
                await vm.loadExistingTags()
            }
            do {
                backgroundPresets = try await container.userService.fetchTagPresets(category: .culturalBackground)
                languagePresets = try await container.userService.fetchTagPresets(category: .language)
                interestPresets = try await container.userService.fetchTagPresets(category: .interestVibe)
            } catch {
                viewModel?.error = error.localizedDescription
            }
        }
    }
}

// MARK: - Content

private struct EditCulturalTagsContent: View {
    @Bindable var viewModel: EditProfileViewModel
    let backgroundPresets: [String]
    let languagePresets: [String]
    let interestPresets: [String]
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                if let error = viewModel.error {
                    InlineErrorBanner(message: error) {
                        viewModel.error = nil
                    }
                }

                TagSection(
                    title: "Cultural Background",
                    options: backgroundPresets,
                    selected: $viewModel.editingBackground
                )

                TagSection(
                    title: "Languages",
                    options: languagePresets,
                    selected: $viewModel.editingLanguages
                )

                TagSection(
                    title: "Interests & Vibes",
                    options: interestPresets,
                    selected: $viewModel.editingInterests
                )

                BelongButton(title: "Clear All", style: .tertiary) {
                    viewModel.editingBackground.removeAll()
                    viewModel.editingLanguages.removeAll()
                    viewModel.editingInterests.removeAll()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(Layout.screenPadding)
            .padding(.bottom, Spacing.xxxl)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        let success = await viewModel.saveTags()
                        if success { onDismiss() }
                    }
                }
                .font(BelongFont.bodySemiBold())
                .foregroundStyle(BelongColor.primary)
                .disabled(viewModel.isSaving)
            }
        }
    }
}

// MARK: - Tag Section

private struct TagSection: View {
    let title: String
    let options: [String]
    @Binding var selected: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            ChipGroup(options: options, selected: $selected)
        }
    }
}

#Preview {
    NavigationStack {
        EditCulturalTagsScreen()
    }
    .environment(DependencyContainer())
}
