import SwiftUI

struct PostCard: View {
    let post: Post
    var onLike: (() -> Void)? = nil
    var onComment: (() -> Void)? = nil
    var onBookmark: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PostCardCoverImage(coverImage: post.coverImage)
            PostCardContent(
                post: post,
                onLike: onLike,
                onComment: onComment,
                onBookmark: onBookmark
            )
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
        .shadow(
            color: BelongShadow.level1.color,
            radius: BelongShadow.level1.radius,
            x: BelongShadow.level1.x,
            y: BelongShadow.level1.y
        )
    }
}

struct PostCardCoverImage: View {
    let coverImage: PostImage?

    var body: some View {
        if let image = coverImage {
            AsyncImage(url: image.imageURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Rectangle().fill(BelongColor.skeleton)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: Layout.cardImageHeight)
            .clipped()
        }
    }
}

struct PostCardContent: View {
    let post: Post
    var onLike: (() -> Void)?
    var onComment: (() -> Void)?
    var onBookmark: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            PostCardAuthorRow(
                name: post.authorName,
                emoji: post.authorAvatarEmoji,
                avatarURL: post.authorAvatarURL
            )
            Text(post.content)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textPrimary)
                .lineLimit(2)

            if !post.tags.isEmpty {
                PostCardTagRow(tags: post.tags)
            }

            PostCardActionRow(
                likeCount: post.likeCount,
                commentCount: post.commentCount,
                isLiked: post.isLiked,
                isSaved: post.isSaved,
                onLike: onLike,
                onComment: onComment,
                onBookmark: onBookmark
            )
        }
        .padding(Spacing.base)
    }
}

struct PostCardAuthorRow: View {
    let name: String
    let emoji: String
    let avatarURL: URL?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            AvatarView(imageURL: avatarURL, emoji: emoji, size: .small)
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            Text(name)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)
        }
    }
}

struct PostCardTagRow: View {
    let tags: [String]

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(tags.prefix(3), id: \.self) { tag in
                ChipView(title: tag, isSelected: true)
            }
        }
    }
}

struct PostCardActionRow: View {
    let likeCount: Int
    let commentCount: Int
    let isLiked: Bool
    let isSaved: Bool
    var onLike: (() -> Void)?
    var onComment: (() -> Void)?
    var onBookmark: (() -> Void)?

    var body: some View {
        HStack(spacing: Spacing.lg) {
            PostCardActionButton(
                icon: isLiked ? "heart.fill" : "heart",
                count: likeCount,
                tint: isLiked ? BelongColor.error : BelongColor.textSecondary,
                label: "Like",
                action: onLike
            )
            PostCardActionButton(
                icon: "bubble.left",
                count: commentCount,
                tint: BelongColor.textSecondary,
                label: "Comment",
                action: onComment
            )
            Spacer()
            PostCardActionButton(
                icon: isSaved ? "bookmark.fill" : "bookmark",
                count: nil,
                tint: isSaved ? BelongColor.primary : BelongColor.textSecondary,
                label: "Bookmark",
                action: onBookmark
            )
        }
    }
}

struct PostCardActionButton: View {
    let icon: String
    let count: Int?
    let tint: Color
    let label: String
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(BelongFont.caption())
                }
            }
            .foregroundStyle(tint)
            .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    let sample = Post(
        id: "1",
        authorId: "u1",
        content: "Just had the most amazing dumpling-making session with friends. Nothing beats handmade dumplings from scratch!",
        images: [],
        tags: ["Chinese", "Food", "Cooking"],
        visibility: .publicPost,
        city: "San Francisco",
        likeCount: 24,
        commentCount: 8,
        saveCount: 3,
        isLiked: true,
        isSaved: false,
        createdAt: Date(),
        authorName: "Wei Lin",
        authorUsername: "weilin",
        authorAvatarEmoji: "🥟"
    )
    return PostCard(post: sample, onLike: {}, onComment: {}, onBookmark: {})
        .padding()
        .background(BelongColor.background)
}
