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

    init(
        authService: any AuthServiceProtocol = MockAuthService(),
        gatheringService: any GatheringServiceProtocol = MockGatheringService(),
        postService: any PostServiceProtocol = MockPostService(),
        chatService: any ChatServiceProtocol = MockChatService(),
        userService: any UserServiceProtocol = MockUserService(),
        notificationService: any NotificationServiceProtocol = MockNotificationService(),
        storageService: any StorageServiceProtocol = MockStorageService()
    ) {
        self.authService = authService
        self.gatheringService = gatheringService
        self.postService = postService
        self.chatService = chatService
        self.userService = userService
        self.notificationService = notificationService
        self.storageService = storageService
    }
}
