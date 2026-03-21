import SwiftUI

// MARK: - EditCulturalTagsScreen (S24)
// Edit version of the cultural tags picker from onboarding (S10).
// UX Decision: Pre-populated selections make it clear what's already chosen,
// and "Clear all" provides a quick reset without tedious one-by-one removal.

struct EditCulturalTagsScreen: View {
    @Bindable var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                ChipGroup(
                    title: "Cultural background",
                    options: SampleData.culturalTagOptions.background,
                    selected: $viewModel.editingBackground
                )

                ChipGroup(
                    title: "Languages",
                    options: SampleData.culturalTagOptions.languages,
                    selected: $viewModel.editingLanguages
                )

                ChipGroup(
                    title: "Interests",
                    options: SampleData.culturalTagOptions.interests,
                    selected: $viewModel.editingInterests
                )

                BelongButton(
                    title: "Clear all",
                    style: .tertiary
                ) {
                    viewModel.clearAllTags()
                }
                .accessibilityLabel("Clear all selected tags")
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(BelongColor.background)
        .navigationTitle("Edit Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.saveTags()
                    dismiss()
                } label: {
                    Text("Save")
                        .font(BelongFont.bodySemiBold())
                        .foregroundStyle(
                            viewModel.hasTagChanges
                                ? BelongColor.primary
                                : BelongColor.disabledText
                        )
                }
                .disabled(!viewModel.hasTagChanges)
                .accessibilityLabel("Save tag changes")
                .accessibilityHint(viewModel.hasTagChanges ? "Saves your changes" : "No changes to save")
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditCulturalTagsScreen(viewModel: {
            let vm = ProfileViewModel()
            vm.beginEditingTags()
            return vm
        }())
    }
}
