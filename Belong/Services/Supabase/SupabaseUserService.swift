import Foundation
import Supabase

@MainActor
final class SupabaseUserService: UserServiceProtocol {
    private let manager = SupabaseManager.shared

    func fetchMyProfile() async throws -> User {
        let userId = try manager.requireUserId()
        return try await fetchProfile(userId: userId)
    }

    func fetchProfile(userId: String) async throws -> User {
        let rows: [DBUser] = try await manager.client.from("users")
            .select()
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value
        guard let row = rows.first else { throw SupabaseServiceError.notFound }
        var user = mapUserRow(row)

        // Fetch counts in parallel
        async let followerCount = countRows("follows", column: "following_id", value: userId)
        async let followingCount = countRows("follows", column: "follower_id", value: userId)
        async let postCount = countRows("posts", column: "author_id", value: userId)
        async let hostedCount = countRows("gatherings", column: "host_id", value: userId)

        user.followerCount = try await followerCount
        user.followingCount = try await followingCount
        user.postCount = try await postCount
        user.gatheringsHosted = try await hostedCount
        return user
    }

    func updateProfile(displayName: String?, bio: String?, city: String?, school: String?) async throws -> User {
        let userId = try manager.requireUserId()
        let update = ProfileUpdate(
            displayName: displayName,
            bio: bio,
            city: city,
            school: school
        )
        try await manager.client.from("users")
            .update(update)
            .eq("id", value: userId)
            .execute()
        return try await fetchMyProfile()
    }

    func updateProfile(_ fields: [String: String]) async throws {
        let userId = try manager.requireUserId()
        guard !fields.isEmpty else { return }
        // For generic field updates, use ProfileFieldsUpdate
        let update = ProfileFieldsUpdate(fields: fields)
        try await manager.client.from("users")
            .update(update)
            .eq("id", value: userId)
            .execute()
    }

    func updateAvatar(imageData: Data) async throws -> URL {
        let userId = try manager.requireUserId()
        let path = "\(userId)/avatar-\(UUID().uuidString).jpg"
        try await manager.client.storage.from("avatars")
            .upload(path, data: imageData, options: .init(contentType: "image/jpeg", upsert: true))
        let publicURL = try manager.client.storage.from("avatars").getPublicURL(path: path)
        try await manager.client.from("users")
            .update(AvatarUrlUpdate(avatarUrl: publicURL.absoluteString))
            .eq("id", value: userId)
            .execute()
        return publicURL
    }

