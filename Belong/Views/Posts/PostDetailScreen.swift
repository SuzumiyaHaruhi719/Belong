import SwiftUI

struct PostDetailScreen: View {
    let post: Post
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: PostDetailViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                PostDetailContent(viewModel: vm, post: post)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = PostDetailViewModel(container: container)
                viewModel = vm
                await vm.loadDetail(id: post.id)
            }
        }
    }
}

// MARK: - Detail Content

private struct PostDetailContent: View {
    @Bindable var viewModel: PostDetailViewModel
    let post: Post

    private var displayPost: Post { viewModel.post ?? post }

    var body: some View {
        if viewModel.isLoading && viewModel.post == nil {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.error, viewModel.post == nil {
            ErrorStateView(message: error, onRetry: {
                Task { await viewModel.loadDetail(id: post.id) }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 0) {
                PostDetailScrollContent(viewModel: viewModel, post: displayPost)
                PostDetailCommentComposer(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Scroll Content

private struct PostDetailScrollContent: View {
    @Bindable var viewModel: PostDetailViewModel
    let post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image carousel
                if !post.images.isEmpty {
                    let urls = post.images
                        .sorted { $0.displayOrder < $1.displayOrder }
                        .map(\.imageURL)
                    ImageCarousel(imageURLs: urls)
                        .frame(height: Layout.heroImageHeight)
                }

                VStack(alignment: .leading, spacing: Spacing.base) {
                    // Author row
                    PostDetailAuthorRow(post: post)

                    // Content with hashtag highlighting
                    PostDetailContentText(content: post.content, tags: post.tags)

                    // Cultural tag chips
                    if !post.tags.isEmpty {
                        PostDetailTagChips(tags: post.tags)
                    }

                    // Action bar
                    PostDetailActionBar(viewModel: viewModel, post: post)

                    // Linked gathering button
                    if let gatheringTitle = post.linkedGatheringTitle, post.linkedGatheringId != nil {
                        BelongButton(
                            title: "View Gathering: \(gatheringTitle)",
                            style: .secondary,
                            isFullWidth: true,
                            leadingIcon: "calendar",
                            action: {}
                        )
                    }

                    Divider()
                        .foregroundStyle(BelongColor.divider)

                    // Comments section
                    PostDetailCommentsSection(viewModel: viewModel, post: post)
                }
                .padding(Layout.screenPadding)
            }
        }
    }
}

// MARK: - Author Row

private struct PostDetailAuthorRow: View {
    let post: Post

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(imageURL: post.authorAvatarURL, emoji: post.authorAvatarEmoji, size: .medium)
                .frame(width: 36, height: 36)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(post.authorName)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                Text("@\(post.authorUsername)")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
            }

            Spacer()

            Button(action: {}) {
                Text("Follow")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.primary)
                    .padding(.horizontal, Spacing.md)
                    .frame(height: 34)
                    .background(BelongColor.surfaceSecondary)
                    .clipShape(Capsule())
            }
            .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
        }
    }
}

// MARK: - Content Text with Hashtag Highlighting

private struct PostDetailContentText: View {
    let content: String
    let tags: [String]

    var body: some View {
        Text(attributedContent)
            .font(BelongFont.body())
            .foregroundStyle(BelongColor.textPrimary)
            .lineSpacing(4)
    }

    private var attributedContent: AttributedString {
        var result = AttributedString(content)
        for tag in tags {
            let hashTag = "#\(tag)"
            var searchRange = result.startIndex..<result.endIndex
            while let range = result[searchRange].range(of: hashTag) {
                result[range].foregroundColor = UIColor(BelongColor.primary)
                result[range].font = UIFont.systemFont(ofSize: 16, weight: .medium)
                if range.upperBound < result.endIndex {
                    searchRange = range.upperBound..<result.endIndex
                } else {
                    break
                }
            }
        }
        return result
    }
}

// MARK: - Tag Chips

