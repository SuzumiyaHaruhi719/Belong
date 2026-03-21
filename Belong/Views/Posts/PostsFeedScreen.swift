import SwiftUI

// MARK: - PostsFeedScreen
// 小红书-style 2-column waterfall grid for posts.
//
// UX Decisions (UI/UX Pro Max + SwiftUI Pro):
// - 2-column grid maximizes content density — users see 4-6 posts per screen
//   vs. 1-2 with full-width cards. This is the standard pattern for visual
//   social feeds (小红书, Pinterest, Instagram Explore).
// - Compact cards: image + 2-line text + minimal stats. No author row on feed
//   cards — saves vertical space. Author shows on detail tap.
// - Filter chips at top for tag-based browsing (Food, Music, etc.)
// - Pull-to-refresh + infinite scroll pagination.
// - Cards have slight shadow + rounded corners for depth without clutter.

struct PostsFeedScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: PostsFeedViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                PostsFeedContent(viewModel: vm)
            } else {
                Color.clear
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = PostsFeedViewModel(container: container)
                viewModel = vm
                await vm.loadFeed()
            }
        }
    }
}

// MARK: - Feed Content

private struct PostsFeedContent: View {
    @Bindable var viewModel: PostsFeedViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                PostsFeedSkeleton()
            } else if let error = viewModel.error, viewModel.posts.isEmpty {
                ErrorStateView(message: error, onRetry: {
                    Task { await viewModel.loadFeed() }
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.posts.isEmpty {
                EmptyStateView(
                    icon: "square.and.pencil",
                    title: "No posts yet",
                    message: "Follow people or explore tags to see posts in your feed."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                PostsFeedGrid(viewModel: viewModel)
            }
        }
        .background(BelongColor.background)
    }
}

// MARK: - 2-Column Grid Feed
// UX: LazyVGrid with 2 flexible columns. Each card is self-sizing
// based on image aspect ratio + text content, creating a natural
// waterfall flow. Min spacing of 10pt between cards (touch-safe).

private struct PostsFeedGrid: View {
    @Bindable var viewModel: PostsFeedViewModel

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Filter chips
                FilterChipRow(
                    filters: viewModel.filterOptions,
                    selected: Binding(
                        get: { viewModel.selectedFilterBinding },
                        set: { newValue in
                            viewModel.selectedFilterBinding = newValue
                            Task { await viewModel.loadFeed() }
                        }
                    )
                )
                .padding(.vertical, Spacing.sm)

                // 2-column grid
                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(viewModel.posts) { post in
                        NavigationLink(value: PostsRoute.detail(post)) {
                            CompactPostCard(
                                post: post,
                                onLike: { viewModel.toggleLike(postId: post.id) }
                            )
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if post.id == viewModel.posts.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xxl)

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding(Spacing.lg)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Compact Post Card (for 2-column grid)
// UX: Optimized for small card size — image takes most of the space,
// text is limited to 2 lines, stats are tiny. Author avatar is a
// small overlay on the image bottom-left for recognition without
// taking card body space. This mirrors 小红书's card pattern exactly.

private struct CompactPostCard: View {
    let post: Post
    var onLike: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image area
            ZStack(alignment: .bottomLeading) {
                if let image = post.coverImage {
                    AsyncImage(url: image.imageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            cardPlaceholder
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .clipped()
                } else {
                    cardPlaceholder
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                }

                // Author avatar overlay (small, bottom-left)
                HStack(spacing: 4) {
                    AvatarView(
                        imageURL: post.authorAvatarURL,
                        emoji: post.authorAvatarEmoji,
                        size: .small
                    )
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(BelongColor.surface, lineWidth: 1))

                    Text(post.authorName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.bottom, Spacing.sm)
            }

            // Text + stats
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(post.content)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Compact stats row
                HStack(spacing: Spacing.sm) {
                    HStack(spacing: 2) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 11))
                            .foregroundStyle(post.isLiked ? BelongColor.error : BelongColor.textTertiary)
                        if post.likeCount > 0 {
                            Text("\(post.likeCount)")
                                .font(.system(size: 10))
                                .foregroundStyle(BelongColor.textTertiary)
                        }
                    }
                    .onTapGesture { onLike?() }

                    HStack(spacing: 2) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 11))
                        if post.commentCount > 0 {
                            Text("\(post.commentCount)")
                                .font(.system(size: 10))
                        }
                    }
                    .foregroundStyle(BelongColor.textTertiary)

                    Spacer()
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.sm)
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(post.authorName): \(post.content)")
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

// MARK: - Skeleton (2-column)

private struct PostsFeedSkeleton: View {
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                ForEach(0..<6, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 0) {
                        SkeletonView(height: 140)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            SkeletonView(height: 14)
                            SkeletonView(width: 80, height: 12)
                        }
                        .padding(Spacing.sm)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.base)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PostsFeedScreen()
            .environment(DependencyContainer())
    }
}
