import SwiftUI

// MARK: - Profile Activity Section
// The "what I've done" tab: browsing history + event join history.
//
// UX Decisions:
// - Browsing history shows recently viewed gatherings with a "Clear all" option
//   for privacy. Each item is swipe-deletable for granular control.
// - Join history is a timeline showing confirmed, attended, and cancelled events.
// - Unrated attended events show a subtle "Rate" badge — inviting but not pushy.
// - Status badges use color coding: green (confirmed), sage (attended),
//   gray (cancelled) for quick scanning.
// - Empty states are specific per subsection, not generic.

struct ProfileActivitySection: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // MARK: Browsing History
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Recently viewed")
                        .font(BelongFont.h2())
                        .foregroundStyle(BelongColor.textPrimary)

                    Spacer()

                    if !viewModel.browsingHistory.isEmpty {
                        Button("Clear all") {
                            withAnimation { viewModel.clearBrowsingHistory() }
                        }
                        .font(BelongFont.captionMedium())
                        .foregroundStyle(BelongColor.textTertiary)
                    }
                }

                if viewModel.browsingHistory.isEmpty {
                    EmptyStateView(
                        systemImage: "eye",
                        title: "No browsing history",
                        message: "Gatherings you view will appear here"
                    )
                    .frame(height: 120)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.md) {
                            ForEach(viewModel.browsingHistory) { item in
                                BrowsingHistoryCard(item: item)
                            }
                        }
                    }
                }
            }

            // MARK: Event Join History
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Events joined")
                    .font(BelongFont.h2())
                    .foregroundStyle(BelongColor.textPrimary)

                if viewModel.joinHistory.isEmpty {
                    EmptyStateView(
                        systemImage: "calendar.badge.checkmark",
                        title: "No events yet",
                        message: "Events you join will appear here"
                    )
                    .frame(height: 120)
                } else {
                    VStack(spacing: Spacing.md) {
                        ForEach(viewModel.joinHistory) { item in
                            JoinHistoryRow(item: item)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Browsing History Card

struct BrowsingHistoryCard: View {
    let item: BrowsingHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Thumbnail
            AsyncImage(url: item.gatheringImageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(BelongColor.skeleton)
                }
            }
            .frame(width: 140, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))

            // Title
            Text(item.gatheringTitle)
                .font(BelongFont.captionMedium())
                .foregroundStyle(BelongColor.textPrimary)
                .lineLimit(2)

            // Time ago
            Text(relativeTime(from: item.viewedAt))
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
        .frame(width: 140)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.gatheringTitle), viewed \(relativeTime(from: item.viewedAt))")
    }

    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Join History Row

struct JoinHistoryRow: View {
    let item: EventJoinHistoryItem

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Thumbnail
            AsyncImage(url: item.gatheringImageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(BelongColor.skeleton)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))

            // Details
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(item.gatheringTitle)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Text(item.date.formatted(.dateTime.month(.abbreviated).day()))
                    Text("•")
                    Text(item.location)
                        .lineLimit(1)
                }
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)

                // Tags
                HStack(spacing: Spacing.xs) {
                    ForEach(item.culturalTags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(BelongColor.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            // Status + rating
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                JoinStatusBadge(status: item.status)

                if let rating = item.ratingGiven {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(BelongColor.warning)
                        Text("\(rating)")
                            .font(BelongFont.captionMedium())
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                } else if item.status == .attended {
                    Text("Rate")
                        .font(BelongFont.captionMedium())
                        .foregroundStyle(BelongColor.primary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 2)
                        .background(BelongColor.surfaceSecondary)
                        .clipShape(Capsule())
                }

                if let emoji = item.feedbackEmoji {
                    Text(emoji)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(Spacing.md)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.gatheringTitle), \(item.status.rawValue), \(item.date.formatted(.dateTime.month(.abbreviated).day()))")
    }
}

// MARK: - Join Status Badge

struct JoinStatusBadge: View {
    let status: JoinStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(BelongFont.caption())
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var foregroundColor: Color {
        switch status {
        case .confirmed: return BelongColor.success
        case .attended: return BelongColor.sageDark
        case .missed: return BelongColor.warning
        case .cancelled: return BelongColor.textTertiary
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .confirmed: return BelongColor.successLight
        case .attended: return BelongColor.sage.opacity(0.2)
        case .missed: return BelongColor.warningLight
        case .cancelled: return BelongColor.divider
        }
    }
}
