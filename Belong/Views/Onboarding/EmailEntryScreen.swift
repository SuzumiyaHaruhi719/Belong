import SwiftUI

struct EmailEntryScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBarView(totalSegments: 4, filledSegments: 1)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    EmailEntryHeader()
                    EmailEntryField()
                    EmailEntryButton(path: $path)
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.xxl)
            }
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
    }
}

struct EmailEntryHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("What's your email?")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("Use your university email (.edu) to get started.")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

struct EmailEntryField: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        BelongTextField(
            label: "University email",
            text: $vm.email,
            placeholder: "you@university.edu",
            helperText: "Must be a .edu email address",
            errorMessage: viewModel.emailError,
            leadingIcon: "envelope"
        )
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .accessibilityLabel("University email address")
        .onChange(of: viewModel.email) { _, _ in
            viewModel.validateEmail()
        }
    }
}

struct EmailEntryButton: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        BelongButton(
            title: "Send verification code",
            style: .primary,
            isFullWidth: true,
            isLoading: viewModel.isSendingOTP,
            isDisabled: !viewModel.isEmailValid
        ) {
            Task {
                await viewModel.sendOTP()
                if viewModel.emailError == nil {
                    path.append(.otp)
                }
            }
        }
    }
}

#Preview {
    struct EmailEntryPreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                EmailEntryScreen(path: $path)
            }
            .environment(OnboardingViewModel(deps: DependencyContainer()))
        }
    }
    return EmailEntryPreview()
}
