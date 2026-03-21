import SwiftUI

struct PasswordSetupScreen: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProgressBarView(totalSegments: 4, filledSegments: 3)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    PasswordHeader()
                    PasswordFields()
                    PasswordRulesList()
                    PasswordContinueButton(path: $path)
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.xxl)
            }
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(false)
    }
}

struct PasswordHeader: View {
    var body: some View {
        Text("Create a password")
            .font(BelongFont.h1())
            .foregroundStyle(BelongColor.textPrimary)
    }
}

struct PasswordFields: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        VStack(spacing: Spacing.base) {
            BelongTextField(
                label: "Password",
                text: $vm.password,
                placeholder: "Create a strong password",
                isSecure: true
            )
            .textContentType(.newPassword)
            .accessibilityLabel("New password")
            .onChange(of: viewModel.password) { _, _ in
                viewModel.validatePassword()
            }

            if viewModel.allPasswordRulesMet {
                BelongTextField(
                    label: "Confirm password",
                    text: $vm.confirmPassword,
                    placeholder: "Re-enter your password",
                    errorMessage: confirmPasswordError,
                    isSecure: true
                )
                .textContentType(.newPassword)
                .accessibilityLabel("Confirm password")
            }
        }
    }

    private var confirmPasswordError: String? {
        guard !viewModel.confirmPassword.isEmpty else { return nil }
        return viewModel.passwordsMatch ? nil : "Passwords don't match"
    }
}

struct PasswordRulesList: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ForEach(viewModel.passwordRules) { rule in
                PasswordRuleRow(rule: rule)
            }
        }
    }
}

struct PasswordRuleRow: View {
    let rule: PasswordRule

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: rule.met ? "checkmark.circle.fill" : "minus.circle")
                .font(.system(size: 16))
                .foregroundStyle(rule.met ? BelongColor.success : BelongColor.textTertiary)

            Text(rule.label)
                .font(BelongFont.secondary())
                .foregroundStyle(rule.met ? BelongColor.success : BelongColor.textTertiary)
        }
    }
}

struct PasswordContinueButton: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        BelongButton(
            title: "Continue",
            style: .primary,
            isFullWidth: true,
            isDisabled: !viewModel.isPasswordStepValid
        ) {
            path.append(.username)
        }
    }
}

#Preview {
    struct PasswordPreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                PasswordSetupScreen(path: $path)
            }
            .environment(OnboardingViewModel(deps: DependencyContainer()))
        }
    }
    return PasswordPreview()
}
