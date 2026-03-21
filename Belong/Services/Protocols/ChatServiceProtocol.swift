import Foundation

protocol ChatServiceProtocol: Sendable {
    func fetchConversations() async throws -> [Conversation]
    func fetchMessages(conversationId: String, page: Int) async throws -> [Message]
    func sendMessage(conversationId: String, content: String?, imageURL: URL?, sharedPostId: String?) async throws -> Message
    func createDMConversation(with userId: String) async throws -> Conversation
    func markAsRead(conversationId: String) async throws
    func fetchGatheringChat(gatheringId: String) async throws -> Conversation?
    func searchUsers(query: String) async throws -> [User]
}
