import SwiftUI

// MARK: - RootView
// Routes between splash, onboarding, and main app based on auth state.

struct RootView: View {
    @State private var appState = AppState()
    @State private var deps = DependencyContainer()

    var body: some View {
        Group {
            switch appState.authStatus {
            case .unknown:
                SplashView()
            case .onboarding:
                OnboardingFlow()
            case .authenticated:
                MainTabView()
            }
        }
        .environment(appState)
        .environment(deps)
        .task { await appState.checkAuth() }
    }
}

#Preview {
    RootView()
}
