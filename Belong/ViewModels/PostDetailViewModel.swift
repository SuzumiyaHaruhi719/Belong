import SwiftUI

@Observable @MainActor
final class PostDetailViewModel {
    // MARK: - State

    var post: Post?
    var comments: [PostComment] = []
    var isLoading = false
    var error: String?
    var newCommentText: String = ""
    var isPostingComment = false

    // MARK: - Dependencies

    private(set) var container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Actions

    func loadDetail(id: String) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            async let postRequest = container.postService.fetchDetail(id: id)
            async let commentsRequest = container.postService.fetchComments(postId: id, page: 1)
            let postResult = try await postRequest
            let commentsResult = try await commentsRequest
            post = postResult
            comments = commentsResult
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadComments() async {
        guard let postId = post?.id else { return }
        do {
            comments = try await container.postService.fetchComments(postId: postId, page: 1)
        } catch {
            // Keep existing comments on failure
        }
    }

    func toggleLike() {
        guard var current = post else { return }
        let wasLiked = current.isLiked
        let oldCount = current.likeCount
        current.isLiked.toggle()
        current.likeCount += wasLiked ? -1 : 1
        post = current
        Task {
            do {
                let result = try await container.postService.toggleLike(postId: current.id)
                post?.isLiked = result.liked
                post?.likeCount = result.count
            } catch {
                post?.isLiked = wasLiked
                post?.likeCount = oldCount
            }
        }
    }

    func toggleSave() {
        guard var current = post else { return }
        let wasSaved = current.isSaved
        current.isSaved.toggle()
        post = current
        Task {
            do {
                let saved = try await container.postService.toggleSave(postId: current.id)
                post?.isSaved = saved
            } catch {
                post?.isSaved = wasSaved
            }
        }
    }

    func addComment() async {
        guard let postId = post?.id, !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isPostingComment = true
        let text = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        newCommentText = ""
        do {
            let comment = try await container.postService.addComment(postId: postId, content: text, parentId: nil)
            comments.append(comment)
            post?.commentCount += 1
        } catch {
            newCommentText = text
        }
        isPostingComment = false
    }

    func deleteComment(id: String) {
        let index = comments.firstIndex(where: { $0.id == id })
        let removed = comments.first(where: { $0.id == id })
        comments.removeAll { $0.id == id }
        post?.commentCount -= 1
        Task {
            do {
                try await container.postService.deleteComment(commentId: id)
            } catch {
                if let removed, let idx = index {
                    comments.insert(removed, at: min(idx, comments.count))
                    post?.commentCount += 1
                }
            }
        }
    }
}
