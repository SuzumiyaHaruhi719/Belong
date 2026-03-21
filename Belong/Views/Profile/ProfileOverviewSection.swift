import SwiftUI

// MARK: - Profile Overview Section
// The "who I am" tab: cultural tags, saved gatherings shortcut, connections.
// UX: This is the default landing — shows identity and community at a glance.

struct ProfileOverviewSection: View {
    let viewModel: ProfileViewModel
    let onEditTags: () -> Void
    let onSaved: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // MARK: Cultural Tags
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Cultural tags")
                        .font(BelongFont.h2())
                        .foregroundStyle(BelongColor.textPrimary)

                    Spacer()

                    Button("Edit", action: onEditTags)
                        .font(BelongFont.secondaryMedium())
                        .foregroundStyle(BelongColor.primary)
                        .accessibilityLabel("Edit cultural tags")
                }

                if viewModel.user.culturalTags.isEmpty {
                    Text("No tags added yet")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textTertiary)
                } else {
                    FlowLayout(spacing: Spacing.sm) {
                        ForEach(viewModel.user.culturalTags.allTags, id: \.self) { tag in
                            Text(tag)
                                .font(BelongFont.captionMedium())
                                .foregroundStyle(BelongColor.primary)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(BelongColor.surfaceSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // MARK: Saved Gatherings
            Button(action: onSaved) {
                HStack {
                    Text("Saved gatherings")
                        .font(BelongFont.h2())
                        .foregroundStyle(BelongColor.textPrimary)

                    Spacer()

                    Text("\(viewModel.savedGatherings.count)")
                        .font(BelongFont.captionMedium())
                        .foregroundStyle(BelongColor.textOnPrimary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(BelongColor.primary)
                        .clipShape(Capsule())

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(BelongColor.textTertiary)
                }
                .padding(Spacing.base)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Saved gatherings, \(viewModel.savedGatherings.count) items")

            // MARK: Connections
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Connections")
                    .font(BelongFont.h2())
                    .foregroundStyle(BelongColor.textPrimary)

                if viewModel.connections.isEmpty {
                    Text("No connections yet")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textTertiary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.base) {
                            ForEach(viewModel.connections) { connection in
                                VStack(spacing: Spacing.xs) {
                                    AvatarView(emoji: connection.avatarEmoji, size: 40)

                                    Text(connection.name.components(separatedBy: " ").first ?? connection.name)
                                        .font(BelongFont.caption())
                                        .foregroundStyle(BelongColor.textSecondary)
                                        .lineLimit(1)
                                }
                                .frame(width: 60)
                                .accessibilityLabel("\(connection.name), \(connection.mutualEvents) mutual events")
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}
