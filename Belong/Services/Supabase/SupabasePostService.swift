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

    func create(content: String, imageURLs: [URL], tags: [String], visibility: PostVisibility, linkedGatheringId: String?, city: String? = nil, school: String? = nil) async throws -> Post {
        // Atomic RPC: creates post + images + tags in one transaction
        let params = CreatePostWithTagsParams(
            pContent: content,
            pVisibility: visibility.rawValue,
            pImageUrls: imageURLs.map { $0.absoluteString },
            pTags: tags,
            pCity: city,
            pSchool: school,
            pLinkedGatheringId: linkedGatheringId
        )
        let result: CreatePostResult = try await manager.client
            .rpc("create_post_with_tags", params: params)
            .execute()
            .value

        return try await fetchDetail(id: result.postId)
    }

    func delete(postId: String) async throws {
        try await manager.client.from("posts")
            .delete()
            .eq("id", value: postId)
            .execute()
    }

    func toggleLike(postId: String) async throws -> (liked: Bool, count: Int) {
        // The RPC returns {"liked": bool, "like_count": int} — use it directly
        let result: ToggleLikeResult = try await manager.client
            .rpc("toggle_post_like", params: ToggleLikeParams(pPostId: postId))
            .execute()
            .value
        return (liked: result.liked, count: result.likeCount)
    }

    func toggleSave(postId: String) async throws -> Bool {
        // Atomic RPC: toggle save + recount save_count in one call
        let result: ToggleSaveResult = try await manager.client
            .rpc("toggle_post_save", params: ToggleSaveParams(pPostId: postId))
            .execute()
            .value
        return result.saved
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
        // RPC returns {"comment_id": "uuid"} — decode as lightweight result
        let result: AddCommentResult = try await manager.client
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
            id: result.commentId,
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

private struct AddCommentResult: Codable {
    let commentId: String
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
    }
}

private struct ToggleLikeResult: Codable {
    let liked: Bool
    let likeCount: Int
    enum CodingKeys: String, CodingKey {
        case liked
        case likeCount = "like_count"
    }
}

private struct ToggleSaveResult: Codable {
    let saved: Bool
    let saveCount: Int
    enum CodingKeys: String, CodingKey {
        case saved
        case saveCount = "save_count"
    }
}

private struct CreatePostResult: Codable {
    let postId: String
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
    }
}

private struct PostLikeRow: Codable {
    let postId: String
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
    }
}

private struct PostSaveRow: Codable {
    let postId: String
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
    }
}
