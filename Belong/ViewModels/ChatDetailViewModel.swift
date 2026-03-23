import SwiftUI
import Supabase
import Realtime

@Observable @MainActor
final class ChatDetailViewModel {
    // MARK: - Dependencies
    private let chatService: any ChatServiceProtocol
    private var realtimeChannel: RealtimeChannelV2?

    // MARK: - State
    var conversation: Conversation?
    var messages: [Message] = []
    var isLoading = false
    var error: String?
    var newMessageText = ""
    var isSending = false
    var replyingTo: Message?

    /// True when the conversation is a DM with mutual follow, OR when no messages
    /// have been sent yet (allowing the first ice-breaker message).
    var canSendMessage: Bool {
        guard let conversation else { return false }
        if conversation.type == .gatheringGroup { return true }
        if conversation.isMutualFollow { return true }
        // Allow the first message even without mutual follow
        let currentUserMessages = messages.filter { $0.isCurrentUser && $0.messageType != .system }
        return currentUserMessages.isEmpty
    }

    /// True when conversation is a DM without mutual follow.
    var showDMGatingBanner: Bool {
        guard let conversation else { return false }
        return conversation.type == .dm && !conversation.isMutualFollow
    }

    /// Banner text when composer is disabled because first message was already sent.
    var dmGatingMessage: String? {
        guard showDMGatingBanner else { return nil }
        if canSendMessage {
            return "You can send one message. Follow each other to continue chatting."
        }
        return "Follow each other to chat more"
    }

    var isComposerDisabled: Bool {
        !canSendMessage
    }

    // MARK: - Init

    init(chatService: any ChatServiceProtocol) {
        self.chatService = chatService
    }

    // MARK: - Actions

    func loadMessages(conversationId: String) async {
        isLoading = true
        error = nil
        do {
            messages = try await chatService.fetchMessages(conversationId: conversationId, page: 1)
            try? await chatService.markAsRead(conversationId: conversationId)
            // Refresh mutual follow status from latest conversation data
            await refreshMutualFollowStatus(conversationId: conversationId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false

        // Start listening for new messages in realtime
        await subscribeToMessages(conversationId: conversationId)
    }

    private func refreshMutualFollowStatus(conversationId: String) async {
        guard var conv = conversation, conv.type == .dm, !conv.isMutualFollow else { return }
        // Re-fetch conversations to get fresh isMutualFollow
        if let fresh = try? await chatService.fetchConversations(),
           let updated = fresh.first(where: { $0.id == conversationId }),
           updated.isMutualFollow {
            conv.isMutualFollow = true
            conversation = conv
        }
    }

    /// Subscribe to realtime INSERT events on the messages table for this conversation
    private func subscribeToMessages(conversationId: String) async {
        // Unsubscribe from previous channel if any
        await unsubscribe()

        do {
            let channel = SupabaseManager.shared.client.realtimeV2.channel("messages:\(conversationId)")

            let insertions = channel.postgresChange(InsertAction.self, schema: "public", table: "messages", filter: "conversation_id=eq.\(conversationId)")

            await channel.subscribe()

            // Listen for new messages in background
            Task { [weak self] in
                for await insert in insertions {
                    guard let self else { return }
                    let record = insert.record
                    let senderId = (try? record["sender_id"]?.value as? String) ?? ""
                    let myId = SupabaseManager.shared.currentUserId ?? ""

                    // Skip messages we sent ourselves (already in the list)
                    if senderId == myId { continue }

                    let newMessage = Message(
                        id: (try? record["id"]?.value as? String) ?? UUID().uuidString,
                        conversationId: conversationId,
                        senderId: senderId,
                        content: try? record["content"]?.value as? String,
                        imageURL: (try? record["image_url"]?.value as? String).flatMap { URL(string: $0) },
                        sharedPostId: try? record["shared_post_id"]?.value as? String,
                        messageType: MessageType(rawValue: (try? record["message_type"]?.value as? String) ?? "text") ?? .text,
                        reactions: [],
                        replyTo: nil,
                        status: .delivered,
                        createdAt: Date(),
                        senderName: "User",
                        senderAvatarEmoji: "🙂",
                        isCurrentUser: false,
                        sharedPostPreview: nil
                    )
                    self.messages.append(newMessage)
                }
            }

            self.realtimeChannel = channel
        } catch {
            self.error = "Failed to connect to live updates: \(error.localizedDescription)"
        }
    }

    func unsubscribe() async {
        if let channel = realtimeChannel {
            await SupabaseManager.shared.client.realtimeV2.removeChannel(channel)
            realtimeChannel = nil
        }
    }

    func sendMessage() async {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let conversation else { return }

        isSending = true
        let replyRef: ReplyReference? = if let replyingTo {
            ReplyReference(
                messageId: replyingTo.id,
                senderName: replyingTo.senderName,
                previewText: String((replyingTo.content ?? "").prefix(50))
            )
        } else {
            nil
        }

        do {
            var sent = try await chatService.sendMessage(
                conversationId: conversation.id,
                content: trimmed,
                imageURL: nil,
                sharedPostId: nil
            )
            sent.replyTo = replyRef
            messages.append(sent)
            newMessageText = ""
            replyingTo = nil
        } catch {
            self.error = error.localizedDescription
        }
        isSending = false
    }

    func sendImage(url: URL) async {
        guard let conversation else { return }
        isSending = true
        do {
            let sent = try await chatService.sendMessage(
                conversationId: conversation.id,
                content: nil,
                imageURL: url,
                sharedPostId: nil
            )
            messages.append(sent)
        } catch {
            self.error = error.localizedDescription
        }
        isSending = false
    }

    func sendSharedPost(postId: String) async {
        guard let conversation else { return }
        isSending = true
        do {
            let sent = try await chatService.sendMessage(
                conversationId: conversation.id,
                content: nil,
                imageURL: nil,
                sharedPostId: postId
            )
            messages.append(sent)
        } catch {
            self.error = error.localizedDescription
        }
        isSending = false
    }

    func beginReply(to message: Message) {
        replyingTo = message
    }

    func cancelReply() {
        replyingTo = nil
    }
}
