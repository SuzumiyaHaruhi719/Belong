import SwiftUI

enum ProfileTab: String, CaseIterable {
    case posts = "Posts"
    case gatherings = "Gatherings"
}

@Observable @MainActor
final class ProfileViewModel {
    // MARK: - Dependencies
    private let userService: any UserServiceProtocol

    // MARK: - State
    var user: User?
    var myPosts: [Post] = []
    var myGatherings: [Gathering] = []
    var savedGatherings: [Gathering] = []
    var savedPosts: [Post] = []
    var followers: [User] = []
    var following: [User] = []
    var mutuals: [User] = []
    var blockedUsers: [User] = []
    var browseHistory: [BrowseHistoryEntry] = []
    var isLoading = false
    var error: String?
    var selectedProfileTab: ProfileTab = .posts

    init(userService: any UserServiceProtocol) {
        self.userService = userService
    }

    // MARK: - Load Profile

    func loadProfile() async {
        isLoading = true
        error = nil
        do {
            user = try await userService.fetchMyProfile()
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Posts & Gatherings

    func loadMyPosts() async {
        do {
            myPosts = try await userService.fetchMyPosts()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadMyGatherings() async {
        do {
            myGatherings = try await userService.fetchMyGatherings(role: nil)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Saved

    func loadSaved() async {
        do {
            async let gatheringsTask = userService.fetchSavedGatherings()
            async let postsTask = userService.fetchSavedPosts()
            savedGatherings = try await gatheringsTask
            savedPosts = try await postsTask
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Connections

    func loadFollowers() async {
        guard let userId = user?.id else { return }
        do {
            followers = try await userService.fetchFollowers(userId: userId, page: 0)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadFollowing() async {
        guard let userId = user?.id else { return }
        do {
            following = try await userService.fetchFollowing(userId: userId, page: 0)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadMutuals() async {
        do {
            mutuals = try await userService.fetchMutuals(page: 0)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadBlockedUsers() async {
        do {
            blockedUsers = try await userService.fetchBlockedUsers()
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - History

    func loadHistory() async {
        do {
            browseHistory = try await userService.fetchBrowseHistory(type: nil)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func clearHistory() async {
        do {
            try await userService.clearBrowseHistory()
            browseHistory = []
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Actions

    func removeSavedGathering(at offsets: IndexSet) {
        savedGatherings.remove(atOffsets: offsets)
    }

    func removeSavedPost(at offsets: IndexSet) {
        savedPosts.remove(atOffsets: offsets)
    }

    func followUser(_ userId: String) async {
        do {
            try await userService.follow(userId: userId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func unfollowUser(_ userId: String) async {
        do {
            try await userService.unfollow(userId: userId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func blockUser(_ userId: String) async {
        do {
            try await userService.block(userId: userId)
            await loadBlockedUsers()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func unblockUser(_ userId: String) async {
        do {
            try await userService.unblock(userId: userId)
            blockedUsers.removeAll { $0.id == userId }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
