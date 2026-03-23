import SwiftUI

struct OTPVerificationScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBarView(totalSegments: 4, filledSegments: 2)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    OTPHeader()
                    OTPInput(path: $path)
                    OTPErrorMessage()
                    OTPResendRow()
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.xxl)
            }
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
    }
}

struct OTPHeader: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("\u{1F4E7} Check your email")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("We sent a 6-digit code to \(viewModel.maskedEmail)")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

struct OTPInput: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        @Bindable var vm = viewModel
        VStack(spacing: Spacing.base) {
            OTPField(code: $vm.otpCode) { code in
                guard code.count == 6, !viewModel.isVerifyingOTP else { return }
                Task {
                    await viewModel.verifyOTP()
                    if viewModel.otpVerified {
                        path.append(.password)
                    }
                }
            }
            .accessibilityLabel("Verification code")

            if viewModel.isVerifyingOTP {
                ProgressView()
                    .tint(BelongColor.primary)
            }
        }
    }
}

struct OTPErrorMessage: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        if let error = viewModel.otpError {
            Text(error)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.error)
        }
    }
}

struct OTPResendRow: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        HStack {
            if viewModel.otpCountdown > 0 {
                Text("Resend code in \(viewModel.otpCountdown)s")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textTertiary)
            } else {
                Button {
                    Task { await viewModel.resendOTP() }
                } label: {
                    Text("Resend code")
                        .font(BelongFont.secondaryMedium())
                        .foregroundStyle(BelongColor.primary)
                }
                .accessibilityLabel("Resend verification code")
            }
        }
    }
}

#Preview {
    struct OTPPreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                OTPVerificationScreen(path: $path)
            }
            .environment({
                let vm = OnboardingViewModel(deps: DependencyContainer())
                vm.email = "test@university.edu"
                return vm
            }())
        }
    }
    return OTPPreview()
}
