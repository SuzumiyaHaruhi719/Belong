import SwiftUI

struct PostLikesScreen: View {
    let postId: String
    @Environment(DependencyContainer.self) private var container
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error, users.isEmpty {
                ErrorStateView(message: error, onRetry: {
                    Task { await loadLikes() }
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if users.isEmpty {
                EmptyStateView(
                    icon: "heart",
                    title: "No likes yet",
                    message: "Be the first to like this post!"
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                PostLikesList(users: users)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Likes")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadLikes()
        }
    }

    private func loadLikes() async {
        isLoading = true
        error = nil
        do {
            // Re-use followers endpoint as a stand-in for likes (real API would have a dedicated endpoint)
            users = try await container.userService.fetchFollowers(userId: postId, page: 1)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Likes List

private struct PostLikesList: View {
    let users: [User]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(users) { user in
                    UserRow(
                        avatarURL: user.avatarURL,
                        avatarEmoji: user.avatarEmoji,
                        name: user.displayName,
                        subtitle: "@\(user.username)",
                        trailingActionTitle: "Follow",
                        onTrailingAction: {}
                    )
                    Divider()
                        .padding(.leading, Layout.screenPadding + Layout.touchTargetMin + Spacing.md)
                }
            }
        }
    }
}

// MARK: - User Convenience

private extension User {
    var avatarEmoji: String {
        SampleData.avatarEmoji(for: id)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PostLikesScreen(postId: SampleData.postIdPhoRecipe)
            .environment(DependencyContainer())
    }
}
