import SwiftUI

struct WelcomeScreen: View {
    @Binding var path: [AppState.OnboardingStep]
    @Binding var showLogin: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            WelcomeHero()
            Spacer()
            WelcomeActions(path: $path, showLogin: $showLogin)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
        .navigationBarHidden(true)
    }
}

struct WelcomeHero: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // App wordmark with warm accent line
            VStack(spacing: Spacing.md) {
                Text("Belong")
                    .font(.system(size: 52, weight: .bold, design: .serif))
                    .foregroundStyle(BelongColor.primary)
                    .tracking(-0.5)

                // Decorative accent line
                RoundedRectangle(cornerRadius: 2)
                    .fill(BelongColor.primaryMuted)
                    .frame(width: 48, height: 3)
            }

            Text("Find your people.\nShare your story.")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Social proof badge
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(BelongColor.sage)
                Text("Join 4,200+ students")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.sm)
            .background(BelongColor.sageLight)
            .clipShape(Capsule())
        }
    }
}

struct WelcomeActions: View {
    @Binding var path: [AppState.OnboardingStep]
    @Binding var showLogin: Bool

    var body: some View {
        VStack(spacing: Spacing.md) {
            BelongButton(
                title: "Get started",
                style: .primary,
                isFullWidth: true
            ) {
                path.append(.email)
            }

            BelongButton(
                title: "I already have an account",
                style: .tertiary,
                isFullWidth: true
            ) {
                showLogin = true
            }
        }
    }
}

#Preview {
    struct WelcomePreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        @State private var showLogin = false
        var body: some View {
            NavigationStack(path: $path) {
                WelcomeScreen(path: $path, showLogin: $showLogin)
            }
            .environment(AppState())
            .environment(DependencyContainer())
        }
    }
    return WelcomePreview()
}
