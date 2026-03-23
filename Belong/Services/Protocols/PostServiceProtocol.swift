import Foundation

protocol PostServiceProtocol: Sendable {
    func fetchFeed(page: Int, filter: String?) async throws -> [Post]
    func fetchDetail(id: String) async throws -> Post
    func create(content: String, imageURLs: [URL], tags: [String], visibility: PostVisibility, linkedGatheringId: String?, city: String?, school: String?) async throws -> Post
    func delete(postId: String) async throws
    func toggleLike(postId: String) async throws -> (liked: Bool, count: Int)
    func toggleSave(postId: String) async throws -> Bool
    func fetchComments(postId: String, page: Int) async throws -> [PostComment]
    func addComment(postId: String, content: String, parentId: String?) async throws -> PostComment
    func deleteComment(commentId: String) async throws
    func fetchTrendingTags(query: String) async throws -> [String]
}
