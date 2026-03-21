import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var deps
    @State private var path: [AppState.OnboardingStep] = []
    @State private var viewModel: OnboardingViewModel?
    @State private var showLogin = false

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
        .task {
            if viewModel == nil {
                viewModel = OnboardingViewModel(deps: deps)
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
