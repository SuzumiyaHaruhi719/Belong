import SwiftUI

@Observable @MainActor
final class SettingsViewModel {
    // MARK: - Dependencies
    private let authService: any AuthServiceProtocol

    // MARK: - State
    var privacyProfile: PrivacyLevel = .publicProfile
    var privacyDM: DMPrivacy = .everyone
    var notificationsEnabled = true
    var showLogoutConfirm = false
    var showDeleteConfirm = false
    var isLoggingOut = false
    var isDeletingAccount = false
    var error: String?

    // Notification toggles
    var notifyLikes = true
    var notifyComments = true
    var notifyFollows = true
    var notifyMentions = true
    var notifyGatheringReminders = true
    var notifyNewPosts = true
    var notifyDMs = true

    init(authService: any AuthServiceProtocol) {
        self.authService = authService
    }

    func loadFromUser(_ user: User) {
        privacyProfile = user.privacyProfile
        privacyDM = user.privacyDM
        notificationsEnabled = user.notificationsEnabled
    }

    func logout() async {
        isLoggingOut = true
        do {
            try await authService.logout()
            isLoggingOut = false
        } catch {
            self.error = error.localizedDescription
            isLoggingOut = false
        }
    }

    func deleteAccount() async {
        isDeletingAccount = true
        do {
            // In production: call a delete account endpoint
            try await authService.logout()
            isDeletingAccount = false
        } catch {
            self.error = error.localizedDescription
            isDeletingAccount = false
        }
    }
}
