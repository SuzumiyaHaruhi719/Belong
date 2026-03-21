import SwiftUI

// MARK: - OnboardingCompleteScreen (S11)
// Celebration screen with personalized welcome message.
// No back button. Single CTA completes onboarding.

struct OnboardingCompleteScreen: View {
    let viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Celebration icon
                Image(systemName: "party.popper")
                    .font(.system(size: 48))
                    .foregroundStyle(BelongColor.primary)
                    .accessibilityHidden(true)

                // Personalized welcome
                VStack(spacing: Spacing.sm) {
                    Text("Welcome to Belong, \(viewModel.displayName)!")
                        .font(BelongFont.h1())
                        .foregroundStyle(BelongColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)

                    Text("We've found gatherings near \(viewModel.selectedCity). Let's explore!")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // CTA
                BelongButton(title: "Start exploring", style: .primary) {
                    onComplete()
                }
                .accessibilityHint("Enter the app and start exploring gatherings")
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.xxxl)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        OnboardingCompleteScreen(
            viewModel: {
                let vm = OnboardingViewModel()
                vm.displayName = "Mai"
                vm.selectedCity = "Melbourne"
                return vm
            }(),
            onComplete: {}
        )
    }
}
