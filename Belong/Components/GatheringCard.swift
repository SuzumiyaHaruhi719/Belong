import SwiftUI

struct GatheringCard: View {
    let gathering: Gathering
    var onBookmarkToggle: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GatheringCardImage(
                imageURL: gathering.imageURL,
                emoji: gathering.emoji,
                tags: gathering.tags,
                isBookmarked: gathering.isBookmarked,
                onBookmarkToggle: onBookmarkToggle
            )
            GatheringCardBody(gathering: gathering)
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

struct GatheringCardImage: View {
    let imageURL: URL?
    let emoji: String
    let tags: [String]
    let isBookmarked: Bool
    var onBookmarkToggle: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        GatheringCardImagePlaceholder(emoji: emoji)
                    }
                }
            } else {
                GatheringCardImagePlaceholder(emoji: emoji)
            }
        }
        .frame(height: Layout.cardImageHeight)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(alignment: .bottomLeading) {
            GatheringCardTagRow(tags: tags)
        }
        .overlay(alignment: .topTrailing) {
            GatheringCardBookmarkButton(
                isBookmarked: isBookmarked,
                action: onBookmarkToggle
            )
        }
    }
}

struct GatheringCardImagePlaceholder: View {
    let emoji: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [BelongColor.primaryMuted.opacity(0.4), BelongColor.surfaceSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(emoji)
                .font(.system(size: 52))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GatheringCardTagRow: View {
    let tags: [String]

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(tags.prefix(3), id: \.self) { tag in
                ChipView(title: tag, isSelected: true)
            }
        }
        .padding(Spacing.sm)
    }
}

struct GatheringCardBookmarkButton: View {
    let isBookmarked: Bool
    var action: (() -> Void)?

    var body: some View {
        if let action = action {
            Button(action: action) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isBookmarked ? BelongColor.primary : .white)
                    .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(Spacing.sm)
            .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark gathering")
        }
    }
}

struct GatheringCardBody: View {
    let gathering: Gathering

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(gathering.title)
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)
                .lineLimit(2)

            GatheringCardHostRow(
                hostName: gathering.hostName,
                hostEmoji: gathering.hostAvatarEmoji
            )

            GatheringCardInfoRow(gathering: gathering)

            GatheringCardFooter(gathering: gathering)
        }
        .padding(.horizontal, Spacing.base)
        .padding(.vertical, Spacing.md)
    }
}

struct GatheringCardHostRow: View {
    let hostName: String
    let hostEmoji: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            AvatarView(emoji: hostEmoji, size: .small)
            Text(hostName)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

struct GatheringCardInfoRow: View {
    let gathering: Gathering

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d 'at' h:mm a"
        return formatter.string(from: gathering.startsAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(dateText, systemImage: "calendar")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
            Label(gathering.locationName, systemImage: "mappin.and.ellipse")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
                .lineLimit(1)
        }
    }
}

struct GatheringCardFooter: View {
    let gathering: Gathering

    var body: some View {
        HStack {
            GatheringCardFacePile(avatarEmojis: gathering.attendeeAvatars)
            Spacer()
            Text(gathering.formattedSpots)
                .font(BelongFont.captionMedium())
                .foregroundStyle(
                    gathering.isFull ? BelongColor.error :
                    gathering.spotsRemaining <= 3 ? BelongColor.warning :
                    BelongColor.textSecondary
                )
        }
    }
}

struct GatheringCardFacePile: View {
    let avatarEmojis: [String]

    var body: some View {
        HStack(spacing: -8) {
            ForEach(Array(avatarEmojis.prefix(5).enumerated()), id: \.offset) { index, emoji in
                AvatarView(emoji: emoji, size: .small)
                    .overlay(Circle().stroke(BelongColor.surface, lineWidth: 2))
                    .zIndex(Double(5 - index))
            }
        }
    }
}

#Preview {
    let sample = Gathering(
        id: "1",
        hostId: "u1",
        title: "Korean BBQ Night",
        description: "Let's enjoy some galbi together!",
        templateType: .food,
        emoji: "🥩",
        imageURL: nil,
        city: "Los Angeles",
        school: "UCLA",
        locationName: "Kang Ho-dong Baekjeong",
        latitude: nil,
        longitude: nil,
        startsAt: Date().addingTimeInterval(86400),
        endsAt: nil,
        maxAttendees: 8,
        visibility: .open,
        vibe: .welcoming,
        status: .upcoming,
        isDraft: false,
        tags: ["Korean", "Food", "Social"],
        attendeeCount: 5,
        attendeeAvatars: ["🧑‍🍳", "🎎", "🌸", "🎭", "🎵"],
        hostName: "Min-Jun",
        hostAvatarEmoji: "🧑‍🍳",
        hostRating: 4.8,
        isBookmarked: false,
        isJoined: false,
        isMaybe: false,
        createdAt: Date()
    )
    return GatheringCard(gathering: sample, onBookmarkToggle: {})
        .padding()
        .background(BelongColor.background)
}
