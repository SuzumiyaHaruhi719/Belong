import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let authorId: String
    var content: String
    var images: [PostImage]
    var tags: [String]  // hashtags without #
    var visibility: PostVisibility
    var linkedGatheringId: String?
    var city: String
    var school: String?
    var likeCount: Int
    var commentCount: Int
    var saveCount: Int
    var isLiked: Bool
    var isSaved: Bool
    let createdAt: Date
    // Denormalized
    var authorName: String
    var authorUsername: String
    var authorAvatarURL: URL?
    var authorAvatarEmoji: String
    var linkedGatheringTitle: String?

    var coverImage: PostImage? { images.sorted(by: { $0.displayOrder < $1.displayOrder }).first }
}

enum PostVisibility: String, Codable, CaseIterable {
    case publicPost = "public"
    case schoolOnly = "school_only"
    case followersOnly = "followers_only"
}
