import SwiftUI

// MARK: - GatheringCard
// Spec: 20pt radius, 16:9 image, Level 1 shadow.
// UX Decision: Card shows cultural tags, attendee face pile, and spots remaining
// to help users quickly decide relevance. Bookmark toggle is always accessible.

struct GatheringCard: View {
    let gathering: Gathering
    var isCompact: Bool = false
    var onBookmarkToggle: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: gathering.imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                        case .failure:
                            imagePlaceholder
                        case .empty:
                            SkeletonView()
                                .aspectRatio(16/9, contentMode: .fill)
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                    .frame(height: isCompact ? 140 : 200)
                    .clipped()

                    // Bookmark button
                    if let onBookmarkToggle {
                        Button(action: onBookmarkToggle) {
                            Image(systemName: gathering.isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(gathering.isBookmarked ? BelongColor.primary : .white)
                                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(Spacing.sm)
                        .accessibilityLabel(gathering.isBookmarked ? "Remove bookmark" : "Bookmark this gathering")
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Cultural tags
                    if !gathering.culturalTags.isEmpty {
                        HStack(spacing: Spacing.xs) {
                            ForEach(gathering.culturalTags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(BelongFont.captionMedium())
                                    .foregroundStyle(BelongColor.primary)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(BelongColor.accent)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    // Title
                    Text(gathering.title)
                        .font(isCompact ? BelongFont.bodyMedium() : BelongFont.h2())
                        .foregroundStyle(BelongColor.textPrimary)
                        .lineLimit(2)

                    // Date & location
                    HStack(spacing: Spacing.base) {
                        Label(gathering.date.formatted(.dateTime.month(.abbreviated).day().hour().minute()),
                              systemImage: "calendar")
                        Label(gathering.location, systemImage: "mappin")
                            .lineLimit(1)
                    }
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)

                    // Bottom row: avatars + spots
                    HStack {
                        // Attendee face pile
                        HStack(spacing: -8) {
                            ForEach(Array(gathering.attendeeAvatars.prefix(5).enumerated()), id: \.offset) { _, emoji in
                                Text(emoji)
                                    .font(.system(size: 16))
                                    .frame(width: 28, height: 28)
                                    .background(BelongColor.surfaceSecondary)
                                    .clipShape(Circle())
                                    .overlay(Circle().strokeBorder(BelongColor.surface, lineWidth: 2))
                            }
                        }
                        .accessibilityLabel("\(gathering.attendeeCount) attendees")

                        Spacer()

                        // Spots indicator
                        Text(gathering.formattedSpotsText)
                            .font(BelongFont.captionMedium())
                            .foregroundStyle(gathering.spotsRemaining <= 3 ? BelongColor.warning : BelongColor.textSecondary)
                    }
                }
                .padding(Spacing.base)
            }
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusXl))
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(gathering.title), \(gathering.location), \(gathering.formattedSpotsText)")
        .accessibilityAddTraits(.isButton)
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(BelongColor.skeleton)
            .overlay {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(BelongColor.textTertiary)
            }
    }
}

#Preview("Gathering Card") {
    ScrollView {
        VStack(spacing: 16) {
            GatheringCard(gathering: SampleData.topPick, onBookmarkToggle: {}, onTap: {})
            GatheringCard(gathering: SampleData.gatherings[1], isCompact: true, onTap: {})
        }
        .padding()
    }
    .background(BelongColor.background)
}
