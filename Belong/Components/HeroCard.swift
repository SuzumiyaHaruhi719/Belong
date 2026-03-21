import SwiftUI

struct HeroCard: View {
    let gathering: Gathering
    var mutualFriendsCount: Int = 0
    var onBookmarkToggle: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeroCardImage(
                imageURL: gathering.imageURL,
                emoji: gathering.emoji,
                tags: gathering.tags,
                isBookmarked: gathering.isBookmarked,
                onBookmarkToggle: onBookmarkToggle
            )
            HeroCardBody(
                gathering: gathering,
                mutualFriendsCount: mutualFriendsCount
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

struct HeroCardImage: View {
    let imageURL: URL?
    let emoji: String
    let tags: [String]
    let isBookmarked: Bool
    var onBookmarkToggle: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topLeading) {
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
        .frame(height: Layout.heroImageHeight)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(alignment: .topLeading) {
            HeroCardBadge()
        }
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

struct HeroCardBadge: View {
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
            Text("Top pick for you")
                .font(BelongFont.captionMedium())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(BelongColor.gold)
        .clipShape(Capsule())
        .padding(Spacing.sm)
    }
}

struct HeroCardBody: View {
    let gathering: Gathering
    let mutualFriendsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(gathering.title)
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .lineLimit(2)

            GatheringCardHostRow(
                hostName: gathering.hostName,
                hostEmoji: gathering.hostAvatarEmoji
            )

            GatheringCardInfoRow(gathering: gathering)

            HeroCardTrustSignals(
                mutualFriendsCount: mutualFriendsCount,
                hostRating: gathering.hostRating
            )

            GatheringCardFooter(gathering: gathering)
        }
        .padding(Spacing.base)
    }
}

struct HeroCardTrustSignals: View {
    let mutualFriendsCount: Int
    let hostRating: Double

    var body: some View {
        HStack(spacing: Spacing.base) {
            if mutualFriendsCount > 0 {
                Label(
                    "\(mutualFriendsCount) mutual friend\(mutualFriendsCount == 1 ? "" : "s") attending",
                    systemImage: "person.2.fill"
                )
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.sage)
            }
            if hostRating > 0 {
                Label(
                    String(format: "%.1f", hostRating),
                    systemImage: "star.fill"
                )
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.gold)
            }
        }
    }
}

#Preview {
    let sample = Gathering(
        id: "1",
        hostId: "u1",
        title: "Lunar New Year Celebration",
        description: "Ring in the Year of the Dragon!",
        templateType: .cultural,
        emoji: "🧧",
        imageURL: nil,
        city: "San Francisco",
        school: "UC Berkeley",
        locationName: "Asian Art Museum",
        latitude: nil,
        longitude: nil,
        startsAt: Date().addingTimeInterval(86400 * 3),
        endsAt: nil,
        maxAttendees: 30,
        visibility: .open,
        vibe: .hype,
        status: .upcoming,
        isDraft: false,
        tags: ["Chinese", "Cultural", "Holiday"],
        attendeeCount: 22,
        attendeeAvatars: ["🧧", "🐉", "🎊", "🏮", "🎆"],
        hostName: "Amy Chen",
        hostAvatarEmoji: "🧧",
        hostRating: 4.9,
        isBookmarked: true,
        isJoined: false,
        isMaybe: false,
        createdAt: Date()
    )
    return HeroCard(gathering: sample, mutualFriendsCount: 3, onBookmarkToggle: {})
        .padding()
        .background(BelongColor.background)
}
