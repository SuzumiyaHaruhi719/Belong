import Foundation

@MainActor
final class MockChatService: ChatServiceProtocol {
    private var conversations: [Conversation] = []
    private var messageStore: [String: [Message]] = [:]

    nonisolated init() {}

    private func ensureLoaded() {
        if conversations.isEmpty {
            conversations = SampleData.conversations
        }
    }

    nonisolated func fetchConversations() async throws -> [Conversation] {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            ensureLoaded()
            return conversations
        }
    }

    nonisolated func fetchMessages(conversationId: String, page: Int) async throws -> [Message] {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run {
            if let existing = messageStore[conversationId] {
                return existing
            }
            let messages = SampleData.messages(for: conversationId)
            messageStore[conversationId] = messages
            return messages
        }
    }

    nonisolated func sendMessage(conversationId: String, content: String?, imageURL: URL?, sharedPostId: String?) async throws -> Message {
        try await Task.sleep(for: .milliseconds(400))
        return await MainActor.run {
            let messageType: MessageType
            if sharedPostId != nil {
                messageType = .sharedPost
            } else if imageURL != nil {
                messageType = .image
            } else {
                messageType = .text
            }

            let message = Message(
                id: UUID().uuidString,
                conversationId: conversationId,
                senderId: SampleData.currentUser.id,
                content: content,
                imageURL: imageURL,
                sharedPostId: sharedPostId,
                messageType: messageType,
                reactions: [],
                replyTo: nil,
                status: .sent,
                createdAt: Date(),
                senderName: SampleData.currentUser.displayName,
                senderAvatarEmoji: SampleData.avatarEmoji(for: SampleData.currentUser.id),
                isCurrentUser: true,
                sharedPostPreview: nil
            )
            messageStore[conversationId, default: []].append(message)

            // Update conversation's last message
            if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
                conversations[index].lastMessageText = content ?? (imageURL != nil ? "Sent an image" : "Shared a post")
                conversations[index].lastMessageAt = Date()
            }
            return message
        }
    }

    nonisolated func createDMConversation(with userId: String) async throws -> Conversation {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            ensureLoaded()
            // Check if conversation already exists
            if let existing = conversations.first(where: {
                $0.type == .dm && $0.members.contains(where: { $0.userId == userId })
            }) {
                return existing
            }
            let otherUser = SampleData.allUsers.first(where: { $0.id == userId }) ?? SampleData.allUsers[0]
            let conversation = Conversation(
                id: UUID().uuidString,
                type: .dm,
                gatheringId: nil,
                title: otherUser.displayName,
                lastMessageText: nil,
                lastMessageAt: Date(),
                unreadCount: 0,
                members: [
                    ConversationMemberInfo(
                        userId: SampleData.currentUser.id,
                        displayName: SampleData.currentUser.displayName,
                        avatarEmoji: SampleData.avatarEmoji(for: SampleData.currentUser.id),
                        avatarURL: SampleData.currentUser.avatarURL
                    ),
                    ConversationMemberInfo(
                        userId: otherUser.id,
                        displayName: otherUser.displayName,
                        avatarEmoji: SampleData.avatarEmoji(for: otherUser.id),
                        avatarURL: otherUser.avatarURL
                    ),
                ],
                createdAt: Date(),
                isMutualFollow: false
            )
            conversations.insert(conversation, at: 0)
            return conversation
        }
    }

    nonisolated func markAsRead(conversationId: String) async throws {
        try await Task.sleep(for: .milliseconds(300))
        await MainActor.run {
            if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
                conversations[index].unreadCount = 0
            }
        }
    }

    nonisolated func fetchGatheringChat(gatheringId: String) async throws -> Conversation? {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run {
            ensureLoaded()
            return conversations.first { $0.gatheringId == gatheringId }
        }
    }

    nonisolated func searchUsers(query: String) async throws -> [User] {
        try await Task.sleep(for: .milliseconds(500))
        let lowered = query.lowercased()
        return SampleData.allUsers.filter {
            $0.username.lowercased().contains(lowered) ||
            $0.displayName.lowercased().contains(lowered)
        }
    }
}
