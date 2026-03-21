import SwiftUI

struct PostCommentsScreen: View {
    let postId: String
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: PostDetailViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                PostCommentsContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = PostDetailViewModel(container: container)
                viewModel = vm
                await vm.loadDetail(id: postId)
            }
        }
    }
}

// MARK: - Comments Content

private struct PostCommentsContent: View {
    @Bindable var viewModel: PostDetailViewModel

    var body: some View {
        if viewModel.isLoading && viewModel.comments.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.error, viewModel.comments.isEmpty {
            ErrorStateView(message: error, onRetry: {
                Task { await viewModel.loadComments() }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 0) {
                PostCommentsScrollContent(viewModel: viewModel)
                PostCommentsComposer(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Scroll Content

private struct PostCommentsScrollContent: View {
    @Bindable var viewModel: PostDetailViewModel

    var body: some View {
        if viewModel.comments.isEmpty {
            VStack {
                Spacer()
                EmptyStateView(
                    icon: "bubble.left.and.bubble.right",
                    title: "No comments yet",
                    message: "Be the first to share your thoughts!"
                )
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.base) {
                    ForEach(viewModel.comments) { comment in
                        PostCommentRow(comment: comment, indentLevel: 0)
                    }
                }
                .padding(Layout.screenPadding)
            }
        }
    }
}

// MARK: - Comment Composer

private struct PostCommentsComposer: View {
    @Bindable var viewModel: PostDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundStyle(BelongColor.divider)
            HStack(spacing: Spacing.md) {
                AvatarView(emoji: "😊", size: .small)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())

                TextField("Add a comment...", text: $viewModel.newCommentText)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)

                Button(action: { Task { await viewModel.addComment() } }) {
                    Text("Post")
                        .font(BelongFont.secondaryMedium())
                        .foregroundStyle(
                            viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? BelongColor.disabled
                                : BelongColor.primary
                        )
                }
                .disabled(
                    viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || viewModel.isPostingComment
                )
                .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)
            .background(BelongColor.surface)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PostCommentsScreen(postId: SampleData.postIdPhoRecipe)
            .environment(DependencyContainer())
    }
}
