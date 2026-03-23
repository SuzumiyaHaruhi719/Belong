import SwiftUI

struct SavedPostsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                SavedPostsContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Saved Posts")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = ProfileViewModel(userService: container.userService)
                vm.postService = container.postService
                viewModel = vm
            }
            await viewModel?.loadSaved()
        }
        .onAppear {
            if viewModel != nil {
                Task { await viewModel?.loadSaved() }
            }
        }
    }
}

// MARK: - Content

private struct SavedPostsContent: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.savedPosts.isEmpty {
                ScrollView {
                    VStack(spacing: Spacing.base) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonCard()
                        }
                    }
                    .padding(Layout.screenPadding)
                }
            } else if let error = viewModel.error, viewModel.savedPosts.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadSaved() }
                }
            } else if viewModel.savedPosts.isEmpty {
                EmptyStateView(
                    icon: "bookmark",
                    title: "Nothing saved yet",
                    message: "Tap the bookmark icon on any post to save it for later."
                )
            } else {
                List {
                    ForEach(viewModel.savedPosts) { post in
                        NavigationLink(value: PostsRoute.detail(post)) {
                            PostCard(post: post)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(
                            top: Spacing.sm,
                            leading: Layout.screenPadding,
                            bottom: Spacing.sm,
                            trailing: Layout.screenPadding
                        ))
                    }
                    .onDelete { offsets in
                        viewModel.removeSavedPost(at: offsets)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SavedPostsScreen()
    }
    .environment(DependencyContainer())
}
