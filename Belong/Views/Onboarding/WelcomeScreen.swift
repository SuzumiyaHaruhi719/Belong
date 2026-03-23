import SwiftUI

struct WelcomeScreen: View {
    @Binding var path: [AppState.OnboardingStep]
    @Binding var showLogin: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            WelcomeHero(appeared: appeared)
            Spacer()
            WelcomeActions(path: $path, showLogin: $showLogin, appeared: appeared)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(BelongMotion.expressive.delay(0.2)) {
                appeared = true
            }
        }
    }
}

struct WelcomeHero: View {
    let appeared: Bool

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            // Wordmark — large, confident, primary color
            VStack(spacing: Spacing.md) {
                Text("Belong")
                    .font(.system(size: 56, weight: .bold, design: .serif))
                    .foregroundStyle(BelongColor.primary)
                    .tracking(-1)

                // Thin accent line — subtle brand touch
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(BelongColor.primaryMuted)
                    .frame(width: 40, height: 2.5)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)

            // Tagline — serif, warmer tone, breathing room
            VStack(spacing: Spacing.sm) {
                Text("Find your people.")
                    .font(BelongFont.h1(24))
                    .foregroundStyle(BelongColor.textPrimary)

                Text("Share your culture.")
                    .font(BelongFont.h1(24))
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .multilineTextAlignment(.center)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)

            // Social proof — restrained, trustworthy
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(BelongColor.sage)
                Text("4,200+ students from 80+ countries")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .padding(.horizontal, Spacing.base)
            .padding(.vertical, Spacing.sm)
            .background(BelongColor.sageLight.opacity(0.6))
            .clipShape(Capsule())
            .opacity(appeared ? 1 : 0)
        }
    }
}

struct WelcomeActions: View {
    @Binding var path: [AppState.OnboardingStep]
    @Binding var showLogin: Bool
    let appeared: Bool

    var body: some View {
        VStack(spacing: Spacing.md) {
            BelongButton(
                title: "Get started",
                style: .primary,
                isFullWidth: true
            ) {
                path.append(.email)
            }

            Button {
                showLogin = true
            } label: {
                Text("I already have an account")
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Layout.buttonHeight)
            }
        }
        .opacity(appeared ? 1 : 0)
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
