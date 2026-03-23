import SwiftUI

struct EditProfileScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                EditProfileContent(viewModel: vm, onDismiss: { dismiss() })
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = EditProfileViewModel(userService: container.userService)
                if let user = appState.currentUser {
                    vm.loadCurrentValues(from: user)
                }
                viewModel = vm
                await vm.loadCities()
                await vm.loadSchools()
            }
        }
    }
}

// MARK: - Content

private struct EditProfileContent: View {
    @Bindable var viewModel: EditProfileViewModel
    let onDismiss: () -> Void
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                EditProfileAvatarSection()

                if let error = viewModel.error {
                    InlineErrorBanner(message: error) {
                        viewModel.error = nil
                    }
                    .padding(.horizontal, Layout.screenPadding)
                }

                EditProfileFormFields(viewModel: viewModel)
            }
            .padding(.bottom, Spacing.xxxl)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        if let updated = await viewModel.save() {
                            appState.currentUser = updated
                            onDismiss()
                        }
                    }
                }
                .font(BelongFont.bodySemiBold())
                .foregroundStyle(viewModel.hasChanges ? BelongColor.primary : BelongColor.disabled)
                .disabled(!viewModel.hasChanges || viewModel.isSaving)
            }
        }
    }
}

// MARK: - Avatar Section

private struct EditProfileAvatarSection: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(emoji: "👤", size: .xlarge)
                Image(systemName: "camera.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(BelongColor.textOnPrimary)
                    .frame(width: 28, height: 28)
                    .background(BelongColor.primary)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(BelongColor.surface, lineWidth: 2))
            }
            Text("Change Photo")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.primary)
        }
        .padding(.top, Spacing.xl)
    }
}

// MARK: - Form Fields

private struct EditProfileFormFields: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        VStack(spacing: Spacing.lg) {
            BelongTextField(
                label: "Display Name",
                text: $viewModel.displayName,
                placeholder: "Your display name",
                characterLimit: 50
            )

            EditProfileBioField(bio: $viewModel.bio)

            EditProfileCityPicker(viewModel: viewModel)

            EditProfileSchoolPicker(viewModel: viewModel)
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Bio Field

private struct EditProfileBioField: View {
    @Binding var bio: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Bio")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            TextEditor(text: $bio)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(Spacing.md)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusMd)
                        .stroke(BelongColor.border, lineWidth: 1)
                )

            HStack {
                Spacer()
                Text("\(bio.count)/300")
                    .font(BelongFont.caption())
                    .foregroundStyle(bio.count > 300 ? BelongColor.error : BelongColor.textTertiary)
            }
        }
    }
}

// MARK: - City Picker

private struct EditProfileCityPicker: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("City")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            Menu {
                ForEach(viewModel.availableCities, id: \.self) { city in
                    Button(city) {
                        viewModel.selectedCity = city
                        viewModel.selectedSchool = ""
                        Task { await viewModel.loadSchools() }
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedCity.isEmpty ? "Select city" : viewModel.selectedCity)
                        .font(BelongFont.body())
                        .foregroundStyle(viewModel.selectedCity.isEmpty ? BelongColor.textTertiary : BelongColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(BelongColor.textTertiary)
                }
                .padding(.horizontal, Spacing.md)
                .frame(height: Layout.inputHeight)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusMd)
                        .stroke(BelongColor.border, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - School Picker

private struct EditProfileSchoolPicker: View {
    @Bindable var viewModel: EditProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("School")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            Menu {
                ForEach(viewModel.availableSchools, id: \.self) { school in
                    Button(school) {
                        viewModel.selectedSchool = school
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedSchool.isEmpty ? "Select school" : viewModel.selectedSchool)
                        .font(BelongFont.body())
                        .foregroundStyle(viewModel.selectedSchool.isEmpty ? BelongColor.textTertiary : BelongColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(BelongColor.textTertiary)
                }
                .padding(.horizontal, Spacing.md)
                .frame(height: Layout.inputHeight)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusMd)
                        .stroke(BelongColor.border, lineWidth: 1)
                )
            }
            .disabled(viewModel.selectedCity.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileScreen()
    }
    .environment(AppState())
    .environment(DependencyContainer())
}
