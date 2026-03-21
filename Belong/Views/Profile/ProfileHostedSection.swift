import SwiftUI

// MARK: - Profile Hosted Section
// The "what I've created" tab: hosted events with stats and ratings.
//
// UX Decisions:
// - Summary card at top shows aggregate hosting stats (total events,
//   total attendees, average rating) — rewards effort and builds host identity.
// - Each hosted event shows fill rate (attendees/max) as a visual bar.
// - Rating shown per event when available, with star icon for scannability.
// - Published (upcoming) events distinguished from completed (past) events.
// - Empty state encourages hosting with a warm message and CTA hint.

struct ProfileHostedSection: View {
    let viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // MARK: Host Summary Card
            if !viewModel.hostHistory.isEmpty {
                HostSummaryCard(
                    totalEvents: viewModel.publishedHosted.count,
                    totalAttendees: viewModel.totalAttendeesHosted,
                    averageRating: viewModel.averageHostRating
                )
            }

            // MARK: Hosted Events List
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Your gatherings")
                    .font(BelongFont.h2())
                    .foregroundStyle(BelongColor.textPrimary)

                if viewModel.hostHistory.isEmpty {
                    EmptyStateView(
                        systemImage: "plus.circle",
                        title: "No gatherings hosted yet",
                        message: "Share your culture by hosting a gathering — it only takes a few minutes"
                    )
                    .frame(height: 160)
                } else {
                    VStack(spacing: Spacing.md) {
                        ForEach(viewModel.hostHistory) { item in
                            HostHistoryRow(item: item)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Host Summary Card

struct HostSummaryCard: View {
    let totalEvents: Int
    let totalAttendees: Int
    let averageRating: Double?

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: Spacing.xs) {
                Text("\(totalEvents)")
                    .font(BelongFont.h1())
                    .foregroundStyle(BelongColor.primary)
                Text("Events")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: Spacing.xs) {
                Text("\(totalAttendees)")
                    .font(BelongFont.h1())
                    .foregroundStyle(BelongColor.primary)
                Text("Attendees")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: Spacing.xs) {
                if let rating = averageRating {
                    HStack(spacing: 2) {
                        Text(String(format: "%.1f", rating))
                            .font(BelongFont.h1())
                            .foregroundStyle(BelongColor.primary)
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(BelongColor.warning)
                    }
                } else {
                    Text("—")
                        .font(BelongFont.h1())
                        .foregroundStyle(BelongColor.textTertiary)
                }
                Text("Avg Rating")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, Spacing.base)
        .background(BelongColor.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Host stats: \(totalEvents) events, \(totalAttendees) attendees")
    }
}

// MARK: - Host History Row

struct HostHistoryRow: View {
    let item: EventHostHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
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
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(item.gatheringTitle)
                            .font(BelongFont.bodyMedium())
                            .foregroundStyle(BelongColor.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        HostedEventStatusBadge(status: item.status)
                    }

                    Text(item.date.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textSecondary)

                    HStack(spacing: Spacing.sm) {
                        Label("\(item.attendeeCount)/\(item.maxAttendees)", systemImage: "person.2")
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.textSecondary)

                        if let rating = item.averageRating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(BelongColor.warning)
                                Text(String(format: "%.1f", rating))
                                    .font(BelongFont.captionMedium())
                                    .foregroundStyle(BelongColor.textSecondary)
                            }
                        }
                    }
                }
            }

            // Fill rate bar
            FillRateBar(current: item.attendeeCount, max: item.maxAttendees)
        }
        .padding(Spacing.md)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.gatheringTitle), \(item.status.rawValue), \(item.attendeeCount) of \(item.maxAttendees) attendees")
    }
}

// MARK: - Fill Rate Bar

struct FillRateBar: View {
    let current: Int
    let max: Int

    private var progress: Double {
        guard max > 0 else { return 0 }
        return min(Double(current) / Double(max), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(BelongColor.divider)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(progress >= 1.0 ? BelongColor.success : BelongColor.primary)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)

            Text(progress >= 1.0 ? "Full" : "\(Int(progress * 100))% filled")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
    }
}

// MARK: - Hosted Event Status Badge

struct HostedEventStatusBadge: View {
    let status: HostedEventStatus

    var body: some View {
        Text(label)
            .font(BelongFont.caption())
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var label: String {
        switch status {
        case .draft: return "Draft"
        case .published: return "Live"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .draft: return BelongColor.textTertiary
        case .published: return BelongColor.success
        case .completed: return BelongColor.sageDark
        case .cancelled: return BelongColor.error
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .draft: return BelongColor.divider
        case .published: return BelongColor.successLight
        case .completed: return BelongColor.sage.opacity(0.2)
        case .cancelled: return BelongColor.errorLight
        }
    }
}
