import SwiftUI

struct UserProfileScreen: View {
    let userId: String
    @Environment(DependencyContainer.self) private var container
    @State private var user: User?
    @State private var posts: [Post] = []
    @State private var gatherings: [Gathering] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var isFollowing = false
    @State private var selectedTab: ProfileTab = .posts
    @State private var showOverflowMenu = false
    @State private var showBlockConfirm = false
    @State private var showReportSheet = false

    var body: some View {
        Group {
            if isLoading && user == nil {
                UserProfileLoading()
            } else if let errorMsg = error, user == nil {
                ErrorStateView(message: errorMsg) {
                    Task { await loadUser() }
                }
            } else if let user {
                UserProfileScrollContent(
                    user: user,
                    posts: posts,
                    gatherings: gatherings,
                    isFollowing: $isFollowing,
                    selectedTab: $selectedTab,
                    onFollow: { await toggleFollow() },
                    onBlock: { await blockUser() }
                )
            }
        }
        .background(BelongColor.background)
        .navigationTitle(user?.displayName ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showBlockConfirm = true
                    } label: {
                        Label("Block", systemImage: "slash.circle")
                    }
                    Button(role: .destructive) {
                        showReportSheet = true
                    } label: {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(BelongColor.textPrimary)
                }
            }
        }
        .task {
            await loadUser()
        }
        .alert("Block this user?", isPresented: $showBlockConfirm) {
            Button("Block", role: .destructive) {
                Task { await blockUser() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("They won't be able to see your profile or content. You can unblock them later.")
        }
    }

    private func loadUser() async {
        isLoading = true
        error = nil
        do {
            user = try await container.userService.fetchProfile(userId: userId)
            isLoading = false
            // Load follow state, posts, and gatherings in parallel
            async let followTask: () = loadFollowState()
            async let postsTask: () = loadPosts()
            async let gatheringsTask: () = loadGatherings()
            _ = await (followTask, postsTask, gatheringsTask)
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    private func loadFollowState() async {
        do {
            isFollowing = try await container.userService.isFollowing(userId: userId)
        } catch {
            // Best-effort — keep current state
        }
    }

    private func loadPosts() async {
        do {
            posts = try await container.userService.fetchMyPosts()
        } catch {
            // Silently fail for sub-content
        }
    }

    private func loadGatherings() async {
        do {
            gatherings = try await container.userService.fetchMyGatherings(role: nil)
        } catch {
            // Silently fail for sub-content
        }
    }

    private func toggleFollow() async {
        guard let user else { return }
        let wasFollowing = isFollowing
        // Optimistic update
        isFollowing = !wasFollowing
        do {
            if wasFollowing {
                try await container.userService.unfollow(userId: user.id)
            } else {
                try await container.userService.follow(userId: user.id)
            }
            // Verify actual state from backend
            isFollowing = try await container.userService.isFollowing(userId: user.id)
        } catch {
            // Rollback on failure
            isFollowing = wasFollowing
            self.error = error.localizedDescription
        }
    }

    private func blockUser() async {
        guard let user else { return }
        do {
            try await container.userService.block(userId: user.id)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

// MARK: - Scroll Content

private struct UserProfileScrollContent: View {
    let user: User
    let posts: [Post]
    let gatherings: [Gathering]
    @Binding var isFollowing: Bool
    @Binding var selectedTab: ProfileTab
    let onFollow: () async -> Void
    let onBlock: () async -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                UserProfileHeader(user: user)
                UserProfileStats(user: user)
                UserProfileActions(
                    isFollowing: isFollowing,
                    isMutual: user.mutualCount > 0,
                    onFollow: onFollow
                )

                Picker("Content", selection: $selectedTab) {
                    ForEach(ProfileTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Layout.screenPadding)

                switch selectedTab {
                case .posts:
                    UserProfilePostsGrid(posts: posts)
                case .gatherings:
                    UserProfileGatheringsList(gatherings: gatherings)
                }
            }
            .padding(.bottom, Spacing.xxxl)
        }
    }
}

// MARK: - Header

private struct UserProfileHeader: View {
    let user: User

    var body: some View {
        VStack(spacing: Spacing.md) {
            AvatarView(imageURL: user.avatarURL, emoji: "👤", size: .xlarge)

            Text(user.displayName)
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("@\(user.username)")
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)

            if !user.bio.isEmpty {
                Text(user.bio)
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            HStack(spacing: Spacing.sm) {
                if !user.school.isEmpty {
                    Label(user.school, systemImage: "graduationcap")
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textSecondary)
                }
                if !user.city.isEmpty {
                    Label(user.city, systemImage: "mappin")
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textSecondary)
                }
            }
        }
        .padding(.top, Spacing.base)
    }
}

// MARK: - Stats

private struct UserProfileStats: View {
    let user: User

    var body: some View {
        HStack(spacing: 0) {
            UserProfileStatColumn(count: user.followingCount, label: "Following")
            UserProfileStatColumn(count: user.followerCount, label: "Followers")
            UserProfileStatColumn(count: user.mutualCount, label: "Mutuals")
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

private struct UserProfileStatColumn: View {
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("\(count)")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
            Text(label)
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Actions

private struct UserProfileActions: View {
    let isFollowing: Bool
    let isMutual: Bool
    let onFollow: () async -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            BelongButton(
                title: isFollowing ? "Following" : "Follow",
                style: isFollowing ? .secondary : .primary,
                isFullWidth: true
            ) {
                Task { await onFollow() }
            }

            if isMutual {
                BelongButton(
                    title: "Message",
                    style: .secondary,
                    isFullWidth: true,
                    leadingIcon: "bubble.left"
                ) {
                    // Navigate to message
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Posts Grid

private struct UserProfilePostsGrid: View {
    let posts: [Post]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        if posts.isEmpty {
            EmptyStateView(
                icon: "square.grid.2x2",
                title: "No posts yet",
                message: "This user hasn't shared any posts."
            )
        } else {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(posts) { post in
                    NavigationLink(value: PostsRoute.detail(post)) {
                        UserProfilePostThumbnail(post: post)
                    }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
        }
    }
}

private struct UserProfilePostThumbnail: View {
    let post: Post

    var body: some View {
        Group {
            if let image = post.coverImage {
                AsyncImage(url: image.imageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        thumbnailPlaceholder
                    }
                }
            } else {
                thumbnailPlaceholder
            }
        }
        .frame(minHeight: 110)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            BelongColor.surfaceSecondary
            Image(systemName: "text.quote")
                .font(.system(size: 20))
                .foregroundStyle(BelongColor.textTertiary)
        }
    }
}

// MARK: - Gatherings List

private struct UserProfileGatheringsList: View {
    let gatherings: [Gathering]

    var body: some View {
        if gatherings.isEmpty {
            EmptyStateView(
                icon: "person.3",
                title: "No gatherings",
                message: "This user hasn't hosted or joined any gatherings."
            )
        } else {
            LazyVStack(spacing: Spacing.base) {
                ForEach(gatherings) { gathering in
                    NavigationLink(value: GatheringsRoute.detail(gathering)) {
                        GatheringCard(gathering: gathering)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Layout.screenPadding)
        }
    }
}

// MARK: - Loading

private struct UserProfileLoading: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                SkeletonView(width: 80, height: 80, cornerRadius: 40)
                SkeletonView(width: 140, height: 24)
                SkeletonView(width: 100, height: 16)
                SkeletonView(height: 48)
                    .padding(.horizontal, Layout.screenPadding)
            }
            .padding(.top, Spacing.xl)
        }
    }
}

#Preview {
    NavigationStack {
        UserProfileScreen(userId: SampleData.userIdJin)
    }
    .environment(DependencyContainer())
}
