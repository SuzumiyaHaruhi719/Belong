import SwiftUI

struct ProfileScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                ProfileScreenContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(userService: container.userService)
            }
            await viewModel?.loadProfile()
            await viewModel?.loadMyPosts()
            await viewModel?.loadMyGatherings()
        }
    }
}

// MARK: - Content

private struct ProfileScreenContent: View {
    @Bindable var viewModel: ProfileViewModel
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.user == nil {
                ProfileScreenLoading()
            } else if let errorMsg = viewModel.error, viewModel.user == nil {
                ErrorStateView(message: errorMsg) {
                    Task { await viewModel.loadProfile() }
                }
            } else if let user = viewModel.user {
                ProfileScrollContent(user: user, viewModel: viewModel)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: ProfileRoute.settings) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .accessibilityLabel("Settings")
            }
        }
    }
}

// MARK: - Scroll Content

private struct ProfileScrollContent: View {
    let user: User
    @Bindable var viewModel: ProfileViewModel

    // UX: Profile header is a compact identity section. The tab content below
    // needs generous top spacing so it doesn't feel crushed against the tags.
    // Cultural tags + tab selector get extra vertical padding for breathing room.

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Identity cluster — tighter internal spacing
                ProfileHeaderSection(user: user)
                    .padding(.bottom, Spacing.base)

                ProfileStatsRow(user: user)
                    .padding(.bottom, Spacing.base)

                ProfileActionButtons()
                    .padding(.bottom, Spacing.lg)

                ProfileCulturalTags()
                    .padding(.bottom, Spacing.xl)

                // Divider before tab area for visual separation
                Rectangle()
                    .fill(BelongColor.divider)
                    .frame(height: 1)
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.bottom, Spacing.base)

                ProfileTabSelector(selectedTab: $viewModel.selectedProfileTab)
                    .padding(.bottom, Spacing.lg)

                // Tab content with generous top breathing room
                switch viewModel.selectedProfileTab {
                case .posts:
                    ProfilePostsGrid(posts: viewModel.myPosts)
                case .gatherings:
                    ProfileGatheringsList(gatherings: viewModel.myGatherings)
                }
            }
            .padding(.bottom, Spacing.xxxl)
        }
    }
}

// MARK: - Header

private struct ProfileHeaderSection: View {
    let user: User

    var body: some View {
        VStack(spacing: Spacing.md) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(imageURL: user.avatarURL, emoji: SampleData.avatarEmoji(for: user.id), size: .xlarge)
                NavigationLink(value: ProfileRoute.editProfile) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(BelongColor.textOnPrimary)
                        .frame(width: 28, height: 28)
                        .background(BelongColor.primary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(BelongColor.surface, lineWidth: 2))
                }
                .accessibilityLabel("Edit avatar")
            }

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

private struct ProfileStatsRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 0) {
            NavigationLink(value: ProfileRoute.following) {
                ProfileStatColumn(count: user.followingCount, label: "Following")
            }
            NavigationLink(value: ProfileRoute.followers) {
                ProfileStatColumn(count: user.followerCount, label: "Followers")
            }
            NavigationLink(value: ProfileRoute.mutuals) {
                ProfileStatColumn(count: user.mutualCount, label: "Mutuals")
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

private struct ProfileStatColumn: View {
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

// MARK: - Action Buttons

private struct ProfileActionButtons: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            NavigationLink(value: ProfileRoute.editProfile) {
                Text("Edit Profile")
                    .font(BelongFont.button())
                    .foregroundStyle(BelongColor.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Layout.buttonHeight)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.radiusMd)
                            .stroke(BelongColor.primary, lineWidth: 1.5)
                    )
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Cultural Tags

private struct ProfileCulturalTags: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Cultural Tags")
                    .font(BelongFont.h3())
                    .foregroundStyle(BelongColor.textPrimary)
                Spacer()
                NavigationLink(value: ProfileRoute.editTags) {
                    Text("Edit")
                        .font(BelongFont.secondaryMedium())
                        .foregroundStyle(BelongColor.primary)
                }
            }

            FlowLayout(spacing: Spacing.sm) {
                ForEach(["Vietnamese", "English", "Food", "Cooking", "Hiking"], id: \.self) { tag in
                    ChipView(title: tag, isSelected: true)
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Tab Selector

private struct ProfileTabSelector: View {
    @Binding var selectedTab: ProfileTab

    var body: some View {
        Picker("Content", selection: $selectedTab) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Posts Grid (小红书-style 2-column)
// UX: 2 columns gives each post enough room to show a preview image plus
// title and engagement info. This matches the discovery-oriented feel of
// the Posts tab — users scan visually, not just by thumbnails.

private struct ProfilePostsGrid: View {
    let posts: [Post]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 2)

    var body: some View {
        if posts.isEmpty {
            EmptyStateView(
                icon: "square.grid.2x2",
                title: "No posts yet",
                message: "Share your first post with the community."
            )
        } else {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(posts) { post in
                    NavigationLink(value: PostsRoute.detail(post)) {
                        ProfilePostCard(post: post)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Layout.screenPadding)
        }
    }
}

private struct ProfilePostCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover image — 4:3 aspect for visual appeal
            Group {
                if let image = post.coverImage {
                    AsyncImage(url: image.imageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            cardPlaceholder
                        }
                    }
                } else {
                    cardPlaceholder
                }
            }
            .frame(height: 160)
            .clipped()

            // Text content below image
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Post text preview (max 2 lines)
                Text(post.content)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(2)

                // Engagement row
                HStack(spacing: Spacing.md) {
                    Label("\(post.likeCount)", systemImage: "heart")
                    Label("\(post.commentCount)", systemImage: "bubble.right")
                }
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.sm)
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Post: \(post.content.prefix(60))")
    }

    private var cardPlaceholder: some View {
        ZStack {
            BelongColor.surfaceSecondary
            Image(systemName: "text.quote")
                .font(.system(size: 24))
                .foregroundStyle(BelongColor.textTertiary)
        }
    }
}

// MARK: - Gatherings List

private struct ProfileGatheringsList: View {
    let gatherings: [Gathering]

    var body: some View {
        if gatherings.isEmpty {
            EmptyStateView(
                icon: "person.3",
                title: "No gatherings yet",
                message: "Join or host a gathering to see it here."
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

private struct ProfileScreenLoading: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                SkeletonView(width: 80, height: 80, cornerRadius: 40)
                SkeletonView(width: 140, height: 24)
                SkeletonView(width: 100, height: 16)
                SkeletonView(height: 40)
                    .padding(.horizontal, Layout.screenPadding)
                SkeletonCard()
                    .padding(.horizontal, Layout.screenPadding)
            }
            .padding(.top, Spacing.xl)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
    .environment(AppState())
    .environment(DependencyContainer())
}
