import SwiftUI

// MARK: - PostsFeedScreen
// 小红书-style 2-column waterfall grid for posts.
//
// UX Decisions (UI/UX Pro Max + SwiftUI Pro):
// - 2-column grid maximizes content density — users see 4-6 posts per screen.
// - Compact cards: image + 2-line text + minimal stats.
// - Filter chips ALWAYS visible at top — never disappear during loading.
// - Pull-to-refresh + infinite scroll pagination.
// - Cards have fixed image height + clipped to prevent overflow/stacking.

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
// UX: Filter chips are pinned at top OUTSIDE the scrollable content area.
// They never disappear regardless of loading/error/empty state.
// A subtle divider separates chips from content for visual clarity.

private struct PostsFeedContent: View {
    @Bindable var viewModel: PostsFeedViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips — always visible, pinned outside ScrollView
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

            Rectangle()
                .fill(BelongColor.divider)
                .frame(height: 0.5)

            // Content area — scrollable, switches based on state
            // Show grid if we have posts (even while loading new filter results)
            if !viewModel.posts.isEmpty {
                PostsFeedGrid(viewModel: viewModel)
            } else if viewModel.isLoading {
                PostsFeedSkeleton()
            } else if let error = viewModel.error {
                ErrorStateView(message: error, onRetry: {
                    Task { await viewModel.loadFeed() }
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                EmptyStateView(
                    icon: "square.and.pencil",
                    title: "No posts yet",
                    message: "Follow people or explore tags to see posts in your feed."
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
    }
}

// MARK: - 2-Column Grid Feed

private struct PostsFeedGrid: View {
    @Bindable var viewModel: PostsFeedViewModel

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
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
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)

            if viewModel.isLoadingMore {
                ProgressView()
                    .padding(Spacing.lg)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Compact Post Card
// UX: Each card is a self-contained unit with FIXED dimensions to prevent
// overflow. The image uses a fixed aspect ratio container with clipping.
// Text body has consistent padding and line limits.
// Key fix: .frame().clipped() on the image container prevents scaledToFill
// from bleeding into adjacent grid cells.

private struct CompactPostCard: View {
    let post: Post
    var onLike: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image — Color.clear sets the LAYOUT height, overlay fills it,
            // .clipped() trims any overflow. This is the only reliable way
            // to prevent scaledToFill from expanding the layout frame.
            Color.clear
                .frame(height: 160)
                .overlay {
                    postImageView
                }
                .clipped()

            // Text body
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    AvatarView(
                        imageURL: post.authorAvatarURL,
                        emoji: post.authorAvatarEmoji,
                        size: .small
                    )
                    .frame(width: 18, height: 18)
                    .clipShape(Circle())

                    Text(post.authorName)
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineLimit(1)
                }

                Text(post.content)
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: Spacing.md) {
                    Button(action: { onLike?() }) {
                        Label {
                            if post.likeCount > 0 { Text("\(post.likeCount)") }
                        } icon: {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        }
                        .foregroundStyle(post.isLiked ? BelongColor.error : BelongColor.textTertiary)
                    }
                    .buttonStyle(.plain)

                    Label {
                        if post.commentCount > 0 { Text("\(post.commentCount)") }
                    } icon: {
                        Image(systemName: "bubble.left")
                    }
                    .foregroundStyle(BelongColor.textTertiary)

                    Spacer()
                }
                .font(.system(size: 11))
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.sm)
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(post.authorName): \(post.content)")
    }

    @ViewBuilder
    private var postImageView: some View {
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

    private var cardPlaceholder: some View {
        ZStack {
            BelongColor.surfaceSecondary
            Image(systemName: "text.quote")
                .font(.system(size: 20))
                .foregroundStyle(BelongColor.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Skeleton (2-column)

private struct PostsFeedSkeleton: View {
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(0..<6, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 0) {
                        SkeletonView(height: 160)
                        VStack(alignment: .leading, spacing: 6) {
                            SkeletonView(width: 60, height: 12)
                            SkeletonView(height: 14)
                            SkeletonView(width: 80, height: 11)
                        }
                        .padding(Spacing.sm)
                    }
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.md)
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
