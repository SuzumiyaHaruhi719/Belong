import SwiftUI

// MARK: - AppState
// Central observable state that drives root navigation.
// Determines whether the user sees onboarding, login, or the main tab bar.
//
// Architecture Decision: Single @Observable class at the app root rather than
// distributed @EnvironmentObject instances. This keeps the "where am I?" logic
// in one place and avoids scattered state that can desync.

@Observable
final class AppState {
    enum AuthStatus {
        case unknown      // App just launched, checking stored session
        case onboarding   // New user — show onboarding flow
        case authenticated // Logged in — show main tab bar
    }

    var authStatus: AuthStatus = .unknown
    var currentUser: User? = nil

    // Onboarding progress (persisted across app kills via UserDefaults in production)
    var onboardingStep: OnboardingStep = .welcome

    // Tab selection
    var selectedTab: MainTab = .home

    // MARK: Actions

    func completeOnboarding(user: User) {
        currentUser = user
        authStatus = .authenticated
    }

    func login(user: User) {
        currentUser = user
        authStatus = .authenticated
    }

    func logout() {
        currentUser = nil
        authStatus = .onboarding
    }

    /// Simulate initial load (would check keychain/token in production)
    func checkAuth() async {
        try? await Task.sleep(for: .seconds(0.5))
        // For development, always start at onboarding
        authStatus = .onboarding
    }
}

// MARK: - Navigation Enums

enum OnboardingStep: Int, CaseIterable, Comparable {
    case welcome = 0
    case email
    case otp
    case password
    case username
    case emailConfirmed
    case avatar
    case language
    case citySchool
    case culturalTags
    case complete

    static func < (lhs: OnboardingStep, rhs: OnboardingStep) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum MainTab: Int, CaseIterable {
    case home
    case events
    case host
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .events: return "My Events"
        case .host: return "Host"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .events: return "calendar"
        case .host: return "plus.circle"
        case .profile: return "person"
        }
    }

    var selectedImage: String {
        switch self {
        case .home: return "house.fill"
        case .events: return "calendar"
        case .host: return "plus.circle.fill"
        case .profile: return "person.fill"
        }
    }
}
