import Foundation
import Supabase

@MainActor
final class SupabasePostService: PostServiceProtocol {
    private let manager = SupabaseManager.shared

    func fetchFeed(page: Int, filter: String?) async throws -> [Post] {
        // The RPC returns scored, enriched JSON with author info + like/save state included
        let result: [PostFeedRPCRow] = try await manager.client
            .rpc("get_posts_feed", params: GetPostsFeedParams(pPage: page, pLimit: 20, pFilterTag: filter))
            .execute()
            .value
        return result.map { mapPostFeedRPCRow($0) }
    }

    func fetchDetail(id: String) async throws -> Post {
        let rows: [PostRowWithRelations] = try await manager.client.from("posts")
            .select("*, post_images(*), post_tags(tag_value)")
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        guard let row = rows.first else { throw SupabaseServiceError.notFound }
        var post = mapPostRowWithRelations(row)

        // Fetch author info
        if let authorRows: [DBUser] = try? await manager.client.from("users")
            .select("id, display_name, username, avatar_url, default_avatar_id")
            .eq("id", value: post.authorId)
            .limit(1)
            .execute()
            .value,
           let author = authorRows.first {
            post.authorName = author.displayName ?? author.username ?? ""
            post.authorUsername = author.username ?? ""
            post.authorAvatarURL = author.avatarUrl.flatMap { URL(string: $0) }
        }

        // Check like/save state
        if let myId = manager.currentUserId {
            let likes: [PostLikeRow] = try await manager.client.from("post_likes")
                .select("post_id")
                .eq("user_id", value: myId)
                .eq("post_id", value: id)
                .execute()
                .value
            post.isLiked = !likes.isEmpty

            let saves: [PostSaveRow] = try await manager.client.from("post_saves")
                .select("post_id")
                .eq("user_id", value: myId)
                .eq("post_id", value: id)
                .execute()
                .value
            post.isSaved = !saves.isEmpty
        }

        return post
    }

    func create(content: String, imageURLs: [URL], tags: [String], visibility: PostVisibility, linkedGatheringId: String?) async throws -> Post {
        let myId = try manager.requireUserId()
        let postId = UUID().uuidString.lowercased()

        // 1. Insert post
        let postRow = DBPost(
            id: postId,
            authorId: myId,
            content: content,
            visibility: visibility.rawValue,
            linkedGatheringId: linkedGatheringId,
            city: nil, school: nil,
            likeCount: 0, commentCount: 0, saveCount: 0,
            createdAt: nil
        )
        try await manager.client.from("posts")
            .insert(postRow)
            .execute()

        // 2. Insert images
        if !imageURLs.isEmpty {
            let imageRows = imageURLs.enumerated().map { idx, url in
                DBPostImage(id: UUID().uuidString.lowercased(), postId: postId, imageUrl: url.absoluteString, displayOrder: idx, width: nil, height: nil)
            }
            try await manager.client.from("post_images")
                .insert(imageRows)
                .execute()
        }

        // 3. Insert tags
        if !tags.isEmpty {
            let tagRows = tags.map { DBPostTag(postId: postId, tagValue: $0) }
            try await manager.client.from("post_tags")
                .insert(tagRows)
                .execute()
        }

        return try await fetchDetail(id: postId)
    }

    func delete(postId: String) async throws {
        try await manager.client.from("posts")
            .delete()
            .eq("id", value: postId)
            .execute()
    }

    func toggleLike(postId: String) async throws -> (liked: Bool, count: Int) {
        try await manager.client.rpc("toggle_post_like", params: ToggleLikeParams(pPostId: postId))
            .execute()

        // Fetch current state
        let myId = try manager.requireUserId()
        let likes: [PostLikeRow] = try await manager.client.from("post_likes")
            .select("post_id")
            .eq("user_id", value: myId)
            .eq("post_id", value: postId)
            .execute()
            .value
        let isLiked = !likes.isEmpty

        let posts: [DBPost] = try await manager.client.from("posts")
            .select()
            .eq("id", value: postId)
            .limit(1)
            .execute()
            .value
        let count = posts.first?.likeCount ?? 0

        return (liked: isLiked, count: count)
    }

