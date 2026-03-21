import SwiftUI

struct UserPostsScreen: View {
    enum Mode {
        case user(String)      // userId
        case hashtag(String)   // tag name without #
    }

    let mode: Mode
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: PostsFeedViewModel?

    private var navTitle: String {
        switch mode {
        case .user: return "Posts"
        case .hashtag(let tag): return "#\(tag)"
        }
    }

    private var filterValue: String? {
        switch mode {
        case .user: return nil
        case .hashtag(let tag): return tag
        }
    }

    var body: some View {
        Group {
            if let vm = viewModel {
                UserPostsContent(viewModel: vm, mode: mode)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = PostsFeedViewModel(container: container)
                vm.selectedFilter = filterValue
                viewModel = vm
                await vm.loadFeed()
            }
        }
    }
}

// MARK: - Content

private struct UserPostsContent: View {
    @Bindable var viewModel: PostsFeedViewModel
    let mode: UserPostsScreen.Mode

    var body: some View {
        if viewModel.isLoading && viewModel.posts.isEmpty {
            UserPostsSkeleton()
        } else if let error = viewModel.error, viewModel.posts.isEmpty {
            ErrorStateView(message: error, onRetry: {
                Task { await viewModel.loadFeed() }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.posts.isEmpty {
            EmptyStateView(
                icon: "square.and.pencil",
                title: "No posts yet",
                message: emptyMessage
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            UserPostsList(viewModel: viewModel)
        }
    }

    private var emptyMessage: String {
        switch mode {
        case .user: return "This user hasn't shared any posts yet."
        case .hashtag(let tag): return "No posts tagged with #\(tag) yet."
        }
    }
}

// MARK: - Posts List

private struct UserPostsList: View {
    @Bindable var viewModel: PostsFeedViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.base) {
                ForEach(viewModel.posts) { post in
                    NavigationLink(value: PostsRoute.detail(post)) {
                        PostCard(
                            post: post,
                            onLike: { viewModel.toggleLike(postId: post.id) },
                            onComment: nil,
                            onBookmark: { viewModel.toggleSave(postId: post.id) }
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if post.id == viewModel.posts.last?.id {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding(Spacing.lg)
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.base)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Skeleton

private struct UserPostsSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.base) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonCard()
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.base)
        }
    }
}

// MARK: - Preview

#Preview("Hashtag") {
    NavigationStack {
        UserPostsScreen(mode: .hashtag("FoodieLife"))
            .environment(DependencyContainer())
    }
}

#Preview("User Posts") {
    NavigationStack {
        UserPostsScreen(mode: .user(SampleData.userIdMai))
            .environment(DependencyContainer())
    }
}
