import SwiftUI
import Supabase

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
    @State private var showBlockConfirm = false
    @State private var showReportSheet = false
    @State private var isMutual = false
    @State private var isCreatingDM = false
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var isOwnProfile: Bool {
        userId == appState.currentUser?.id
    }

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
                    isMutual: isMutual,
                    isCreatingDM: isCreatingDM,
                    isOwnProfile: isOwnProfile,
                    onFollow: { await toggleFollow() },
                    onMessage: { await startMessage() }
                )
            }
        }
        .background(BelongColor.background)
        .navigationTitle(user?.displayName ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isOwnProfile {
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
            // Load follow state BEFORE showing content to prevent "Follow" flash on re-entry
            await loadFollowState()
            isLoading = false
            // Load posts and gatherings in parallel (secondary content)
            async let postsTask: () = loadPosts()
            async let gatheringsTask: () = loadGatherings()
            _ = await (postsTask, gatheringsTask)
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    private func loadFollowState() async {
        guard !isOwnProfile else { return }
        do {
            isFollowing = try await container.userService.isFollowing(userId: userId)
            // Check mutual: I follow them AND they follow me
            if isFollowing, let myId = SupabaseManager.shared.currentUserId {
                struct FollowCheck: Codable { let follower_id: String }
                let theyFollowMe: [FollowCheck] = try await SupabaseManager.shared.client
                    .from("follows")
                    .select("follower_id")
                    .eq("follower_id", value: userId)
                    .eq("following_id", value: myId)
                    .limit(1)
                    .execute()
                    .value
                isMutual = !theyFollowMe.isEmpty
            } else {
                isMutual = false
            }
        } catch {
            // Best-effort — keep current state
        }
    }

    private func loadPosts() async {
        do {
            posts = try await container.userService.fetchUserPosts(userId: userId)
        } catch {
            // Silently fail for sub-content
        }
    }

    private func loadGatherings() async {
        do {
            gatherings = try await container.userService.fetchUserGatherings(userId: userId)
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
            // Refresh follow + mutual state from backend
            await loadFollowState()
            // Refresh profile to update follower/following/mutual counts
            self.user = try await container.userService.fetchProfile(userId: user.id)
        } catch {
            // Rollback on failure
            isFollowing = wasFollowing
            self.error = error.localizedDescription
        }
    }

    private func startMessage() async {
        guard !isCreatingDM else { return }
        isCreatingDM = true
        defer { isCreatingDM = false }
        do {
            let conversation = try await container.chatService.createDMConversation(with: userId)
            appState.selectedTab = .chat
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(
                    name: .openConversation,
                    object: nil,
                    userInfo: ["conversation": conversation]
                )
            }
        } catch {
            self.error = "Could not start conversation"
        }
    }

    private func blockUser() async {
        guard let user else { return }
        do {
            try await container.userService.block(userId: user.id)
            dismiss()
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
    let isMutual: Bool
    let isCreatingDM: Bool
    let isOwnProfile: Bool
    let onFollow: () async -> Void
    let onMessage: () async -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Cover banner with overlapping avatar
                UserProfileBanner(user: user)

                // Compact identity (name, username, bio, school/city)
                UserProfileCompactIdentity(user: user)
                    .padding(.top, Spacing.xs)

                // Stats row
                UserProfileStats(user: user)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.sm)

                // Actions (hidden for own profile)
                if !isOwnProfile {
                    UserProfileActions(
                        isFollowing: isFollowing,
                        isMutual: isMutual,
                        isCreatingDM: isCreatingDM,
                        onFollow: onFollow,
                        onMessage: onMessage
                    )
                    .padding(.bottom, Spacing.sm)
                }

                // Cultural tags
                UserProfileTags(userId: user.id)
                    .padding(.bottom, Spacing.md)

                // Divider + tab selector
                Rectangle()
                    .fill(BelongColor.divider)
                    .frame(height: 1)

                Picker("Content", selection: $selectedTab) {
                    ForEach(ProfileTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.vertical, Spacing.sm)

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

// MARK: - Cover Banner (read-only)

private struct UserProfileBanner: View {
    let user: User
    private let bannerHeight: CGFloat = 150
    private let avatarOverlap: CGFloat = 32

    var body: some View {
        ZStack(alignment: .bottom) {
            // Banner
            if let bgURL = user.profileBackgroundURL {
                AsyncImage(url: bgURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        defaultGradient
                    }
                }
                .frame(height: bannerHeight)
                .clipped()
            } else {
                defaultGradient
                    .frame(height: bannerHeight)
            }

            // Avatar overlapping the banner edge
            AvatarView(imageURL: user.avatarURL, emoji: "\u{1F464}", size: .xlarge)
                .frame(width: 68, height: 68)
                .background(BelongColor.background)
                .clipShape(Circle())
                .overlay(Circle().stroke(BelongColor.background, lineWidth: 3))
                .offset(y: avatarOverlap)
        }
        .padding(.bottom, avatarOverlap)
    }

    private var defaultGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.17, green: 0.15, blue: 0.14),
                    Color(red: 0.30, green: 0.22, blue: 0.18),
                    Color(red: 0.45, green: 0.30, blue: 0.22),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [
                    Color(red: 0.55, green: 0.35, blue: 0.25).opacity(0.3),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 200
            )
        }
    }
}

