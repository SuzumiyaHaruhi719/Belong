import SwiftUI

/// Thin wrapper around ChatDetailScreen for gathering group chats.
/// Adds gathering context flag to disable DM gating and show gathering header.
struct GroupChatScreen: View {
    let gatheringId: String
    @Environment(DependencyContainer.self) private var container
    @State private var conversation: Conversation?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BelongColor.background)
            } else if let conversation {
                ChatDetailScreen(
                    conversation: conversation,
                    isGatheringContext: true
                )
            } else if let error {
                ErrorStateView(message: error, onRetry: {
                    Task { await loadGatheringChat() }
                })
            } else {
                EmptyStateView(
                    icon: "bubble.left.and.bubble.right",
                    title: "No group chat",
                    message: "This gathering does not have a group chat yet."
                )
            }
        }
        .task {
            await loadGatheringChat()
        }
    }

    private func loadGatheringChat() async {
        isLoading = true
        error = nil
        do {
            conversation = try await container.chatService.fetchGatheringChat(gatheringId: gatheringId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GroupChatScreen(gatheringId: SampleData.gatheringIdPho)
            .environment(DependencyContainer())
    }
}
