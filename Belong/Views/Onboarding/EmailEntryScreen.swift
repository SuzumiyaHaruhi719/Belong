import SwiftUI

// MARK: - EmailEntryScreen (S02)
// Email input with validation, loading state, and inline error display.
// ProgressBarView step 1 of 4.

struct EmailEntryScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    ProgressBarView(totalSteps: 4, currentStep: 1)
                        .padding(.top, Spacing.sm)

                    // Header
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("What's your email?")
                            .font(BelongFont.h1())
                            .foregroundStyle(BelongColor.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        Text("We'll send a verification code.")
                            .font(BelongFont.body())
                            .foregroundStyle(BelongColor.textSecondary)
                    }

                    // Email field
                    BelongTextField(
                        label: "Email",
                        text: Bindable(viewModel).email,
                        placeholder: "you@example.com",
                        errorMessage: viewModel.emailError,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never,
                        leadingIcon: "envelope"
                    )

                    Spacer(minLength: Spacing.xl)

                    // Send code button
                    BelongButton(
                        title: "Send verification code",
                        style: .primary,
                        isLoading: viewModel.isSendingOTP
                    ) {
                        Task {
                            await viewModel.sendOTP()
                            if viewModel.emailError == nil {
                                onContinue()
                            }
                        }
                    }
                    .accessibilityHint("Sends a 6-digit verification code to your email")
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
        EmailEntryScreen(
            viewModel: OnboardingViewModel(),
            onContinue: {}
        )
    }
}
