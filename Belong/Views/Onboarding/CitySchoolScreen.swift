import SwiftUI

struct CitySchoolScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                CitySchoolHeader()
                CitySearchSection()
                if !viewModel.selectedCity.isEmpty {
                    SchoolSearchSection()
                }
                CitySchoolContinueButton(path: $path)
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
        .task {
            viewModel.searchCities()
        }
    }
}

struct CitySchoolHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("\u{1F4CD} Where are you?")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("This helps us show you local gatherings and people nearby.")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

struct CitySearchSection: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("City")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            SearchBar(
                text: $vm.cityQuery,
                placeholder: "Search for your city...",
                onDebouncedChange: { _ in viewModel.searchCities() }
            )
            .accessibilityLabel("City search")

            if !viewModel.cityResults.isEmpty && viewModel.selectedCity.isEmpty {
                CityResultsList()
            }

            if !viewModel.selectedCity.isEmpty {
                SelectedCityChip()
            }
        }
    }
}

struct CityResultsList: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.cityResults, id: \.self) { city in
                Button {
                    viewModel.selectCity(city)
                } label: {
                    HStack {
                        Image(systemName: "mappin.circle")
                            .foregroundStyle(BelongColor.textTertiary)
                        Text(city)
                            .font(BelongFont.body())
                            .foregroundStyle(BelongColor.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.md)
                }
                .accessibilityLabel("Select \(city)")

                if city != viewModel.cityResults.last {
                    Divider()
                        .background(BelongColor.divider)
                }
            }
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(BelongColor.border, lineWidth: 1)
        )
    }
}

struct SelectedCityChip: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(BelongColor.primary)
            Text(viewModel.selectedCity)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)
            Spacer()
            Button {
                viewModel.selectedCity = ""
                viewModel.cityQuery = ""
                viewModel.selectedSchool = ""
                viewModel.schoolQuery = ""
                viewModel.schoolResults = []
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .accessibilityLabel("Remove city selection")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(BelongColor.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
    }
}

struct SchoolSearchSection: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("School / University")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            if viewModel.selectedSchool.isEmpty {
                SchoolResultsList()
            } else {
                SelectedSchoolChip()
            }
        }
    }
}

struct SchoolResultsList: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.schoolResults, id: \.self) { school in
                Button {
                    viewModel.selectSchool(school)
                } label: {
                    HStack {
                        Image(systemName: "building.columns")
                            .foregroundStyle(BelongColor.textTertiary)
                        Text(school)
                            .font(BelongFont.body())
                            .foregroundStyle(BelongColor.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.md)
                }
                .accessibilityLabel("Select \(school)")

                if school != viewModel.schoolResults.last {
                    Divider()
                        .background(BelongColor.divider)
                }
            }
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(BelongColor.border, lineWidth: 1)
        )
    }
}

struct SelectedSchoolChip: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "building.columns.fill")
                .foregroundStyle(BelongColor.primary)
            Text(viewModel.selectedSchool)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)
            Spacer()
            Button {
                viewModel.selectedSchool = ""
                viewModel.schoolQuery = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .accessibilityLabel("Remove school selection")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(BelongColor.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
    }
}

struct CitySchoolContinueButton: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        BelongButton(
            title: "Continue",
            style: .primary,
            isFullWidth: true,
            isDisabled: !viewModel.canSelectCitySchool
        ) {
            path.append(.culturalTags)
        }
    }
}

#Preview {
    struct CitySchoolPreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                CitySchoolScreen(path: $path)
            }
            .environment(OnboardingViewModel(deps: DependencyContainer()))
        }
    }
    return CitySchoolPreview()
}
