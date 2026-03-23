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

    @discardableResult
    func logout() async -> Bool {
        isLoggingOut = true
        error = nil
        do {
            try await authService.logout()
            isLoggingOut = false
            return true
        } catch {
            self.error = error.localizedDescription
            isLoggingOut = false
            return false
        }
    }

    /// Call this to show the confirmation dialog first.
    func requestDeleteAccount() {
        showDeleteConfirm = true
    }

    /// Called after user confirms deletion in the confirmation dialog.
    @discardableResult
    func deleteAccount() async -> Bool {
        isDeletingAccount = true
        error = nil
        do {
            try await authService.deleteAccount()
            isDeletingAccount = false
            return true
        } catch {
            self.error = error.localizedDescription
            isDeletingAccount = false
            return false
        }
    }
}