// MARK: - Compact Identity

private struct UserProfileCompactIdentity: View {
    let user: User

    var body: some View {
        VStack(spacing: 2) {
            Text(user.displayName)
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)

            Text("@\(user.username)")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)

            if !user.bio.isEmpty {
                Text(user.bio)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, Spacing.xxl)
                    .padding(.top, 2)
            }

            HStack(spacing: Spacing.sm) {
                if !user.school.isEmpty {
                    Label(user.school, systemImage: "graduationcap")
                }
                if !user.city.isEmpty {
                    Label(user.city, systemImage: "mappin")
                }
            }
            .font(BelongFont.caption())
            .foregroundStyle(BelongColor.textTertiary)
            .padding(.top, 2)
        }
    }
}

// MARK: - Stats
// Rounded numbers for typographic texture. Clean 3-column grid.

private struct UserProfileStats: View {
    let user: User

    var body: some View {
        HStack(spacing: 0) {
            NavigationLink(value: ProfileRoute.userFollowing(user.id)) {
                UserProfileStatColumn(count: user.followingCount, label: "Following")
            }
            NavigationLink(value: ProfileRoute.userFollowers(user.id)) {
                UserProfileStatColumn(count: user.followerCount, label: "Followers")
            }
            UserProfileStatColumn(count: user.mutualCount, label: "Mutuals")
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Layout.screenPadding)
    }
}

private struct UserProfileStatColumn: View {
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("\(count)")
                .font(BelongFont.stat())
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
    let isCreatingDM: Bool
    let onFollow: () async -> Void
    let onMessage: () async -> Void

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
                    isLoading: isCreatingDM,
                    leadingIcon: "bubble.left"
                ) {
                    Task { await onMessage() }
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Cultural Tags (read-only)

private struct UserProfileTags: View {
    let userId: String
    @State private var tags: [UserTag] = []

    var body: some View {
        Group {
            if !tags.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Cultural Tags")
                        .font(BelongFont.secondaryMedium())
                        .foregroundStyle(BelongColor.textPrimary)

                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(tags) { tag in
                            ChipView(title: tag.value, isSelected: true)
                        }
                    }
                }
                .padding(.horizontal, Layout.screenPadding)
            }
        }
        .task {
            await loadTags()
        }
    }

    private func loadTags() async {
        do {
            let rows: [DBUserTag] = try await SupabaseManager.shared.client.from("user_tags")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            tags = rows.map {
                UserTag(
                    id: $0.id ?? UUID().uuidString,
                    userId: $0.userId ?? userId,
                    category: TagCategory(rawValue: $0.category) ?? .interestVibe,
                    value: $0.tagValue
                )
            }
        } catch {
            // Fall back to empty
        }
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
                message: "When they share something, it will appear here."
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
                message: "No gatherings to show yet."
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
            VStack(spacing: 0) {
                SkeletonView(height: 150)
                SkeletonView(width: 68, height: 68, cornerRadius: 34)
                    .offset(y: -32)
                    .padding(.bottom, -24)
                SkeletonView(width: 140, height: 20)
                    .padding(.top, Spacing.sm)
                SkeletonView(width: 100, height: 14)
                    .padding(.top, Spacing.xs)
                SkeletonView(height: 48)
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.top, Spacing.md)
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserProfileScreen(userId: SampleData.userIdJin)
    }
    .environment(AppState())
    .environment(DependencyContainer())
}
