import SwiftUI

// MARK: - WelcomeScreen (S01)
// Full-screen welcome with app branding, tagline, social proof, and CTAs.
// No navigation bar. Center-aligned layout.

struct WelcomeScreen: View {
    let onGetStarted: () -> Void
    let onLogin: () -> Void

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // App branding
                VStack(spacing: Spacing.md) {
                    Text("belong")
                        .font(BelongFont.display(42))
                        .foregroundStyle(BelongColor.primary)
                        .accessibilityLabel("Belong")

                    Text("Find your people, share your culture.")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("Find your people, share your culture.")
                }

                Spacer()

                // Social proof
                Text("Join 2,000+ students finding community")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textTertiary)
                    .accessibilityLabel("Join 2,000 plus students finding community")

                // CTAs
                VStack(spacing: Spacing.md) {
                    BelongButton(title: "Get started", style: .primary) {
                        onGetStarted()
                    }
                    .accessibilityHint("Create a new account")

                    BelongButton(title: "I already have an account", style: .tertiary) {
                        onLogin()
                    }
                    .accessibilityHint("Sign in to your existing account")
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.xxxl)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        WelcomeScreen(
            onGetStarted: {},
            onLogin: {}
        )
    }
}
