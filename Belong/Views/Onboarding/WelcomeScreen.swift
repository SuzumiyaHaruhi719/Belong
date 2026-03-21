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
        VStack(spacing: Spacing.base) {
            Text("Belong")
                .font(BelongFont.display(48))
                .foregroundStyle(BelongColor.primary)

            Text("Find your people. Share your story.")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: Spacing.xs) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(BelongColor.sage)
                Text("Join 4,200+ students")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .padding(.top, Spacing.sm)
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
