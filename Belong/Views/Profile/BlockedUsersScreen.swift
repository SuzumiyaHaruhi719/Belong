import SwiftUI

struct BlockedUsersScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                BlockedUsersContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(userService: container.userService)
            }
            await viewModel?.loadBlockedUsers()
        }
    }
}

// MARK: - Content

private struct BlockedUsersContent: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.blockedUsers.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error, viewModel.blockedUsers.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadBlockedUsers() }
                }
            } else if viewModel.blockedUsers.isEmpty {
                EmptyStateView(
                    icon: "slash.circle",
                    title: "No blocked users",
                    message: "You haven't blocked anyone."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.blockedUsers) { user in
                            UserRow(
                                avatarEmoji: SampleData.avatarEmoji(for: user.id),
                                name: user.displayName,
                                subtitle: "@\(user.username)",
                                trailingActionTitle: "Unblock",
                                onTrailingAction: {
                                    Task { await viewModel.unblockUser(user.id) }
                                }
                            )
                            Divider()
                                .padding(.leading, Layout.screenPadding + Layout.touchTargetMin + Spacing.md)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BlockedUsersScreen()
    }
    .environment(DependencyContainer())
}
