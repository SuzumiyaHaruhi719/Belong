import SwiftUI

enum ConnectionsTab: String, CaseIterable {
    case followers = "Followers"
    case following = "Following"
    case mutuals = "Mutuals"
}

struct ConnectionsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    @State private var viewModel: ProfileViewModel?
    @State private var selectedTab: ConnectionsTab
    @State private var searchText = ""
    @State private var myFollowingIds: Set<String> = []
    let userId: String?

    init(initialTab: ConnectionsTab = .followers, userId: String? = nil) {
        _selectedTab = State(initialValue: initialTab)
        self.userId = userId
    }

    private var isOwnConnections: Bool { userId == nil }

    var body: some View {
        Group {
            if let vm = viewModel {
                ConnectionsContent(
                    viewModel: vm,
                    selectedTab: $selectedTab,
                    searchText: $searchText,
                    isOwnConnections: isOwnConnections,
                    myFollowingIds: myFollowingIds
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
                if let userId {
                    await vm.loadUserProfile(userId: userId)
                } else {
                    await vm.loadProfile()
                }
                await loadMyFollowingIds()
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

    private func loadMyFollowingIds() async {
        guard let myId = appState.currentUser?.id else { return }
        do {
            let following = try await container.userService.fetchFollowing(userId: myId, page: 0)
            myFollowingIds = Set(following.map(\.id))
        } catch { }
    }
}

// MARK: - Content

private struct ConnectionsContent: View {
    @Bindable var viewModel: ProfileViewModel
    @Binding var selectedTab: ConnectionsTab
    @Binding var searchText: String
    let isOwnConnections: Bool
    let myFollowingIds: Set<String>

    private var availableTabs: [ConnectionsTab] {
        isOwnConnections ? ConnectionsTab.allCases : [.followers, .following]
    }

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
                ForEach(availableTabs, id: \.self) { tab in
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
                ErrorStateView(message: error, onRetry: {
                    Task {
                        switch selectedTab {
                        case .followers: await viewModel.loadFollowers()
                        case .following: await viewModel.loadFollowing()
                        case .mutuals: await viewModel.loadMutuals()
                        }
                    }
                })
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
                                    isOwnConnections: isOwnConnections,
                                    isFollowed: myFollowingIds.contains(user.id)
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
                message: "Share your profile or join gatherings to grow your community."
            )
        case .following:
            EmptyStateView(
                icon: "person.badge.plus",
                title: "Not following anyone yet",
                message: "Discover people through gatherings and posts."
            )
        case .mutuals:
            EmptyStateView(
                icon: "person.2.fill",
                title: "No mutuals yet",
                message: "When you and someone follow each other, they'll appear here."
            )
        }
    }
}

// MARK: - Connection User Row

private struct ConnectionUserRow: View {
    let user: User
    let tab: ConnectionsTab
    let isOwnConnections: Bool
    @State private var isFollowed: Bool
    @State private var isProcessing = false
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState

    init(user: User, tab: ConnectionsTab, isOwnConnections: Bool, isFollowed: Bool) {
        self.user = user
        self.tab = tab
        self.isOwnConnections = isOwnConnections
        _isFollowed = State(initialValue: isFollowed)
    }

    private var isCurrentUser: Bool {
        user.id == appState.currentUser?.id
    }

    private var showMessage: Bool {
        tab == .mutuals && isOwnConnections
    }

    private var buttonTitle: String {
        if showMessage { return "Message" }
        return isFollowed ? "Following" : "Follow"
    }

    var body: some View {
        let actionTitle: String? = isCurrentUser ? nil : (isProcessing ? "..." : buttonTitle)
        let action: (() -> Void)? = isCurrentUser ? nil : {
            guard !isProcessing else { return }
            isProcessing = true
            Task {
                if showMessage {
                    await openDM()
                } else if isFollowed {
                    await doUnfollow()
                } else {
                    await doFollow()
                }
                isProcessing = false
            }
        }

        UserRow(
            avatarURL: user.avatarURL,
            avatarEmoji: "\u{1F464}",
            name: user.displayName,
            subtitle: "@\(user.username)",
            trailingActionTitle: actionTitle,
            onTrailingAction: action
        )
    }

    private func doFollow() async {
        do {
            try await container.userService.follow(userId: user.id)
            isFollowed = true
        } catch { }
    }

    private func doUnfollow() async {
        do {
            try await container.userService.unfollow(userId: user.id)
            isFollowed = false
        } catch { }
    }

    private func openDM() async {
        do {
            let conversation = try await container.chatService.createDMConversation(with: user.id)
            appState.selectedTab = .chat
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(
                    name: .openConversation,
                    object: nil,
                    userInfo: ["conversation": conversation]
                )
            }
        } catch { }
    }
}

#Preview {
    NavigationStack {
        ConnectionsScreen(initialTab: .followers)
    }
    .environment(AppState())
    .environment(DependencyContainer())
}
