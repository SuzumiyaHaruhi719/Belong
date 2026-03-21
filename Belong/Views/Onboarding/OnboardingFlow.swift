import SwiftUI

// MARK: - OnboardingFlow
// NavigationStack-based coordinator for all onboarding steps (S01–S11).
// Creates a single OnboardingViewModel instance and passes it to child views.
// Uses type-safe navigationDestination(for: OnboardingStep.self).

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = OnboardingViewModel()
    @State private var path: [OnboardingStep] = []

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeScreen(
                onGetStarted: { advance(to: .email) },
                onLogin: { /* TODO: Login flow */ }
            )
            .navigationDestination(for: OnboardingStep.self) { step in
                destinationView(for: step)
            }
        }
    }

    // MARK: - Routing

    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            WelcomeScreen(
                onGetStarted: { advance(to: .email) },
                onLogin: { /* TODO: Login flow */ }
            )

        case .email:
            EmailEntryScreen(viewModel: viewModel) {
                advance(to: .otp)
            }

        case .otp:
            OTPVerificationScreen(viewModel: viewModel) {
                advance(to: .password)
            }

        case .password:
            PasswordSetupScreen(viewModel: viewModel) {
                advance(to: .username)
            }

        case .username:
            UsernameScreen(viewModel: viewModel) {
                advance(to: .emailConfirmed)
            }

        case .emailConfirmed:
            EmailConfirmedScreen {
                advance(to: .avatar)
            }

        case .avatar:
            AvatarSetupScreen(viewModel: viewModel) {
                advance(to: .language)
            }

        case .language:
            LanguageScreen(viewModel: viewModel) {
                advance(to: .citySchool)
            }

        case .citySchool:
            CitySchoolScreen(viewModel: viewModel) {
                advance(to: .culturalTags)
            }

        case .culturalTags:
            CulturalTagsScreen(viewModel: viewModel) {
                advance(to: .complete)
            }

        case .complete:
            OnboardingCompleteScreen(viewModel: viewModel) {
                completeOnboarding()
            }
        }
    }

    // MARK: - Navigation Helpers

    private func advance(to step: OnboardingStep) {
        path.append(step)
    }

    private func completeOnboarding() {
        appState.completeOnboarding(user: viewModel.buildUser())
    }
}

#Preview {
    OnboardingFlow()
        .environment(AppState())
}
