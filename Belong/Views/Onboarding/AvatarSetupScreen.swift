import SwiftUI

// MARK: - AvatarSetupScreen (S07)
// Avatar emoji selection with grid, photo upload option, and display name.

struct AvatarSetupScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    Text("How should we know you?")
                        .font(BelongFont.h1())
                        .foregroundStyle(BelongColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, Spacing.sm)

                    // Avatar preview
                    AvatarView(emoji: viewModel.selectedAvatar, size: 80)
                        .accessibilityLabel("Selected avatar: \(viewModel.selectedAvatar)")

                    // Avatar grid
                    AvatarGrid(
                        avatars: SampleData.defaultAvatars,
                        selected: Bindable(viewModel).selectedAvatar
                    )

                    // Upload photo button
                    BelongButton(
                        title: "Upload photo",
                        style: .tertiary,
                        systemImage: "camera"
                    ) {
                        // TODO: Photo picker integration
                    }
                    .accessibilityHint("Choose a photo from your library")

                    // Display name
                    BelongTextField(
                        label: "Display name",
                        text: Bindable(viewModel).displayName,
                        placeholder: "How friends will see you",
                        errorMessage: viewModel.displayNameError,
                        characterLimit: 30
                    )

                    Spacer(minLength: Spacing.xl)

                    // Continue
                    BelongButton(
                        title: "Continue",
                        style: .primary,
                        isDisabled: !viewModel.isDisplayNameValid
                    ) {
                        onContinue()
                    }
                    .accessibilityHint("Continue to language selection")
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
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
}

#Preview {
    NavigationStack {
        AvatarSetupScreen(
            viewModel: {
                let vm = OnboardingViewModel()
                vm.displayName = "Mai"
                return vm
            }(),
            onContinue: {}
        )
    }
}
