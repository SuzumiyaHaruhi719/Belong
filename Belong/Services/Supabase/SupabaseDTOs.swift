import Foundation

// MARK: - Database row DTOs (snake_case mapping to Supabase tables)

nonisolated struct DBUser: Codable, Sendable {
    let id: String
    var email: String?
    var emailVerified: Bool?
    var username: String?
    var displayName: String?
    var avatarUrl: String?
    var defaultAvatarId: Int?
    var bio: String?
    var city: String?
    var school: String?
    var appLanguage: String?
    var privacyProfile: String?
    var privacyDm: String?
    var notificationsEnabled: Bool?
    var profileBackgroundUrl: String?
    var createdAt: String?
    var updatedAt: String?
    var lastActiveAt: String?

    enum CodingKeys: String, CodingKey {
        case id, email, username, bio, city, school
        case emailVerified = "email_verified"
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case defaultAvatarId = "default_avatar_id"
        case appLanguage = "app_language"
        case privacyProfile = "privacy_profile"
        case privacyDm = "privacy_dm"
        case notificationsEnabled = "notifications_enabled"
        case profileBackgroundUrl = "profile_background_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastActiveAt = "last_active_at"
    }
}

nonisolated struct DBUserTag: Codable, Sendable {
    let id: String?
    let userId: String?
    var category: String
    var tagValue: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case category
        case tagValue = "tag_value"
    }
}

nonisolated struct DBGathering: Codable, Sendable {
    var id: String?
    var hostId: String?
    var title: String?
    var description: String?
    var templateType: String?
    var emoji: String?
    var imageUrl: String?
    var city: String?
    var school: String?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var startsAt: String?
    var endsAt: String?
    var maxAttendees: Int?
    var visibility: String?
    var vibe: String?
    var status: String?
    var isDraft: Bool?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, emoji, city, school, latitude, longitude, visibility, vibe, status
        case hostId = "host_id"
        case templateType = "template_type"
        case imageUrl = "image_url"
        case locationName = "location_name"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case maxAttendees = "max_attendees"
        case isDraft = "is_draft"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

nonisolated struct DBGatheringTag: Codable, Sendable {
    let gatheringId: String
    let tagValue: String

    enum CodingKeys: String, CodingKey {
        case gatheringId = "gathering_id"
        case tagValue = "tag_value"
    }
}

nonisolated struct DBGatheringMember: Codable, Sendable {
    var gatheringId: String?
    var userId: String?
    var status: String?
    var joinedAt: String?

    enum CodingKeys: String, CodingKey {
        case gatheringId = "gathering_id"
        case userId = "user_id"
        case status
        case joinedAt = "joined_at"
    }
}

nonisolated struct DBPost: Codable, Sendable {
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

    enum CodingKeys: String, CodingKey {
        case id, content, visibility, city, school
        case authorId = "author_id"
        case linkedGatheringId = "linked_gathering_id"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case saveCount = "save_count"
        case createdAt = "created_at"
    }
}

nonisolated struct DBPostImage: Codable, Sendable {
    var id: String?
    var postId: String?
    var imageUrl: String
    var displayOrder: Int
    var width: Int?
    var height: Int?

    enum CodingKeys: String, CodingKey {
        case id, width, height
        case postId = "post_id"
        case imageUrl = "image_url"
        case displayOrder = "display_order"
    }
}

nonisolated struct DBPostTag: Codable, Sendable {
    let postId: String
    let tagValue: String

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case tagValue = "tag_value"
    }
}

nonisolated struct DBPostComment: Codable, Sendable {
    var id: String?
    let postId: String
    var authorId: String?
    var content: String
    var parentCommentId: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, content
        case postId = "post_id"
        case authorId = "author_id"
        case parentCommentId = "parent_comment_id"
        case createdAt = "created_at"
    }
}

nonisolated struct DBConversation: Codable, Sendable {
    var id: String?
    var type: String?
    var gatheringId: String?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, type
        case gatheringId = "gathering_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

nonisolated struct DBConversationMember: Codable, Sendable {
    var conversationId: String?
    var userId: String?
    var lastReadAt: String?

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case userId = "user_id"
        case lastReadAt = "last_read_at"
    }
}

nonisolated struct DBMessage: Codable, Sendable {
    var id: String?
    var conversationId: String?
    var senderId: String?
    var content: String?
    var imageUrl: String?
    var sharedPostId: String?
    var messageType: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, content
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case imageUrl = "image_url"
        case sharedPostId = "shared_post_id"
        case messageType = "message_type"
        case createdAt = "created_at"
    }
}

nonisolated struct DBNotification: Codable, Sendable {
    let id: String
    let recipientId: String
    var actorId: String?
    var type: String
    var targetType: String?
    var targetId: String?
    var message: String?
    var isRead: Bool
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, type, message
        case recipientId = "recipient_id"
        case actorId = "actor_id"
        case targetType = "target_type"
        case targetId = "target_id"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

nonisolated struct DBBrowseHistory: Codable, Sendable {
    var id: String?
    var userId: String?
    var targetType: String
    var targetId: String
    var viewedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case targetType = "target_type"
        case targetId = "target_id"
        case viewedAt = "viewed_at"
    }
}

// MARK: - RPC Parameter Types

