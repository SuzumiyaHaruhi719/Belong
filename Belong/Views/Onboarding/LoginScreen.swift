import SwiftUI

struct LoginScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                LoginHeader()
                LoginForm()
                LoginErrorBanner()
                LoginActions()
                Spacer(minLength: Spacing.xxl)
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.xl)
        }
        .background(BelongColor.background)
        .navigationTitle("Log in")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(BelongColor.primary)
            }
        }
    }
}

struct LoginHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Welcome back")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("Log in to your Belong account")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

struct LoginForm: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel
        VStack(spacing: Spacing.base) {
            BelongTextField(
                label: "Email",
                text: $vm.email,
                placeholder: "you@university.edu",
                leadingIcon: "envelope"
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .accessibilityLabel("Email address")

            BelongTextField(
                label: "Password",
                text: $vm.password,
                placeholder: "Enter your password",
                isSecure: true
            )
            .textContentType(.password)
            .accessibilityLabel("Password")
        }
    }
}

struct LoginErrorBanner: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        if let error = viewModel.loginError {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(BelongColor.error)
                Text(error)
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.error)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BelongColor.errorLight)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
        }
    }
}

struct LoginActions: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: Spacing.md) {
            BelongButton(
                title: "Log in",
                style: .primary,
                isFullWidth: true,
                isLoading: viewModel.isLoggingIn,
                isDisabled: viewModel.email.isEmpty || viewModel.password.isEmpty
            ) {
                Task {
                    if let user = await viewModel.login() {
                        appState.login(user: user)
                    }
                }
            }

            Button {
                // Forgot password action placeholder
            } label: {
                Text("Forgot password?")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.primary)
            }
            .accessibilityLabel("Forgot password")
        }
    }
}

#Preview {
    NavigationStack {
        LoginScreen()
    }
    .environment(AppState())
    .environment(OnboardingViewModel(deps: DependencyContainer()))
}
