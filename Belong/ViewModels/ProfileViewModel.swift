import SwiftUI

enum ProfileTab: String, CaseIterable {
    case posts = "Posts"
    case gatherings = "Gatherings"
}

@Observable @MainActor
final class ProfileViewModel {
    // MARK: - Dependencies
    private let userService: any UserServiceProtocol
    var storageService: (any StorageServiceProtocol)?
    var gatheringService: (any GatheringServiceProtocol)?
    var postService: (any PostServiceProtocol)?

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

    // Image upload states
    var avatarUploadState: ImageUploadOverlay.UploadState = .idle
    var backgroundUploadState: ImageUploadOverlay.UploadState = .idle
    var selectedAvatarImage: UIImage?
    var selectedBackgroundImage: UIImage?

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

    func loadUserProfile(userId: String) async {
        isLoading = true
        error = nil
        do {
            user = try await userService.fetchProfile(userId: userId)
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

    // MARK: - Avatar Upload

    func uploadAvatar(_ image: UIImage) {
        selectedAvatarImage = image
        Task { await performAvatarUpload(image) }
    }

    private func performAvatarUpload(_ image: UIImage) async {
        guard let storage = storageService, let userId = user?.id else { return }
        avatarUploadState = .uploading
        do {
            let path = "\(userId)/avatar.jpg"
            let result = try await storage.uploadImage(image, bucket: .avatars, path: path)
            // Update user profile with new avatar URL
            try await userService.updateProfile(["avatar_url": result.publicURL.absoluteString])
            user?.avatarURL = result.publicURL
            avatarUploadState = .success
            try? await Task.sleep(for: .seconds(1.5))
            avatarUploadState = .idle
        } catch {
            avatarUploadState = .error("Upload failed")
        }
    }

    // MARK: - Background Upload

    func uploadBackground(_ image: UIImage) {
        selectedBackgroundImage = image
        Task { await performBackgroundUpload(image) }
    }

    private func performBackgroundUpload(_ image: UIImage) async {
        guard let storage = storageService, let userId = user?.id else { return }
        backgroundUploadState = .uploading
        do {
            let path = "\(userId)/background.jpg"
            let result = try await storage.uploadImage(image, bucket: .profileBackgrounds, path: path)
            // Update user profile with new background URL
            try await userService.updateProfile(["profile_background_url": result.publicURL.absoluteString])
            user?.profileBackgroundURL = result.publicURL
            backgroundUploadState = .success
            try? await Task.sleep(for: .seconds(1.5))
            backgroundUploadState = .idle
        } catch {
            backgroundUploadState = .error("Upload failed")
        }
    }

    // MARK: - Actions

    func removeSavedGathering(at offsets: IndexSet) {
        let itemsToRemove = offsets.map { savedGatherings[$0] }
        savedGatherings.remove(atOffsets: offsets)
        // Persist unsave to backend
        Task {
            for gathering in itemsToRemove {
                do {
                    try await gatheringService?.unsave(gatheringId: gathering.id)
                } catch {
                    // Revert on failure — add back and show error
                    savedGatherings.append(contentsOf: itemsToRemove)
                    self.error = "Failed to unsave gathering"
                    return
                }
            }
        }
    }

    func removeSavedPost(at offsets: IndexSet) {
        let itemsToRemove = offsets.map { savedPosts[$0] }
        savedPosts.remove(atOffsets: offsets)
        // Persist unsave to backend
        Task {
            for post in itemsToRemove {
                do {
                    _ = try await postService?.toggleSave(postId: post.id)
                } catch {
                    // Revert on failure
                    savedPosts.append(contentsOf: itemsToRemove)
                    self.error = "Failed to unsave post"
                    return
                }
            }
        }
    }

    func followUser(_ userId: String) async {
        do {
            try await userService.follow(userId: userId)
            // Update local state: move from followers to mutuals if applicable
            if let idx = followers.firstIndex(where: { $0.id == userId }) {
                let user = followers[idx]
                if !following.contains(where: { $0.id == userId }) {
                    following.append(user)
                }
            }
            // Refresh profile to update counts (followingCount, mutualCount)
            await loadProfile()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func unfollowUser(_ userId: String) async {
        do {
            try await userService.unfollow(userId: userId)
            // Update local state
            following.removeAll { $0.id == userId }
            mutuals.removeAll { $0.id == userId }
            // Refresh profile to update counts
            await loadProfile()
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
