import SwiftUI

// MARK: - RootView
// Routes between splash, onboarding, and main app based on auth state.

struct RootView: View {
    @State private var appState = AppState()
    @State private var deps = DependencyContainer()
    @State private var bannerManager = InAppBannerManager()
    @Environment(\.scenePhase) private var scenePhase

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
        .onChange(of: scenePhase) { _, newPhase in
            bannerManager.isAppActive = (newPhase == .active)
            if newPhase != .active {
                bannerManager.dismissAll()
            }
        }
    }
}

#Preview {
    RootView()
}
