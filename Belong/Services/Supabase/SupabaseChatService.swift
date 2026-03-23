import Foundation
import Supabase

@MainActor
final class SupabaseChatService: ChatServiceProtocol {
    private let manager = SupabaseManager.shared

    func fetchConversations() async throws -> [Conversation] {
        let myId = try manager.requireUserId()

        // Get conversation IDs I'm a member of
        let memberships: [DBConversationMember] = try await manager.client.from("conversation_members")
            .select()
            .eq("user_id", value: myId)
            .execute()
            .value
        let convIds = memberships.compactMap(\.conversationId)
        guard !convIds.isEmpty else { return [] }

        // Fetch conversations
        let convRows: [DBConversation] = try await manager.client.from("conversations")
            .select()
            .in("id", values: convIds)
            .order("updated_at", ascending: false)
            .execute()
            .value

        // Fetch all members for these conversations
        let allMembers: [DBConversationMember] = try await manager.client.from("conversation_members")
            .select()
            .in("conversation_id", values: convIds)
            .execute()
            .value

        // Fetch user info for members
        let allUserIds = Array(Set(allMembers.compactMap(\.userId)))
        guard !allUserIds.isEmpty else { return [] }
        let users: [DBUser] = try await manager.client.from("users")
            .select("id, display_name, username, avatar_url, default_avatar_id")
            .in("id", values: allUserIds)
            .execute()
            .value
        let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })

        // Fetch last message for each conversation
        var lastMessages: [String: DBMessage] = [:]
        for convId in convIds {
            let msgs: [DBMessage] = try await manager.client.from("messages")
                .select()
                .eq("conversation_id", value: convId)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            if let msg = msgs.first {
                lastMessages[convId] = msg
            }
        }

        // Count unread messages per conversation
        var unreadCounts: [String: Int] = [:]
        for convId in convIds {
            let myMember = memberships.first { ($0.conversationId ?? "") == convId }
            let lastRead = myMember?.lastReadAt
            var query = manager.client.from("messages")
                .select("id", head: false, count: .exact)
                .eq("conversation_id", value: convId)
                .neq("sender_id", value: myId)
            if let lastRead {
                query = query.gt("created_at", value: lastRead)
            }
            let response = try await query.execute()
            unreadCounts[convId] = response.count ?? 0
        }

        // Check mutual follows for DMs
        let myFollowing: [FollowIdRow] = try await manager.client.from("follows")
            .select("following_id")
            .eq("follower_id", value: myId)
            .execute()
            .value
        let myFollowers: [FollowIdRow] = try await manager.client.from("follows")
            .select("follower_id")
            .eq("following_id", value: myId)
            .execute()
            .value
        let followingSet = Set(myFollowing.compactMap(\.followingId))
        let followerSet = Set(myFollowers.compactMap(\.followerId))
        let mutualIds = followingSet.intersection(followerSet)

        return convRows.map { conv in
            let convMembers = allMembers.filter { ($0.conversationId ?? "") == (conv.id ?? "") }
            let memberInfos = convMembers.map { m in
                let uid = m.userId ?? ""
                let user = userMap[uid]
                return ConversationMemberInfo(
                    userId: uid,
                    displayName: user?.displayName ?? user?.username ?? "User",
                    avatarEmoji: "🙂",
                    avatarURL: user?.avatarUrl.flatMap { URL(string: $0) }
                )
            }
            let lastMsg = lastMessages[conv.id ?? ""]
            let otherMember = convMembers.first { ($0.userId ?? "") != myId }
            let isMutual = otherMember.map { mutualIds.contains($0.userId ?? "") } ?? false

            // Calculate unread count from unreadCounts dict
            let myMembership = convMembers.first { ($0.userId ?? "") == myId }
            let unread = unreadCounts[conv.id ?? ""] ?? 0

            return Conversation(
                id: conv.id ?? "",
                type: ConversationType(rawValue: conv.type ?? "dm") ?? .dm,
                gatheringId: conv.gatheringId,
                title: nil,
                lastMessageText: lastMsg?.content,
                lastMessageAt: lastMsg?.createdAt.map { parseSupabaseDate($0) },
                unreadCount: unread,
                members: memberInfos,
                createdAt: parseSupabaseDate(conv.createdAt),
                isMutualFollow: isMutual
            )
        }
    }

    func fetchMessages(conversationId: String, page: Int) async throws -> [Message] {
        let myId = manager.currentUserId ?? ""
        let rows: [DBMessage] = try await manager.client.from("messages")
            .select()
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: true)
            .range(from: (page - 1) * 50, to: page * 50 - 1)
            .execute()
            .value

        // Fetch sender info
        let senderIds = Array(Set(rows.compactMap(\.senderId)))
        var senderMap: [String: DBUser] = [:]
        if !senderIds.isEmpty {
            let senders: [DBUser] = try await manager.client.from("users")
                .select("id, display_name, username, avatar_url")
                .in("id", values: senderIds)
                .execute()
                .value
            senderMap = Dictionary(uniqueKeysWithValues: senders.map { ($0.id, $0) })
        }

        // Mark as read
        try? await markAsRead(conversationId: conversationId)

        return rows.map { row in
            let sender = senderMap[row.senderId ?? ""]
            return Message(
                id: row.id ?? UUID().uuidString,
                conversationId: conversationId,
                senderId: row.senderId ?? "",
                content: row.content,
                imageURL: row.imageUrl.flatMap { URL(string: $0) },
                sharedPostId: row.sharedPostId,
                messageType: MessageType(rawValue: row.messageType ?? "text") ?? .text,
                reactions: [],
                replyTo: nil,
                status: .delivered,
                createdAt: parseSupabaseDate(row.createdAt),
                senderName: sender?.displayName ?? sender?.username ?? "User",
                senderAvatarEmoji: "🙂",
                isCurrentUser: row.senderId == myId,
                sharedPostPreview: nil
            )
        }
    }

    func sendMessage(conversationId: String, content: String?, imageURL: URL?, sharedPostId: String?) async throws -> Message {
        let result: DBMessage = try await manager.client
            .rpc("send_dm_message", params: SendDmParams(
                pConversationId: conversationId,
                pContent: content,
                pImageUrl: imageURL?.absoluteString,
                pSharedPostId: sharedPostId
            ))
            .execute()
            .value

        let myId = manager.currentUserId ?? ""
        let msgType: MessageType
        if imageURL != nil { msgType = .image }
        else if sharedPostId != nil { msgType = .sharedPost }
        else { msgType = .text }

        return Message(
            id: result.id ?? UUID().uuidString,
            conversationId: conversationId,
            senderId: myId,
            content: content,
            imageURL: imageURL,
            sharedPostId: sharedPostId,
            messageType: msgType,
            reactions: [],
            replyTo: nil,
            status: .sent,
            createdAt: Date(),
            senderName: "You",
            senderAvatarEmoji: "🙂",
            isCurrentUser: true,
            sharedPostPreview: nil
        )
    }

    func createDMConversation(with userId: String) async throws -> Conversation {
        let result: DBConversation = try await manager.client
            .rpc("create_or_get_dm", params: CreateDmParams(pOtherUserId: userId))
            .execute()
            .value

        // Fetch the full conversation
        let conversations = try await fetchConversations()
        return conversations.first { $0.id == (result.id ?? "") } ?? Conversation(
            id: result.id ?? UUID().uuidString,
            type: .dm,
            gatheringId: nil,
            title: nil,
            lastMessageText: nil,
            lastMessageAt: nil,
            unreadCount: 0,
            members: [],
            createdAt: Date(),
            isMutualFollow: false
        )
    }

    func markAsRead(conversationId: String) async throws {
        let myId = try manager.requireUserId()
        try await manager.client.from("conversation_members")
            .update(LastReadAtUpdate(lastReadAt: formatSupabaseDate(Date())))
            .eq("conversation_id", value: conversationId)
            .eq("user_id", value: myId)
            .execute()
    }

    func fetchGatheringChat(gatheringId: String) async throws -> Conversation? {
        let rows: [DBConversation] = try await manager.client.from("conversations")
            .select()
            .eq("gathering_id", value: gatheringId)
            .limit(1)
            .execute()
            .value
        guard let row = rows.first else { return nil }
        let conversations = try await fetchConversations()
        return conversations.first { $0.id == (row.id ?? "") }
    }

    func searchUsers(query: String) async throws -> [User] {
        let rows: [DBUser] = try await manager.client.from("users")
            .select()
            .or("username.ilike.%\(query)%,display_name.ilike.%\(query)%")
            .limit(20)
            .execute()
            .value
        return rows.map { mapUserRow($0) }
    }
}

// MARK: - Helper DTOs

private struct FollowIdRow: Codable {
    var followingId: String?
    var followerId: String?

    enum CodingKeys: String, CodingKey {
        case followingId = "following_id"
        case followerId = "follower_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        followingId = try? container.decode(String.self, forKey: .followingId)
        followerId = try? container.decode(String.self, forKey: .followerId)
    }
}
