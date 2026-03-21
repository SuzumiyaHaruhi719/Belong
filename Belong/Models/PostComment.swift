import Foundation

struct PostComment: Identifiable, Codable, Hashable {
    let id: String
    let postId: String
    let authorId: String
    var content: String
    var parentCommentId: String?  // nil = top-level
    var likeCount: Int
    var isLiked: Bool
    let createdAt: Date
    // Denormalized
    var authorName: String
    var authorUsername: String
    var authorAvatarEmoji: String
    var replies: [PostComment]?
}
