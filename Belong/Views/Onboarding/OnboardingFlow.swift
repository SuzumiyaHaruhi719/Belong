import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var deps
    @State private var path: [AppState.OnboardingStep] = []
    @State private var viewModel: OnboardingViewModel?
    @State private var showLogin = false
    @State private var didResumeIncomplete = false

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeScreen(path: $path, showLogin: $showLogin)
                .navigationDestination(for: AppState.OnboardingStep.self) { step in
                    OnboardingDestination(step: step, path: $path)
                }
        }
        .sheet(isPresented: $showLogin) {
            NavigationStack {
                LoginScreen()
            }
            .environment(appState)
            .environment(viewModel ?? OnboardingViewModel(deps: deps))
        }
        .onChange(of: appState.authStatus) { _, newValue in
            if newValue == .authenticated || newValue == .incompleteOnboarding {
                showLogin = false
            }
        }
        .task {
            if viewModel == nil {
                viewModel = OnboardingViewModel(deps: deps)
            }
            // If returning with an existing session but incomplete profile,
            // pre-populate known fields and jump to the profile setup steps.
            if appState.authStatus == .incompleteOnboarding,
               !didResumeIncomplete,
               let user = appState.currentUser {
                didResumeIncomplete = true
                let vm = viewModel ?? OnboardingViewModel(deps: deps)
                vm.email = user.email
                vm.username = user.username
                vm.displayName = user.displayName
                // Skip auth steps (already verified), go straight to avatar setup
                path = [.avatar]
            }
        }
        .environment(viewModel ?? OnboardingViewModel(deps: deps))
    }
}

struct OnboardingDestination: View {
    let step: AppState.OnboardingStep
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        switch step {
        case .welcome:
            WelcomeScreen(path: $path, showLogin: .constant(false))
        case .email:
            EmailEntryScreen(path: $path)
        case .otp:
            OTPVerificationScreen(path: $path)
        case .password:
            PasswordSetupScreen(path: $path)
        case .username:
            UsernameScreen(path: $path)
        case .emailConfirmed:
            EmailConfirmedScreen(path: $path)
        case .avatar:
            AvatarSetupScreen(path: $path)
        case .language:
            LanguageScreen(path: $path)
        case .citySchool:
            CitySchoolScreen(path: $path)
        case .culturalTags:
            CulturalTagsScreen(path: $path)
        case .complete:
            OnboardingCompleteScreen()
        }
    }
}

#Preview {
    OnboardingFlow()
        .environment(AppState())
        .environment(DependencyContainer())
}
