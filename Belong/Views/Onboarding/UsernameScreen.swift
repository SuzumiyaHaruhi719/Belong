import SwiftUI

// MARK: - UsernameScreen (S05)
// Username selection with real-time availability check (debounced).
// ProgressBarView step 4 of 4.

struct UsernameScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    /// Debounce identifier — changes trigger .task(id:) re-evaluation
    @State private var usernameDebounceID = 0

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    ProgressBarView(totalSteps: 4, currentStep: 4)
                        .padding(.top, Spacing.sm)

                    // Header
                    Text("Pick a username")
                        .font(BelongFont.h1())
                        .foregroundStyle(BelongColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    // Username field with status indicator
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        BelongTextField(
                            label: "Username",
                            text: Bindable(viewModel).username,
                            placeholder: "your.username",
                            errorMessage: viewModel.usernameError,
                            characterLimit: 20,
                            autocapitalization: .never,
                            leadingIcon: "at"
                        )

                        // Availability status
                        HStack(spacing: Spacing.xs) {
                            if viewModel.isCheckingUsername {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(BelongColor.textTertiary)
                                Text("Checking availability...")
                                    .font(BelongFont.caption())
                                    .foregroundStyle(BelongColor.textTertiary)
                            } else if let available = viewModel.usernameAvailable {
                                if available {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(BelongColor.success)
                                        .font(.system(size: 14))
                                    Text("Username is available")
                                        .font(BelongFont.caption())
                                        .foregroundStyle(BelongColor.success)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(BelongColor.error)
                                        .font(.system(size: 14))
                                    Text("Username is taken")
                                        .font(BelongFont.caption())
                                        .foregroundStyle(BelongColor.error)
                                }
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }

                    Spacer(minLength: Spacing.xl)

                    // Continue button
                    BelongButton(
                        title: "Continue",
                        style: .primary,
                        isDisabled: !viewModel.isUsernameValid
                    ) {
                        onContinue()
                    }
                    .accessibilityHint("Continue to email confirmation")
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
        .onChange(of: viewModel.username) { _, _ in
            usernameDebounceID += 1
            viewModel.usernameAvailable = nil
            viewModel.usernameError = nil
        }
        .task(id: usernameDebounceID) {
            // Debounce: wait 500ms before checking availability
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await viewModel.checkUsernameAvailability()
        }
    }
}

#Preview {
    NavigationStack {
        UsernameScreen(
            viewModel: OnboardingViewModel(),
            onContinue: {}
        )
    }
}
