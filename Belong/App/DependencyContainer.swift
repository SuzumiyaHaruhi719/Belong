import SwiftUI

@Observable @MainActor
final class DependencyContainer {
    let authService: any AuthServiceProtocol
    let gatheringService: any GatheringServiceProtocol
    let postService: any PostServiceProtocol
    let chatService: any ChatServiceProtocol
    let userService: any UserServiceProtocol
    let notificationService: any NotificationServiceProtocol
    let storageService: any StorageServiceProtocol

    /// Set to `true` to use real Supabase backend, `false` for mock data.
    static let useLiveBackend = true

    init(
        authService: (any AuthServiceProtocol)? = nil,
        gatheringService: (any GatheringServiceProtocol)? = nil,
        postService: (any PostServiceProtocol)? = nil,
        chatService: (any ChatServiceProtocol)? = nil,
        userService: (any UserServiceProtocol)? = nil,
        notificationService: (any NotificationServiceProtocol)? = nil,
        storageService: (any StorageServiceProtocol)? = nil
    ) {
        let live = Self.useLiveBackend
        self.authService = authService ?? (live ? SupabaseAuthService() : MockAuthService())
        self.gatheringService = gatheringService ?? (live ? SupabaseGatheringService() : MockGatheringService())
        self.postService = postService ?? (live ? SupabasePostService() : MockPostService())
        self.chatService = chatService ?? (live ? SupabaseChatService() : MockChatService())
        self.userService = userService ?? (live ? SupabaseUserService() : MockUserService())
        self.notificationService = notificationService ?? (live ? SupabaseNotificationService() : MockNotificationService())
        self.storageService = storageService ?? (live ? SupabaseStorageService() : MockStorageService())
    }

    /// Convenience for mock/testing
    static func mock() -> DependencyContainer {
        DependencyContainer(
            authService: MockAuthService(),
            gatheringService: MockGatheringService(),
            postService: MockPostService(),
            chatService: MockChatService(),
            userService: MockUserService(),
            notificationService: MockNotificationService(),
            storageService: MockStorageService()
        )
    }
}
