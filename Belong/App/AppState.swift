import SwiftUI

@Observable @MainActor
final class AppState {
    enum AuthStatus { case unknown, onboarding, authenticated }

    enum MainTab: String, CaseIterable {
        case gatherings, posts, create, chat, profile

        var title: String {
            switch self {
            case .gatherings: "Gatherings"
            case .posts: "Posts"
            case .create: "Create"
            case .chat: "Chat"
            case .profile: "Profile"
            }
        }

        var systemImage: String {
            switch self {
            case .gatherings: "person.3"
            case .posts: "square.grid.2x2"
            case .create: "plus.circle.fill"
            case .chat: "bubble.left.and.bubble.right"
            case .profile: "person.crop.circle"
            }
        }
    }

    enum OnboardingStep: Int, CaseIterable {
        case welcome, email, otp, password, username, emailConfirmed
        case avatar, language, citySchool, culturalTags, complete
    }

    var authStatus: AuthStatus = .unknown
    var currentUser: User?
    var selectedTab: MainTab = .gatherings
    var previousTab: MainTab = .gatherings
    var onboardingStep: OnboardingStep = .welcome
    var showCreateSheet = false
    var showCreateGatheringFlow = false
    var showCreatePostScreen = false
    var unreadNotificationCount = 3
    var unreadChatCount = 2

    var totalBadgeCount: Int { unreadNotificationCount + unreadChatCount }

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
        selectedTab = .gatherings
    }

    func checkAuth() {
        // In production: check stored JWT/session
        // For now: go to onboarding
        authStatus = .onboarding
    }
}
