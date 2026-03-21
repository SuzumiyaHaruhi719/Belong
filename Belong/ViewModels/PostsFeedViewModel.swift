import SwiftUI

@Observable @MainActor
final class PostsFeedViewModel {
    // MARK: - State

    var posts: [Post] = []
    var isLoading = false
    var error: String?
    var page: Int = 1
    var selectedFilter: String? = nil
    var isLoadingMore = false

    var filterOptions: [String] {
        ["Following", "Nearby"] + trendingTags
    }

    /// Bridges the optional selectedFilter to the "All" / tag string that FilterChipRow expects.
    var selectedFilterBinding: String {
        get { selectedFilter ?? "All" }
        set { selectedFilter = newValue == "All" ? nil : newValue }
    }

    private var trendingTags: [String] = []
    private var hasMorePages = true

    // MARK: - Dependencies

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Actions

    func loadFeed() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        page = 1
        hasMorePages = true
        do {
            async let feedRequest = container.postService.fetchFeed(page: 1, filter: selectedFilter)
            async let tagsRequest = container.postService.fetchTrendingTags(query: "")
            let feedResult = try await feedRequest
            let tagsResult = try await tagsRequest
            posts = feedResult
            trendingTags = tagsResult
            hasMorePages = !feedResult.isEmpty
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore, !isLoading, hasMorePages else { return }
        isLoadingMore = true
        let nextPage = page + 1
        do {
            let newPosts = try await container.postService.fetchFeed(page: nextPage, filter: selectedFilter)
            if newPosts.isEmpty {
                hasMorePages = false
            } else {
                posts.append(contentsOf: newPosts)
                page = nextPage
            }
        } catch {
            // Silently fail pagination; user can scroll again
        }
        isLoadingMore = false
    }

    func refresh() async {
        await loadFeed()
    }

    func toggleLike(postId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        let wasLiked = posts[index].isLiked
        let oldCount = posts[index].likeCount
        posts[index].isLiked.toggle()
        posts[index].likeCount += wasLiked ? -1 : 1
        Task {
            do {
                let result = try await container.postService.toggleLike(postId: postId)
                if let idx = posts.firstIndex(where: { $0.id == postId }) {
                    posts[idx].isLiked = result.liked
                    posts[idx].likeCount = result.count
                }
            } catch {
                if let idx = posts.firstIndex(where: { $0.id == postId }) {
                    posts[idx].isLiked = wasLiked
                    posts[idx].likeCount = oldCount
                }
            }
        }
    }

    func toggleSave(postId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        let wasSaved = posts[index].isSaved
        posts[index].isSaved.toggle()
        Task {
            do {
                let saved = try await container.postService.toggleSave(postId: postId)
                if let idx = posts.firstIndex(where: { $0.id == postId }) {
                    posts[idx].isSaved = saved
                }
            } catch {
                if let idx = posts.firstIndex(where: { $0.id == postId }) {
                    posts[idx].isSaved = wasSaved
                }
            }
        }
    }
}
