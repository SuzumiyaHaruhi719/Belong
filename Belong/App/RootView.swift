import SwiftUI

// MARK: - RootView
// Top-level view that switches between splash, onboarding, and main app.
// UX Decision: Uses a crossfade transition between auth states so the
// switch feels intentional, not jarring.

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            switch appState.authStatus {
            case .unknown:
                splashView
            case .onboarding:
                OnboardingFlow()
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.authStatus == .authenticated)
        .environment(appState)
        .task {
            await appState.checkAuth()
        }
    }

    private var splashView: some View {
        ZStack {
            BelongColor.background.ignoresSafeArea()
            VStack(spacing: Spacing.base) {
                Text("belong")
                    .font(BelongFont.display(36))
                    .foregroundStyle(BelongColor.primary)
                ProgressView()
                    .tint(BelongColor.primary)
            }
        }
        .accessibilityLabel("Loading Belong")
    }
}

// Make AuthStatus equatable for animation value
extension AppState.AuthStatus: Equatable {}

#Preview {
    RootView()
}
