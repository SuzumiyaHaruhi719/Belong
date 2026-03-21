import SwiftUI

struct UsernameScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBarView(totalSegments: 4, filledSegments: 4)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    UsernameHeader()
                    UsernameInput()
                    UsernameAvailabilityIndicator()
                    UsernameContinueButton(path: $path)
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.xxl)
            }
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
    }
}

struct UsernameHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Pick a username")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("This is how other students will find you.")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

struct UsernameInput: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        BelongTextField(
            label: "Username",
            text: $vm.username,
            placeholder: "your.username",
            errorMessage: usernameError,
            characterLimit: 30,
            leadingIcon: "at"
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .accessibilityLabel("Username")
        .onChange(of: viewModel.username) { _, _ in
            viewModel.checkUsername()
        }
    }

    private var usernameError: String? {
        guard !viewModel.username.isEmpty else { return nil }
        if viewModel.username.count < 3 { return "Must be at least 3 characters" }
        if viewModel.usernameAvailable == false { return "This username is taken" }
        return nil
    }
}

struct UsernameAvailabilityIndicator: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if viewModel.isCheckingUsername {
                ProgressView()
                    .controlSize(.small)
                    .tint(BelongColor.primary)
                Text("Checking availability...")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textTertiary)
            } else if let available = viewModel.usernameAvailable, viewModel.username.count >= 3 {
                if available {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(BelongColor.success)
                    Text("Username is available")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.success)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(BelongColor.error)
                    Text("Username is taken")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.error)
                }
            }
        }
    }
}

struct UsernameContinueButton: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        BelongButton(
            title: "Continue",
            style: .primary,
            isFullWidth: true,
            isLoading: viewModel.isRegistering,
            isDisabled: !viewModel.isUsernameValid
        ) {
            Task {
                if let _ = await viewModel.register() {
                    path.append(.emailConfirmed)
                }
            }
        }
    }
}

#Preview {
    struct UsernamePreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                UsernameScreen(path: $path)
            }
            .environment(OnboardingViewModel(deps: DependencyContainer()))
        }
    }
    return UsernamePreview()
}