    func updateTags(_ tags: [UserTag]) async throws {
        let userId = try manager.requireUserId()
        // Delete existing tags
        try await manager.client.from("user_tags")
            .delete()
            .eq("user_id", value: userId)
            .execute()
        // Insert new tags
        if !tags.isEmpty {
            let rows = tags.map { tag in
                DBUserTag(id: UUID().uuidString, userId: userId, category: tag.category.rawValue, tagValue: tag.value)
            }
            try await manager.client.from("user_tags")
                .insert(rows)
                .execute()
        }
    }

    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let existing: [DBUser] = try await manager.client.from("users")
            .select("id")
            .eq("username", value: trimmed)
            .limit(1)
            .execute()
            .value
        return existing.isEmpty
    }

    func follow(userId: String) async throws {
        try await manager.client.rpc("toggle_user_follow", params: FollowParams(pTargetId: userId))
            .execute()
    }

    func unfollow(userId: String) async throws {
        // toggle_user_follow removes the follow if it exists
        try await manager.client.rpc("toggle_user_follow", params: FollowParams(pTargetId: userId))
            .execute()
    }

    func block(userId: String) async throws {
        try await manager.client.rpc("block_user", params: BlockUserParams(pTargetId: userId))
            .execute()
    }

    func unblock(userId: String) async throws {
        let myId = try manager.requireUserId()
        try await manager.client.from("blocks")
            .delete()
            .eq("blocker_id", value: myId)
            .eq("blocked_id", value: userId)
            .execute()
    }

    func fetchFollowers(userId: String, page: Int) async throws -> [User] {
        let rows: [FollowWithUser] = try await manager.client.from("follows")
            .select("follower_id, users!follows_follower_id_fkey(id, username, display_name, avatar_url, default_avatar_id)")
            .eq("following_id", value: userId)
            .range(from: page * 20, to: (page + 1) * 20 - 1)
            .execute()
            .value
        return rows.compactMap { $0.users }.map { mapUserRow($0) }
    }

    func fetchFollowing(userId: String, page: Int) async throws -> [User] {
        let rows: [FollowWithUser] = try await manager.client.from("follows")
            .select("following_id, users!follows_following_id_fkey(id, username, display_name, avatar_url, default_avatar_id)")
            .eq("follower_id", value: userId)
            .range(from: page * 20, to: (page + 1) * 20 - 1)
            .execute()
            .value
        return rows.compactMap { $0.users }.map { mapUserRow($0) }
    }

    func fetchMutuals(page: Int) async throws -> [User] {
        let myId = try manager.requireUserId()
        // Mutuals: I follow them AND they follow me
        let myFollowing: [FollowRow] = try await manager.client.from("follows")
            .select("following_id")
            .eq("follower_id", value: myId)
            .execute()
            .value
        let myFollowers: [FollowRow] = try await manager.client.from("follows")
            .select("follower_id")
            .eq("following_id", value: myId)
            .execute()
            .value
        let followingSet = Set(myFollowing.map(\.followingId))
        let followerSet = Set(myFollowers.map(\.followerId))
        let mutualIds = Array(followingSet.intersection(followerSet))
        guard !mutualIds.isEmpty else { return [] }

        let rows: [DBUser] = try await manager.client.from("users")
            .select()
            .in("id", values: mutualIds)
            .range(from: page * 20, to: (page + 1) * 20 - 1)
            .execute()
            .value
        return rows.map { mapUserRow($0) }
    }

    func fetchBlockedUsers() async throws -> [User] {
        let myId = try manager.requireUserId()
        let blocks: [BlockRow] = try await manager.client.from("blocks")
            .select("blocked_id")
            .eq("blocker_id", value: myId)
            .execute()
            .value
        let blockedIds = blocks.map(\.blockedId)
        guard !blockedIds.isEmpty else { return [] }
        let rows: [DBUser] = try await manager.client.from("users")
            .select()
            .in("id", values: blockedIds)
            .execute()
            .value
        return rows.map { mapUserRow($0) }
    }

    func fetchSavedGatherings() async throws -> [Gathering] {
        let myId = try manager.requireUserId()
        let members: [GatheringMemberWithGathering] = try await manager.client.from("gathering_members")
            .select("gathering_id, gatherings(*)")
            .eq("user_id", value: myId)
            .eq("status", value: "saved")
            .execute()
            .value
        return members.compactMap { $0.gatherings }.map { mapDBGathering($0, isBookmarked: true) }
    }

    func fetchSavedPosts() async throws -> [Post] {
        let myId = try manager.requireUserId()
        let saves: [PostSaveWithPost] = try await manager.client.from("post_saves")
            .select("post_id, posts(*, post_images(*), post_tags(tag_value))")
            .eq("user_id", value: myId)
            .execute()
            .value
        return saves.compactMap { $0.posts }.map { mapDBPost($0, isSaved: true) }
    }

    func fetchBrowseHistory(type: BrowseTargetType?) async throws -> [BrowseHistoryEntry] {
        let myId = try manager.requireUserId()
        var query = manager.client.from("browse_history")
            .select()
            .eq("user_id", value: myId)
        if let type {
            query = query.eq("target_type", value: type.rawValue)
        }
        let rows: [DBBrowseHistory] = try await query
            .order("viewed_at", ascending: false)
            .limit(50)
            .execute()
            .value
        return rows.map { row in
            BrowseHistoryEntry(
                id: row.id ?? UUID().uuidString,
                userId: row.userId ?? myId,
                targetType: BrowseTargetType(rawValue: row.targetType) ?? .post,
                targetId: row.targetId,
                viewedAt: parseSupabaseDate(row.viewedAt),
                title: "",
                imageURL: nil,
                subtitle: nil
            )
        }
    }

    func clearBrowseHistory() async throws {
        let myId = try manager.requireUserId()
        try await manager.client.from("browse_history")
            .delete()
            .eq("user_id", value: myId)
            .execute()
    }

    func fetchMyGatherings(role: String?) async throws -> [Gathering] {
        let myId = try manager.requireUserId()
        let members: [GatheringMemberWithGathering] = try await manager.client.from("gathering_members")
            .select("gathering_id, status, gatherings(*)")
            .eq("user_id", value: myId)
            .eq("status", value: "joined")
            .execute()
            .value
        return members.compactMap { $0.gatherings }.map { mapDBGathering($0, isJoined: true) }
    }

    func fetchMyPosts() async throws -> [Post] {
        let myId = try manager.requireUserId()
        let rows: [PostRowWithRelations] = try await manager.client.from("posts")
            .select("*, post_images(*), post_tags(tag_value)")
            .eq("author_id", value: myId)
            .order("created_at", ascending: false)
            .execute()
            .value
        return rows.map { mapPostRowWithRelations($0) }
    }

    func fetchCities(query: String) async throws -> [String] {
        // For now, return common cities. In production, use a dedicated cities table.
        let cities = ["Melbourne", "Sydney", "Brisbane", "Perth", "Adelaide", "Canberra", "Hobart", "Darwin"]
        if query.isEmpty { return cities }
        return cities.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    func fetchSchools(city: String) async throws -> [String] {
        // Same approach - hardcode for now, could be a schools table later
        let schoolsByCity: [String: [String]] = [
            "Melbourne": ["University of Melbourne", "Monash University", "RMIT University", "Deakin University", "La Trobe University", "Swinburne University of Technology"],
            "Sydney": ["University of Sydney", "UNSW Sydney", "Macquarie University", "UTS"],
            "Brisbane": ["University of Queensland", "QUT", "Griffith University"],
            "Perth": ["University of Western Australia", "Curtin University"],
            "Adelaide": ["University of Adelaide", "Flinders University"],
            "Canberra": ["Australian National University", "University of Canberra"],
        ]
        return schoolsByCity[city] ?? []
    }

    func fetchTagPresets(category: TagCategory) async throws -> [String] {
        switch category {
        case .culturalBackground:
            return ["Chinese", "Indian", "Vietnamese", "Korean", "Filipino", "Thai", "Japanese", "Malaysian", "Indonesian", "Sri Lankan", "Nepalese", "Bangladeshi", "Pakistani", "African", "Middle Eastern", "European", "Latin American", "Pacific Islander"]
        case .language:
            return ["English", "Mandarin", "Hindi", "Vietnamese", "Korean", "Cantonese", "Japanese", "Tagalog", "Thai", "Malay", "Indonesian", "Arabic", "Spanish", "French", "Portuguese", "Nepali", "Sinhalese", "Tamil"]
        case .interestVibe:
            return ["Foodie", "Study buddy", "Nightlife", "Sports", "Music", "Art", "Gaming", "Travel", "Fitness", "Photography", "Cooking", "Reading", "Film", "Fashion", "Volunteering", "Entrepreneurship", "Tech", "Nature"]
        }
    }

    // MARK: - Helpers

    private func countRows(_ table: String, column: String, value: String) async throws -> Int {
        let rows: [CountRow] = try await manager.client.from(table)
            .select(column, head: false)
            .eq(column, value: value)
            .execute()
            .value
        return rows.count
    }
}

