import SwiftUI

// MARK: - RootView
// Routes between splash, onboarding, and main app based on auth state.

struct RootView: View {
    @State private var appState = AppState()
    @State private var deps = DependencyContainer()
    @State private var bannerManager = InAppBannerManager()

    var body: some View {
        Group {
            switch appState.authStatus {
            case .unknown:
                SplashView()
            case .onboarding:
                OnboardingFlow()
            case .authenticated:
                MainTabView()
                    .inAppBannerOverlay()
            }
        }
        .environment(appState)
        .environment(deps)
        .environment(bannerManager)
        .task { await appState.checkAuth() }
    }
}

#Preview {
    RootView()
}
