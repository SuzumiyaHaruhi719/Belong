import SwiftUI

// MARK: - OTPVerificationScreen (S03)
// 6-digit OTP entry with auto-verify, countdown timer, and resend link.
// ProgressBarView step 2 of 4.

struct OTPVerificationScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var countdown: Int = 60
    @State private var timerActive = true

    /// Masked email for display (e.g., "m***@example.com")
    private var maskedEmail: String {
        let email = viewModel.email
        guard let atIndex = email.firstIndex(of: "@") else { return email }
        let prefix = email[email.startIndex..<atIndex]
        guard prefix.count > 1 else { return email }
        let first = String(prefix.first!)
        let domain = String(email[atIndex...])
        return "\(first)***\(domain)"
    }

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    ProgressBarView(totalSteps: 4, currentStep: 2)
                        .padding(.top, Spacing.sm)

                    // Header
                    VStack(spacing: Spacing.sm) {
                        Text("Check your email")
                            .font(BelongFont.h1())
                            .foregroundStyle(BelongColor.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        Text("We sent a code to \(maskedEmail)")
                            .font(BelongFont.body())
                            .foregroundStyle(BelongColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // OTP field
                    OTPField(
                        code: Bindable(viewModel).otpCode,
                        onComplete: { code in
                            verifyCode()
                        }
                    )

                    // Error message
                    if let error = viewModel.otpError {
                        Text(error)
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.error)
                            .accessibilityLabel("Error: \(error)")
                    }

                    // Loading indicator
                    if viewModel.isVerifyingOTP {
                        ProgressView()
                            .tint(BelongColor.primary)
                            .accessibilityLabel("Verifying code")
                    }

                    // Resend countdown / link
                    if countdown > 0 {
                        Text("Resend code in 0:\(String(format: "%02d", countdown))")
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textTertiary)
                            .accessibilityLabel("Resend code in \(countdown) seconds")
                    } else {
                        Button {
                            resendCode()
                        } label: {
                            Text("Didn't receive a code? Resend")
                                .font(BelongFont.secondaryMedium())
                                .foregroundStyle(BelongColor.primary)
                        }
                        .accessibilityLabel("Resend verification code")
                        .accessibilityHint("Sends a new code to your email")
                    }

                    Spacer()
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
        .onAppear {
            startTimer()
        }
    }

    // MARK: - Actions

    private func verifyCode() {
        Task {
            let success = await viewModel.verifyOTP()
            if success {
                onContinue()
            }
        }
    }

    private func resendCode() {
        countdown = 60
        timerActive = true
        startTimer()
        Task {
            await viewModel.sendOTP()
        }
    }

    private func startTimer() {
        Task {
            while countdown > 0 && timerActive {
                try? await Task.sleep(for: .seconds(1))
                if countdown > 0 {
                    countdown -= 1
                }
            }
            timerActive = false
        }
    }
}

#Preview {
    NavigationStack {
        OTPVerificationScreen(
            viewModel: {
                let vm = OnboardingViewModel()
                vm.email = "test@example.com"
                return vm
            }(),
            onContinue: {}
        )
    }
}
