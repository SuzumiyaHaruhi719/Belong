import SwiftUI

enum ConnectionsTab: String, CaseIterable {
    case followers = "Followers"
    case following = "Following"
    case mutuals = "Mutuals"
}

struct ConnectionsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?
    @State private var selectedTab: ConnectionsTab
    @State private var searchText = ""

    init(initialTab: ConnectionsTab = .followers) {
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        Group {
            if let vm = viewModel {
                ConnectionsContent(
                    viewModel: vm,
                    selectedTab: $selectedTab,
                    searchText: $searchText
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle(selectedTab.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = ProfileViewModel(userService: container.userService)
                viewModel = vm
                await vm.loadProfile()
            }
            await loadCurrentTab()
        }
        .onChange(of: selectedTab) { _, _ in
            Task { await loadCurrentTab() }
        }
    }

    private func loadCurrentTab() async {
        guard let vm = viewModel else { return }
        switch selectedTab {
        case .followers: await vm.loadFollowers()
        case .following: await vm.loadFollowing()
        case .mutuals: await vm.loadMutuals()
        }
    }
}

// MARK: - Content

private struct ConnectionsContent: View {
    @Bindable var viewModel: ProfileViewModel
    @Binding var selectedTab: ConnectionsTab
    @Binding var searchText: String

    private var currentUsers: [User] {
        let users: [User]
        switch selectedTab {
        case .followers: users = viewModel.followers
        case .following: users = viewModel.following
        case .mutuals: users = viewModel.mutuals
        }
        if searchText.isEmpty { return users }
        return users.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Connections", selection: $selectedTab) {
                ForEach(ConnectionsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)

            SearchBar(text: $searchText, placeholder: "Search people...")
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.sm)

            if let error = viewModel.error {
                ErrorStateView(message: error)
            } else if currentUsers.isEmpty {
                connectionEmptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(currentUsers) { user in
                            NavigationLink(value: ProfileRoute.userProfile(user.id)) {
                                ConnectionUserRow(
                                    user: user,
                                    tab: selectedTab,
                                    viewModel: viewModel
                                )
                            }
                            .buttonStyle(.plain)
                            Divider()
                                .padding(.leading, Layout.screenPadding + Layout.touchTargetMin + Spacing.md)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var connectionEmptyState: some View {
        switch selectedTab {
        case .followers:
            EmptyStateView(
                icon: "person.2",
                title: "No followers yet",
                message: "When people follow you, they will appear here."
            )
        case .following:
            EmptyStateView(
                icon: "person.badge.plus",
                title: "Not following anyone",
                message: "Follow people to see them here."
            )
        case .mutuals:
            EmptyStateView(
                icon: "person.2.fill",
                title: "No mutuals yet",
                message: "When you and someone follow each other, they will appear here."
            )
        }
    }
}

// MARK: - Connection User Row

private struct ConnectionUserRow: View {
    let user: User
    let tab: ConnectionsTab
    let viewModel: ProfileViewModel

    private var trailingTitle: String {
        switch tab {
        case .followers: "Follow"
        case .following: "Unfollow"
        case .mutuals: "Message"
        }
    }

    var body: some View {
        UserRow(
            avatarEmoji: SampleData.avatarEmoji(for: user.id),
            name: user.displayName,
            subtitle: "@\(user.username)",
            trailingActionTitle: trailingTitle,
            onTrailingAction: {
                Task {
                    switch tab {
                    case .followers:
                        await viewModel.followUser(user.id)
                    case .following:
                        await viewModel.unfollowUser(user.id)
                    case .mutuals:
                        break // Navigate to message
                    }
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        ConnectionsScreen(initialTab: .followers)
    }
    .environment(DependencyContainer())
}
