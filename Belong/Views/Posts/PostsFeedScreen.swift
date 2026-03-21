import SwiftUI

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
        .navigationTitle("Community")
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
                PostsFeedList(viewModel: viewModel)
            }
        }
        .background(BelongColor.background)
    }
}

// MARK: - Feed List

private struct PostsFeedList: View {
    @Bindable var viewModel: PostsFeedViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
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
                .padding(.bottom, Spacing.xxl)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Skeleton

private struct PostsFeedSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.base) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonCard()
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