    func toggleSave(postId: String) async throws -> Bool {
        let myId = try manager.requireUserId()

        // Check if already saved
        let existing: [PostSaveRow] = try await manager.client.from("post_saves")
            .select("post_id")
            .eq("user_id", value: myId)
            .eq("post_id", value: postId)
            .execute()
            .value

        if existing.isEmpty {
            // Save
            try await manager.client.from("post_saves")
                .insert(PostSaveRow(postId: postId, userId: myId))
                .execute()
            return true
        } else {
            // Unsave
            try await manager.client.from("post_saves")
                .delete()
                .eq("user_id", value: myId)
                .eq("post_id", value: postId)
                .execute()
            return false
        }
    }

    func fetchComments(postId: String, page: Int) async throws -> [PostComment] {
        let rows: [DBPostComment] = try await manager.client.from("post_comments")
            .select()
            .eq("post_id", value: postId)
            .order("created_at", ascending: true)
            .range(from: (page - 1) * 50, to: page * 50 - 1)
            .execute()
            .value

        // Fetch author info
        let authorIds = Array(Set(rows.map { $0.authorId ?? "" }.filter { !$0.isEmpty }))
        var authorMap: [String: DBUser] = [:]
        if !authorIds.isEmpty {
            let authors: [DBUser] = try await manager.client.from("users")
                .select("id, display_name, username, avatar_url, default_avatar_id")
                .in("id", values: authorIds)
                .execute()
                .value
            authorMap = Dictionary(uniqueKeysWithValues: authors.map { ($0.id, $0) })
        }

        return rows.map { row in
            let author = authorMap[row.authorId ?? ""]
            return PostComment(
                id: row.id ?? UUID().uuidString,
                postId: row.postId,
                authorId: row.authorId ?? "",
                content: row.content,
                parentCommentId: row.parentCommentId,
                likeCount: 0,
                isLiked: false,
                createdAt: parseSupabaseDate(row.createdAt),
                authorName: author?.displayName ?? author?.username ?? "User",
                authorUsername: author?.username ?? "",
                authorAvatarEmoji: "🙂",
                replies: nil
            )
        }
    }

    func addComment(postId: String, content: String, parentId: String?) async throws -> PostComment {
        let result: DBPostComment = try await manager.client
            .rpc("add_post_comment", params: AddCommentParams(pPostId: postId, pContent: content, pParentCommentId: parentId))
            .execute()
            .value
        let myId = manager.currentUserId ?? ""

        // Fetch user info
        let users: [DBUser] = try await manager.client.from("users")
            .select("id, display_name, username")
            .eq("id", value: myId)
            .limit(1)
            .execute()
            .value
        let user = users.first

        return PostComment(
            id: result.id ?? UUID().uuidString,
            postId: postId,
            authorId: myId,
            content: content,
            parentCommentId: parentId,
            likeCount: 0,
            isLiked: false,
            createdAt: Date(),
            authorName: user?.displayName ?? user?.username ?? "You",
            authorUsername: user?.username ?? "",
            authorAvatarEmoji: "🙂",
            replies: nil
        )
    }

    func deleteComment(commentId: String) async throws {
        try await manager.client.from("post_comments")
            .delete()
            .eq("id", value: commentId)
            .execute()
    }

    func fetchTrendingTags(query: String) async throws -> [String] {
        // Query most used tags — use full select to avoid decode crash
        let rows: [DBPostTag] = try await manager.client.from("post_tags")
            .select()
            .limit(50)
            .execute()
            .value
        let allTags = Array(Set(rows.map(\.tagValue)))
        if query.isEmpty { return Array(allTags.prefix(20)) }
        return allTags.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}

// MARK: - Helper DTOs

private struct PostLikeRow: Codable {
    let postId: String
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
    }
}

private struct PostSaveRow: Codable {
    let postId: String
    let userId: String?

    init(postId: String, userId: String? = nil) {
        self.postId = postId
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
    }
}
