import SwiftUI

// MARK: - CulturalTagsScreen (S10)
// Cultural identity tag selection with three ChipGroup sections.
// Skippable — users can proceed without selecting any tags.

struct CulturalTagsScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // Header
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("What connects you?")
                                .font(BelongFont.h1())
                                .foregroundStyle(BelongColor.textPrimary)
                                .accessibilityAddTraits(.isHeader)

                            Text("Choose tags that reflect your identity. You can always change these later.")
                                .font(BelongFont.body())
                                .foregroundStyle(BelongColor.textSecondary)
                        }
                        .padding(.top, Spacing.sm)

                        // Cultural background chips
                        ChipGroup(
                            title: "Cultural background",
                            options: SampleData.culturalTagOptions.background,
                            selected: Bindable(viewModel).selectedBackground
                        )

                        // Languages chips
                        ChipGroup(
                            title: "Languages you speak",
                            options: SampleData.culturalTagOptions.languages,
                            selected: Bindable(viewModel).selectedLanguages
                        )

                        // Interests chips
                        ChipGroup(
                            title: "Interests",
                            options: SampleData.culturalTagOptions.interests,
                            selected: Bindable(viewModel).selectedInterests
                        )
                    }
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.bottom, Spacing.xl)
                }
                .scrollDismissesKeyboard(.interactively)

                // Bottom buttons
                VStack(spacing: Spacing.md) {
                    BelongButton(title: "Skip for now", style: .secondary, isFullWidth: true) {
                        viewModel.selectedBackground = []
                        viewModel.selectedLanguages = []
                        viewModel.selectedInterests = []
                        onContinue()
                    }
                    .accessibilityHint("Skip tag selection and continue")

                    BelongButton(
                        title: "Find my people",
                        style: .primary,
                        systemImage: "arrow.right"
                    ) {
                        onContinue()
                    }
                    .accessibilityHint("Continue with selected tags")
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
                .background(BelongColor.background)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .accessibilityLabel("Back")
            }
        }
    }
}

#Preview {
    NavigationStack {
        CulturalTagsScreen(
            viewModel: OnboardingViewModel(),
            onContinue: {}
        )
    }
}
