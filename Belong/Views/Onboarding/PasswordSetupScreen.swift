import SwiftUI

// MARK: - PasswordSetupScreen (S04)
// Password creation with real-time rule checklist and confirm field.
// ProgressBarView step 3 of 4.

struct PasswordSetupScreen: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    /// True when all 4 individual rules pass (before confirm match check)
    private var allRulesMet: Bool {
        viewModel.passwordRules.allSatisfy(\.met)
    }

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    ProgressBarView(totalSteps: 4, currentStep: 3)
                        .padding(.top, Spacing.sm)

                    // Header
                    Text("Create a password")
                        .font(BelongFont.h1())
                        .foregroundStyle(BelongColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    // Password field
                    BelongTextField(
                        label: "Password",
                        text: Bindable(viewModel).password,
                        placeholder: "Enter your password",
                        isSecure: true,
                        autocapitalization: .never
                    )

                    // Password rules checklist
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ForEach(viewModel.passwordRules, id: \.label) { rule in
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: rule.met ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(rule.met ? BelongColor.success : BelongColor.textTertiary)
                                    .font(.system(size: 16))

                                Text(rule.label)
                                    .font(BelongFont.secondary())
                                    .foregroundStyle(rule.met ? BelongColor.textPrimary : BelongColor.textTertiary)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(rule.label), \(rule.met ? "met" : "not met")")
                        }
                    }

                    // Confirm password — only shows when all rules are met
                    if allRulesMet {
                        BelongTextField(
                            label: "Confirm password",
                            text: Bindable(viewModel).confirmPassword,
                            placeholder: "Re-enter your password",
                            errorMessage: confirmError,
                            isSecure: true,
                            autocapitalization: .never
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer(minLength: Spacing.xl)

                    // Continue button
                    BelongButton(
                        title: "Continue",
                        style: .primary,
                        isDisabled: !viewModel.isPasswordValid
                    ) {
                        onContinue()
                    }
                    .accessibilityHint("Continue to username selection")
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxxl)
                .animation(.easeInOut(duration: 0.3), value: allRulesMet)
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

    /// Show mismatch error only when user has started typing confirm and it doesn't match
    private var confirmError: String? {
        guard !viewModel.confirmPassword.isEmpty else { return nil }
        return viewModel.password != viewModel.confirmPassword ? "Passwords don't match" : nil
    }
}

#Preview {
    NavigationStack {
        PasswordSetupScreen(
            viewModel: OnboardingViewModel(),
            onContinue: {}
        )
    }
}
