import SwiftUI

struct NewConversationScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    @State private var isCreating = false
    @State private var createdConversation: Conversation?
    @State private var navigateToConversation = false

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(
                text: $searchText,
                placeholder: "Search users...",
                onDebouncedChange: { query in
                    Task { await searchUsers(query: query) }
                }
            )
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)

            if isSearching {
                Spacer()
                ProgressView()
                Spacer()
            } else if searchText.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "Search for users",
                    message: "Search for users to message"
                )
                Spacer()
            } else if searchResults.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "person.slash",
                    title: "No users found",
                    message: "Try a different search term"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchResults) { user in
                            Button {
                                Task { await startConversation(with: user) }
                            } label: {
                                UserRow(
                                    avatarURL: user.avatarURL,
                                    avatarEmoji: "👤",
                                    name: user.displayName,
                                    subtitle: "@\(user.username)"
                                )
                            }
                            .disabled(isCreating)
                            Divider().padding(.leading, Layout.screenPadding + 56)
                        }
                    }
                }
            }
        }
        .background(BelongColor.background)
        .navigationTitle("New Message")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(BelongColor.primary)
            }
        }
        .navigationDestination(item: $createdConversation) { conversation in
            ChatDetailScreen(conversation: conversation)
        }
    }

    private func searchUsers(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        do {
            searchResults = try await container.chatService.searchUsers(query: query)
            // Filter out current user
            searchResults.removeAll { $0.id == SupabaseManager.shared.currentUserId }
        } catch {
            searchResults = []
        }
        isSearching = false
    }

    private func startConversation(with user: User) async {
        isCreating = true
        do {
            let conversation = try await container.chatService.createDMConversation(with: user.id)
            createdConversation = conversation
        } catch {}
        isCreating = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NewConversationScreen()
            .environment(DependencyContainer())
    }
}