nonisolated struct PublishGatheringParams: Codable, Sendable {
    let pTitle: String
    let pDescription: String
    let pTemplateType: String
    let pEmoji: String
    let pImageUrl: String?
    let pCity: String
    let pSchool: String?
    let pLocationName: String
    let pLatitude: Double?
    let pLongitude: Double?
    let pStartsAt: String
    let pEndsAt: String?
    let pMaxAttendees: Int
    let pVisibility: String
    let pVibe: String
    let pTags: [String]
    let pIsDraft: Bool

    enum CodingKeys: String, CodingKey {
        case pTitle = "p_title"
        case pDescription = "p_description"
        case pTemplateType = "p_template_type"
        case pEmoji = "p_emoji"
        case pImageUrl = "p_image_url"
        case pCity = "p_city"
        case pSchool = "p_school"
        case pLocationName = "p_location_name"
        case pLatitude = "p_latitude"
        case pLongitude = "p_longitude"
        case pStartsAt = "p_starts_at"
        case pEndsAt = "p_ends_at"
        case pMaxAttendees = "p_max_attendees"
        case pVisibility = "p_visibility"
        case pVibe = "p_vibe"
        case pTags = "p_tags"
        case pIsDraft = "p_is_draft"
    }
}

nonisolated struct PublishGatheringResult: Codable, Sendable {
    let gatheringId: String

    enum CodingKeys: String, CodingKey {
        case gatheringId = "gathering_id"
    }
}

nonisolated struct ToggleLikeParams: Codable, Sendable {
    let pPostId: String

    enum CodingKeys: String, CodingKey {
        case pPostId = "p_post_id"
    }
}

nonisolated struct JoinGatheringParams: Codable, Sendable {
    let pGatheringId: String
    let pStatus: String

    enum CodingKeys: String, CodingKey {
        case pGatheringId = "p_gathering_id"
        case pStatus = "p_status"
    }
}

nonisolated struct SubmitFeedbackParams: Codable, Sendable {
    let pGatheringId: String
    let pEmojiRating: String
    let pRatingScore: Int

    enum CodingKeys: String, CodingKey {
        case pGatheringId = "p_gathering_id"
        case pEmojiRating = "p_emoji_rating"
        case pRatingScore = "p_rating_score"
    }
}

nonisolated struct AddCommentParams: Codable, Sendable {
    let pPostId: String
    let pContent: String
    let pParentCommentId: String?

    enum CodingKeys: String, CodingKey {
        case pPostId = "p_post_id"
        case pContent = "p_content"
        case pParentCommentId = "p_parent_comment_id"
    }
}

nonisolated struct SendDmParams: Codable, Sendable {
    let pConversationId: String
    let pContent: String?
    let pMessageType: String
    let pImageUrl: String?
    let pSharedPostId: String?

    enum CodingKeys: String, CodingKey {
        case pConversationId = "p_conversation_id"
        case pContent = "p_content"
        case pMessageType = "p_message_type"
        case pImageUrl = "p_image_url"
        case pSharedPostId = "p_shared_post_id"
    }
}

nonisolated struct CreateDmParams: Codable, Sendable {
    let pOtherUserId: String

    enum CodingKeys: String, CodingKey {
        case pOtherUserId = "p_other_user_id"
    }
}

nonisolated struct BlockUserParams: Codable, Sendable {
    let pTargetId: String

    enum CodingKeys: String, CodingKey {
        case pTargetId = "p_target_id"
    }
}

nonisolated struct FollowParams: Codable, Sendable {
    let pTargetId: String

    enum CodingKeys: String, CodingKey {
        case pTargetId = "p_target_id"
    }
}

nonisolated struct RecommendParams: Codable, Sendable {
    let pLimit: Int

    enum CodingKeys: String, CodingKey {
        case pLimit = "p_limit"
    }
}

nonisolated struct GetPostsFeedParams: Codable, Sendable {
    let pPage: Int
    let pLimit: Int
    let pFilterTag: String?

    enum CodingKeys: String, CodingKey {
        case pPage = "p_page"
        case pLimit = "p_limit"
        case pFilterTag = "p_filter_tag"
    }
}

// MARK: - Date Helpers

let supabaseDateFormatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()

let supabaseDateFormatterBasic: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
}()

func parseSupabaseDate(_ str: String?) -> Date {
    guard let str else { return Date() }
    return supabaseDateFormatter.date(from: str)
        ?? supabaseDateFormatterBasic.date(from: str)
        ?? Date()
}

func formatSupabaseDate(_ date: Date) -> String {
    supabaseDateFormatter.string(from: date)
}

nonisolated struct PublishDraftUpdate: Codable, Sendable {
    let isDraft: Bool
    let status: String

    enum CodingKeys: String, CodingKey {
        case isDraft = "is_draft"
        case status
    }
}

nonisolated struct StatusUpdate: Codable, Sendable {
    let status: String
}

nonisolated struct IsReadUpdate: Codable, Sendable {
    let isRead: Bool

    enum CodingKeys: String, CodingKey {
        case isRead = "is_read"
    }
}

nonisolated struct LastReadAtUpdate: Codable, Sendable {
    let lastReadAt: String

    enum CodingKeys: String, CodingKey {
        case lastReadAt = "last_read_at"
    }
}

nonisolated struct UsernameUpdate: Codable, Sendable {
    let username: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case username
        case displayName = "display_name"
    }
}

nonisolated struct ProfileUpdate: Codable, Sendable {
    let displayName: String?
    let bio: String?
    let city: String?
    let school: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case bio, city, school
    }
}

nonisolated struct ProfileFieldsUpdate: Codable, Sendable {
    private let data: [String: String]

    init(fields: [String: String]) {
        self.data = fields
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        data = try container.decode([String: String].self)
    }
}

nonisolated struct AvatarUrlUpdate: Codable, Sendable {
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}
