import SwiftUI
import Supabase

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

            #if DEBUG
            // Dev-mode test credentials hint
            VStack(alignment: .leading, spacing: 4) {
                Text("Test accounts (dev only)")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.primary)
                Text("mai@unimelb.edu / Belong123!")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(BelongColor.textTertiary)
                Text("test@test.edu / Test1234!")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BelongColor.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
            .padding(.top, Spacing.sm)
            #endif
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
    @Environment(\.dismiss) private var dismiss
    @State private var showForgotPasswordAlert = false
    @State private var forgotPasswordMessage = ""
    @State private var isSendingReset = false

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
                        dismiss()
                        appState.login(user: user)
                    }
                }
            }

            Button {
                Task {
                    let email = viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !email.isEmpty else {
                        forgotPasswordMessage = "Please enter your email address first."
                        showForgotPasswordAlert = true
                        return
                    }
                    isSendingReset = true
                    do {
                        try await SupabaseManager.shared.client.auth.resetPasswordForEmail(email)
                        forgotPasswordMessage = "Password reset email sent. Check your inbox."
                    } catch {
                        forgotPasswordMessage = "Failed to send reset email: \(error.localizedDescription)"
                    }
                    isSendingReset = false
                    showForgotPasswordAlert = true
                }
            } label: {
                if isSendingReset {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Forgot password?")
                        .font(BelongFont.secondaryMedium())
                        .foregroundStyle(BelongColor.primary)
                }
            }
            .disabled(isSendingReset)
            .accessibilityLabel("Forgot password")
            .alert("Password Reset", isPresented: $showForgotPasswordAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(forgotPasswordMessage)
            }
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