// MARK: - Helper DTOs for joins

private struct FollowWithUser: Codable {
    var users: DBUser?
}

private struct FollowRow: Codable {
    var followerId: String?
    var followingId: String?
    enum CodingKeys: String, CodingKey {
        case followerId = "follower_id"
        case followingId = "following_id"
    }
}

private struct BlockRow: Codable {
    var blockedId: String
    enum CodingKeys: String, CodingKey {
        case blockedId = "blocked_id"
    }
}

private struct GatheringMemberWithGathering: Codable {
    var gatherings: DBGathering?
}

private struct PostSaveWithPost: Codable {
    var posts: PostRowWithRelations?
}

nonisolated struct CountRow: Codable, Sendable {
    // Generic row for counting - accepts any single column
    init(from decoder: Decoder) throws {
        // Just needs to decode successfully; we only care about array count
    }
}

// MARK: - Post/Gathering Mapping Helpers

struct PostRowWithRelations: Codable {
    var id: String?
    var authorId: String?
    var content: String?
    var visibility: String?
    var linkedGatheringId: String?
    var city: String?
    var school: String?
    var likeCount: Int?
    var commentCount: Int?
    var saveCount: Int?
    var createdAt: String?
    var postImages: [DBPostImage]?
    var postTags: [DBPostTag]?

    enum CodingKeys: String, CodingKey {
        case id, content, visibility, city, school
        case authorId = "author_id"
        case linkedGatheringId = "linked_gathering_id"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case saveCount = "save_count"
        case createdAt = "created_at"
        case postImages = "post_images"
        case postTags = "post_tags"
    }
}

// MARK: - RPC Feed Response DTO (matches get_posts_feed JSON shape)
nonisolated struct PostFeedRPCRow: Codable, Sendable {
    var id: String?
    var authorId: String?
    var authorName: String?
    var authorUsername: String?
    var authorAvatar: String?
    var content: String?
    var imageUrls: [String]?
    var tags: [String]?
    var likeCount: Int?
    var commentCount: Int?
    var isLiked: Bool?
    var isSaved: Bool?
    var linkedGatheringId: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, content, tags
        case authorId = "author_id"
        case authorName = "author_name"
        case authorUsername = "author_username"
        case authorAvatar = "author_avatar"
        case imageUrls = "image_urls"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case isLiked = "is_liked"
        case isSaved = "is_saved"
        case linkedGatheringId = "linked_gathering_id"
        case createdAt = "created_at"
    }
}

