import SwiftUI

struct ChatSearchScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var searchText = ""
    @State private var allConversations: [Conversation] = []
    @State private var isLoading = true

    private var filteredConversations: [Conversation] {
        guard !searchText.isEmpty else { return allConversations }
        let query = searchText.lowercased()
        return allConversations.filter {
            $0.displayTitle.lowercased().contains(query) ||
            ($0.lastMessageText ?? "").lowercased().contains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(
                text: $searchText,
                placeholder: "Search conversations..."
            )
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if filteredConversations.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: searchText.isEmpty ? "Your conversations" : "No results",
                    message: searchText.isEmpty
                        ? "Search through your conversations"
                        : "No conversations match your search"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredConversations) { conversation in
                            NavigationLink(value: ChatRoute.conversation(conversation)) {
                                ChatSearchRow(conversation: conversation)
                            }
                            Divider().padding(.leading, Layout.screenPadding + 56)
                        }
                    }
                }
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Search Chats")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                allConversations = try await container.chatService.fetchConversations()
            } catch {}
            isLoading = false
        }
    }
}

// MARK: - Search Row

private struct ChatSearchRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(emoji: conversation.displayAvatar, size: .large)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(conversation.displayTitle)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(1)
                if let lastMessage = conversation.lastMessageText {
                    Text(lastMessage)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.md)
        .background(BelongColor.surface)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChatSearchScreen()
            .environment(DependencyContainer())
    }
}
