import SwiftUI

// MARK: - CitySchoolScreen (S09)
// City and school selection with search filtering.
// School picker appears after city is selected.

struct CitySchoolScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    /// Filtered cities based on search text
    private var filteredCities: [String] {
        if viewModel.citySearchText.isEmpty {
            return SampleData.cities
        }
        return SampleData.cities.filter {
            $0.localizedCaseInsensitiveContains(viewModel.citySearchText)
        }
    }

    /// Schools for the selected city, filtered by search text
    private var filteredSchools: [String] {
        guard !viewModel.selectedCity.isEmpty,
              let schools = SampleData.schoolsByCity[viewModel.selectedCity] else {
            return []
        }
        if viewModel.schoolSearchText.isEmpty {
            return schools
        }
        return schools.filter {
            $0.localizedCaseInsensitiveContains(viewModel.schoolSearchText)
        }
    }

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Where are you?")
                            .font(BelongFont.h1())
                            .foregroundStyle(BelongColor.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        Text("This helps us find gatherings near you.")
                            .font(BelongFont.body())
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                    .padding(.top, Spacing.sm)

                    // City picker
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("City")
                            .font(BelongFont.bodyMedium())
                            .foregroundStyle(BelongColor.textPrimary)

                        // Search field for city
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(BelongColor.textTertiary)
                            TextField("Search city", text: Bindable(viewModel).citySearchText)
                                .font(BelongFont.body())
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, Spacing.base)
                        .frame(height: Layout.inputHeight)
                        .background(BelongColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                        .overlay {
                            RoundedRectangle(cornerRadius: Layout.radiusMd)
                                .strokeBorder(BelongColor.border, lineWidth: 1)
                        }
                        .accessibilityLabel("Search city")

                        // City list
                        LazyVStack(spacing: 0) {
                            ForEach(filteredCities, id: \.self) { city in
                                cityRow(city)
                            }
                        }
                    }

                    // School picker — only after city is selected
                    if !viewModel.selectedCity.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("School")
                                .font(BelongFont.bodyMedium())
                                .foregroundStyle(BelongColor.textPrimary)

                            // Search field for school
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(BelongColor.textTertiary)
                                TextField("Search school", text: Bindable(viewModel).schoolSearchText)
                                    .font(BelongFont.body())
                                    .textInputAutocapitalization(.never)
                            }
                            .padding(.horizontal, Spacing.base)
                            .frame(height: Layout.inputHeight)
                            .background(BelongColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                            .overlay {
                                RoundedRectangle(cornerRadius: Layout.radiusMd)
                                    .strokeBorder(BelongColor.border, lineWidth: 1)
                            }
                            .accessibilityLabel("Search school")

                            // School list
                            LazyVStack(spacing: 0) {
                                ForEach(filteredSchools, id: \.self) { school in
                                    schoolRow(school)
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer(minLength: Spacing.xl)

                    // Continue button
                    BelongButton(
                        title: "Continue",
                        style: .primary,
                        isDisabled: !viewModel.isCitySchoolValid
                    ) {
                        onContinue()
                    }
                    .accessibilityHint("Continue to cultural tags")
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
                .animation(.easeInOut(duration: 0.3), value: viewModel.selectedCity)
            }
            .scrollDismissesKeyboard(.interactively)
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

    // MARK: - Row Views

    private func cityRow(_ city: String) -> some View {
        let isSelected = viewModel.selectedCity == city

        return Button {
            viewModel.selectedCity = city
            viewModel.selectedSchool = ""
            viewModel.schoolSearchText = ""
        } label: {
            HStack {
                Text(city)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(BelongColor.primary)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(.horizontal, Spacing.base)
            .frame(height: 48)
            .background(isSelected ? BelongColor.surfaceSecondary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(city)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func schoolRow(_ school: String) -> some View {
        let isSelected = viewModel.selectedSchool == school

        return Button {
            viewModel.selectedSchool = school
        } label: {
            HStack {
                Text(school)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(BelongColor.primary)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(.horizontal, Spacing.base)
            .frame(height: 48)
            .background(isSelected ? BelongColor.surfaceSecondary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(school)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    NavigationStack {
        CitySchoolScreen(
            viewModel: OnboardingViewModel(),
            onContinue: {}
        )
    }
}
