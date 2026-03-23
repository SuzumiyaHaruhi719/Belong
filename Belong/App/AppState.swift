import SwiftUI
import Supabase
import Auth

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
    var unreadNotificationCount = 0
    var unreadChatCount = 0

    var totalBadgeCount: Int { unreadNotificationCount + unreadChatCount }

    func completeOnboarding(user: User) {
        currentUser = user
        authStatus = .authenticated
    }

    func login(user: User) {
        currentUser = user
        authStatus = .authenticated
    }

    func logout() async {
        // Sign out from Supabase to clear persisted session token
        if DependencyContainer.useLiveBackend {
            try? await SupabaseManager.shared.client.auth.signOut()
            // Clean up Realtime WebSocket channels
            await SupabaseManager.shared.client.realtimeV2.removeAllChannels()
        }
        currentUser = nil
        authStatus = .onboarding
        selectedTab = .gatherings
        unreadChatCount = 0
        unreadNotificationCount = 0
    }

    func checkAuth() async {
        if DependencyContainer.useLiveBackend {
            let manager = SupabaseManager.shared
            do {
                let session = try await manager.client.auth.session
                let userId = session.user.id.uuidString.lowercased()
                // Session exists — try to fetch profile
                if let rows: [DBUser] = try? await manager.client.from("users")
                    .select()
                    .eq("id", value: userId)
                    .limit(1)
                    .execute()
                    .value,
                   let row = rows.first {
                    currentUser = mapUserRow(row)
                    authStatus = .authenticated
                    return
                }
                // Session valid but profile fetch failed (network issue) — still authenticated
                // Construct minimal user from session data
                currentUser = User(
                    id: userId,
                    email: session.user.email ?? "",
                    username: session.user.userMetadata["username"]?.value as? String ?? "",
                    displayName: session.user.userMetadata["username"]?.value as? String ?? "",
                    avatarURL: nil, defaultAvatarId: nil, bio: "",
                    city: "", school: "", appLanguage: "en",
                    privacyProfile: .publicProfile, privacyDM: .mutualOnly,
                    notificationsEnabled: true,
                    followerCount: 0, followingCount: 0, mutualCount: 0,
                    gatheringsAttended: 0, gatheringsHosted: 0, postCount: 0,
                    createdAt: Date(), lastActiveAt: Date()
                )
                authStatus = .authenticated
                return
            } catch {
                // No valid session — go to onboarding
            }
        }
        authStatus = .onboarding
    }
}
