import SwiftUI

struct CulturalTagsScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Environment(AppState.self) private var appState
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    CulturalTagsHeader()
                    CulturalBackgroundSection()
                    CulturalLanguagesSection()
                    CulturalInterestsSection()
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.base)
            }

            CulturalTagsActions(path: $path)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
                .padding(.top, Spacing.base)
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
        .task {
            await viewModel.loadTagPresets()
        }
    }
}

struct CulturalTagsHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Tell us about you")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("This helps us find gatherings and people you'll love.")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

struct CulturalBackgroundSection: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("\u{1F30D} Cultural background")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            ChipGroup(
                options: viewModel.backgroundPresets,
                selected: $vm.selectedBackgrounds
            )
        }
    }
}

struct CulturalLanguagesSection: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("\u{1F5E3}\u{FE0F} Languages you speak")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            ChipGroup(
                options: viewModel.languagePresets,
                selected: $vm.selectedLanguages
            )
        }
    }
}

struct CulturalInterestsSection: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("\u{2728} Interests & vibes")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            ChipGroup(
                options: viewModel.interestPresets,
                selected: $vm.selectedInterests
            )
        }
    }
}

struct CulturalTagsActions: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(spacing: Spacing.md) {
            BelongButton(
                title: "Find my people \u{2192}",
                style: .primary,
                isFullWidth: true,
                isLoading: viewModel.isSubmittingTags
            ) {
                Task {
                    await viewModel.submitTags()
                    path.append(.complete)
                }
            }

            BelongButton(
                title: "Skip for now",
                style: .secondary,
                isFullWidth: true
            ) {
                path.append(.complete)
            }
        }
    }
}

#Preview {
    struct CulturalTagsPreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                CulturalTagsScreen(path: $path)
            }
            .environment(AppState())
            .environment(OnboardingViewModel(deps: DependencyContainer()))
        }
    }
    return CulturalTagsPreview()
}
