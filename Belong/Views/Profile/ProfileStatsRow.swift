import SwiftUI

// MARK: - Profile Stats Row
// Three-column stat display: Attended, Hosted, Connections.
// UX: Centered in a card to feel like an achievement summary.
// Numbers use the display font for visual weight.

struct ProfileStatsRow: View {
    let stats: UserStats

    var body: some View {
        HStack(spacing: 0) {
            StatColumn(number: stats.attended, label: "Attended")
            Divider().frame(height: 40)
            StatColumn(number: stats.hosted, label: "Hosted")
            Divider().frame(height: 40)
            StatColumn(number: stats.connections, label: "Connections")
        }
        .padding(.vertical, Spacing.base)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Stat Column

struct StatColumn: View {
    let number: Int
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("\(number)")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
            Text(label)
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(number) \(label)")
    }
}