private struct PostDetailTagChips: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: Spacing.sm, data: tags) { tag in
            ChipView(title: tag, isSelected: true)
        }
    }
}

// MARK: - Action Bar

private struct PostDetailActionBar: View {
    @Bindable var viewModel: PostDetailViewModel
    let post: Post

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Like
            Button(action: { viewModel.toggleLike() }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                    if post.likeCount > 0 {
                        Text("\(post.likeCount)")
                            .font(BelongFont.secondary())
                    }
                }
                .foregroundStyle(post.isLiked ? BelongColor.error : BelongColor.textSecondary)
            }
            .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
            .accessibilityLabel("Like")

            // Comments
            NavigationLink(value: PostsRoute.comments(post.id)) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 20))
                    if post.commentCount > 0 {
                        Text("\(post.commentCount)")
                            .font(BelongFont.secondary())
                    }
                }
                .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
            .accessibilityLabel("Comments")

            // Bookmark
            Button(action: { viewModel.toggleSave() }) {
                Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundStyle(post.isSaved ? BelongColor.primary : BelongColor.textSecondary)
            }
            .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
            .accessibilityLabel("Bookmark")

            Spacer()

            // Share
            ShareLink(item: "Check out this post on Belong!") {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
            .accessibilityLabel("Share")
        }
    }
}

// MARK: - Comments Section

private struct PostDetailCommentsSection: View {
    @Bindable var viewModel: PostDetailViewModel
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Comments")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            if viewModel.comments.isEmpty {
                Text("No comments yet -- be the first!")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textTertiary)
                    .padding(.vertical, Spacing.base)
            } else {
                ForEach(viewModel.comments.prefix(3)) { comment in
                    PostCommentRow(comment: comment, indentLevel: 0)
                }

                if viewModel.comments.count > 3 {
                    NavigationLink(value: PostsRoute.comments(post.id)) {
                        Text("View all \(post.commentCount) comments")
                            .font(BelongFont.secondaryMedium())
                            .foregroundStyle(BelongColor.primary)
                    }
                    .frame(minHeight: Layout.touchTargetMin)
                }
            }
        }
    }
}

// MARK: - Comment Composer

private struct PostDetailCommentComposer: View {
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

// MARK: - Shared Comment Row

struct PostCommentRow: View {
    let comment: PostComment
    let indentLevel: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                AvatarView(emoji: comment.authorAvatarEmoji, size: .small)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: Spacing.xs) {
                        Text(comment.authorUsername)
                            .font(BelongFont.captionMedium())
                            .foregroundStyle(BelongColor.textPrimary)
                        Text(comment.createdAt.postTimeAgo)
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.textTertiary)
                    }
                    Text(comment.content)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textPrimary)

                    HStack(spacing: Spacing.md) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 12))
                            if comment.likeCount > 0 {
                                Text("\(comment.likeCount)")
                                    .font(BelongFont.caption())
                            }
                        }
                        .foregroundStyle(comment.isLiked ? BelongColor.error : BelongColor.textTertiary)

                        if indentLevel == 0 {
                            Text("Reply")
                                .font(BelongFont.captionMedium())
                                .foregroundStyle(BelongColor.textTertiary)
                        }
                    }
                }
            }

            // Show nested replies (max 1 level)
            if indentLevel == 0, let replies = comment.replies, !replies.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    ForEach(replies) { reply in
                        PostCommentRow(comment: reply, indentLevel: 1)
                    }
                }
                .padding(.leading, Spacing.xl)
            }
        }
    }
}

// MARK: - Date Formatting

extension Date {
    var postTimeAgo: String {
        let interval = Date().timeIntervalSince(self)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "now" }
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h" }
        let days = hours / 24
        if days < 7 { return "\(days)d" }
        let weeks = days / 7
        return "\(weeks)w"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PostDetailScreen(post: SampleData.posts[0])
            .environment(DependencyContainer())
    }
}
