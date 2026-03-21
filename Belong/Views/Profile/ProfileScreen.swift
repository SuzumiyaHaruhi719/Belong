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
// UX: Cover banner → overlapping avatar → compact identity → stats →
// tags → tabs → content. The cover creates visual personality. Avatar
// overlaps the banner edge like Instagram/小红书 for a polished feel.
// Top half is deliberately compact to give posts/gatherings maximum space.

private struct ProfileScrollContent: View {
    let user: User
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Cover banner with overlapping avatar
                ProfileCoverBanner(user: user)

                // Compact identity (name, username, bio, school)
                ProfileCompactIdentity(user: user)
                    .padding(.top, Spacing.xs)

                // Stats row
                ProfileStatsRow(user: user)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.sm)

                // Edit button (compact)
                ProfileActionButtons()
                    .padding(.bottom, Spacing.sm)

                // Cultural tags
                ProfileCulturalTags()
                    .padding(.bottom, Spacing.md)

                // Divider + tab selector
                Rectangle()
                    .fill(BelongColor.divider)
                    .frame(height: 1)

                ProfileTabSelector(selectedTab: $viewModel.selectedProfileTab)
                    .padding(.vertical, Spacing.sm)

                // Content area — gets the most space
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

// MARK: - Cover Banner
// UX: Profile background creates visual personality. Default is a warm
// gradient matching the app palette. Users can set a custom photo or
// pick from presets. Avatar overlaps the bottom edge of the banner.

private struct ProfileCoverBanner: View {
    let user: User
    private let bannerHeight: CGFloat = 150
    private let avatarOverlap: CGFloat = 32

    var body: some View {
        ZStack(alignment: .bottom) {
            // Banner image or default gradient
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

            // Avatar overlapping banner bottom
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    imageURL: user.avatarURL,
                    emoji: SampleData.avatarEmoji(for: user.id),
                    size: .xlarge
                )
                .frame(width: 68, height: 68)
                .background(BelongColor.background)
                .clipShape(Circle())
                .overlay(Circle().stroke(BelongColor.background, lineWidth: 3))

                NavigationLink(value: ProfileRoute.editProfile) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(BelongColor.textOnPrimary)
                        .frame(width: 22, height: 22)
                        .background(BelongColor.primary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(BelongColor.background, lineWidth: 2))
                }
                .accessibilityLabel("Edit avatar")
            }
            .offset(y: avatarOverlap)
        }
        .padding(.bottom, avatarOverlap)
    }

    private var defaultGradient: some View {
        LinearGradient(
            colors: [
                BelongColor.primary.opacity(0.35),
                BelongColor.surfaceSecondary,
                BelongColor.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Compact Identity

private struct ProfileCompactIdentity: View {
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
        VStack(spacing: 1) {
            Text("\(count)")
                .font(BelongFont.bodySemiBold())
                .foregroundStyle(BelongColor.textPrimary)
            Text(label)
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Action Buttons (compact)

private struct ProfileActionButtons: View {
    var body: some View {
        NavigationLink(value: ProfileRoute.editProfile) {
            Text("Edit Profile")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusSm)
                        .stroke(BelongColor.border, lineWidth: 1)
                )
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Cultural Tags

private struct ProfileCulturalTags: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("Cultural Tags")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                Spacer()
                NavigationLink(value: ProfileRoute.editTags) {
                    Text("Edit")
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.primary)
                }
            }

            FlowLayout(spacing: Spacing.xs) {
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

// MARK: - Posts Grid (2-column 小红书-style)

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
            // Image — fixed height, fully clipped to prevent overflow
            postImage
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .clipped()
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: Layout.radiusMd,
                        topTrailingRadius: Layout.radiusMd
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(post.content)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: Spacing.sm) {
                    Label("\(post.likeCount)", systemImage: "heart")
                    Label("\(post.commentCount)", systemImage: "bubble.right")
                }
                .font(.system(size: 11))
                .foregroundStyle(BelongColor.textTertiary)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.sm)
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private var postImage: some View {
        if let image = post.coverImage {
            AsyncImage(url: image.imageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    cardPlaceholder
                }
            }
        } else {
            cardPlaceholder
        }
    }

    private var cardPlaceholder: some View {
        ZStack {
            BelongColor.surfaceSecondary
            Image(systemName: "text.quote")
                .font(.system(size: 20))
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
            VStack(spacing: 0) {
                SkeletonView(height: 150)
                SkeletonView(width: 68, height: 68, cornerRadius: 34)
                    .offset(y: -32)
                    .padding(.bottom, -24)
                SkeletonView(width: 140, height: 20)
                    .padding(.top, Spacing.sm)
                SkeletonView(width: 100, height: 14)
                    .padding(.top, Spacing.xs)
                SkeletonView(height: 34)
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.top, Spacing.md)
            }
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