func mapPostFeedRPCRow(_ row: PostFeedRPCRow) -> Post {
    let imgURLs = (row.imageUrls ?? []).compactMap { URL(string: $0) }
    return Post(
        id: row.id ?? UUID().uuidString,
        authorId: row.authorId ?? "",
        content: row.content ?? "",
        images: imgURLs.enumerated().map { idx, url in
            PostImage(id: UUID().uuidString, postId: row.id ?? "", imageURL: url, displayOrder: idx, width: nil, height: nil)
        },
        tags: row.tags ?? [],
        visibility: .publicPost,
        linkedGatheringId: row.linkedGatheringId,
        city: "",
        school: nil,
        likeCount: row.likeCount ?? 0,
        commentCount: row.commentCount ?? 0,
        saveCount: 0,
        isLiked: row.isLiked ?? false,
        isSaved: row.isSaved ?? false,
        createdAt: parseSupabaseDate(row.createdAt),
        authorName: row.authorName ?? "",
        authorUsername: row.authorUsername ?? "",
        authorAvatarURL: row.authorAvatar.flatMap { URL(string: $0) },
        authorAvatarEmoji: "🙂",
        linkedGatheringTitle: nil
    )
}

func mapPostRowWithRelations(_ row: PostRowWithRelations, isLiked: Bool = false, isSaved: Bool = false) -> Post {
    Post(
        id: row.id ?? UUID().uuidString,
        authorId: row.authorId ?? "",
        content: row.content ?? "",
        images: (row.postImages ?? []).map { img in
            PostImage(
                id: img.id ?? UUID().uuidString,
                postId: row.id ?? "",
                imageURL: URL(string: img.imageUrl) ?? URL(string: "https://picsum.photos/400")!,
                displayOrder: img.displayOrder,
                width: img.width,
                height: img.height
            )
        },
        tags: (row.postTags ?? []).map(\.tagValue),
        visibility: PostVisibility(rawValue: row.visibility ?? "public") ?? .publicPost,
        linkedGatheringId: row.linkedGatheringId,
        city: row.city ?? "",
        school: row.school,
        likeCount: row.likeCount ?? 0,
        commentCount: row.commentCount ?? 0,
        saveCount: row.saveCount ?? 0,
        isLiked: isLiked,
        isSaved: isSaved,
        createdAt: parseSupabaseDate(row.createdAt),
        authorName: "",
        authorUsername: "",
        authorAvatarURL: nil,
        authorAvatarEmoji: "🙂",
        linkedGatheringTitle: nil
    )
}

func mapDBPost(_ row: PostRowWithRelations, isLiked: Bool = false, isSaved: Bool = false) -> Post {
    mapPostRowWithRelations(row, isLiked: isLiked, isSaved: isSaved)
}

func mapDBGathering(_ row: DBGathering, isBookmarked: Bool = false, isJoined: Bool = false, isMaybe: Bool = false) -> Gathering {
    Gathering(
        id: row.id ?? UUID().uuidString,
        hostId: row.hostId ?? "",
        title: row.title ?? "",
        description: row.description ?? "",
        templateType: GatheringTemplate(rawValue: row.templateType ?? "hangout") ?? .hangout,
        emoji: row.emoji ?? "🤝",
        imageURL: row.imageUrl.flatMap { URL(string: $0) },
        city: row.city ?? "",
        school: row.school,
        locationName: row.locationName ?? "",
        latitude: row.latitude,
        longitude: row.longitude,
        startsAt: parseSupabaseDate(row.startsAt),
        endsAt: row.endsAt.map { parseSupabaseDate($0) },
        maxAttendees: row.maxAttendees ?? 10,
        visibility: GatheringVisibility(rawValue: row.visibility ?? "open") ?? .open,
        vibe: GatheringVibe(rawValue: row.vibe ?? "welcoming") ?? .welcoming,
        status: GatheringStatus(rawValue: row.status ?? "upcoming") ?? .upcoming,
        isDraft: row.isDraft ?? false,
        tags: [],
        attendeeCount: 0,
        attendeeAvatars: [],
        hostName: "",
        hostAvatarEmoji: "🙂",
        hostRating: 4.5,
        isBookmarked: isBookmarked,
        isJoined: isJoined,
        isMaybe: isMaybe,
        createdAt: parseSupabaseDate(row.createdAt)
    )
}
