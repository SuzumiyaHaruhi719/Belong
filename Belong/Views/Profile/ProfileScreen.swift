import SwiftUI

// MARK: - ProfileScreen (S23)
// User profile hub showing identity, stats, tags, saved gatherings, and connections.
// UX Decision: Stats row creates a sense of community investment.
// Horizontal scroll for connections keeps the profile scannable.

struct ProfileScreen: View {
    @State private var viewModel = ProfileViewModel()
    @State private var navigateToEditTags = false
    @State private var navigateToSaved = false
    @State private var navigateToSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {

                    // MARK: Avatar & Identity
                    VStack(spacing: Spacing.md) {
                        // Avatar with camera badge
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(
                                emoji: viewModel.user.avatarEmoji,
                                imageURL: viewModel.user.avatarURL,
                                size: 80
                            )

                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(BelongColor.textOnPrimary)
                                .frame(width: 28, height: 28)
                                .background(BelongColor.primary)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().strokeBorder(BelongColor.background, lineWidth: 2)
                                }
                                .accessibilityLabel("Edit avatar")
                        }

                        Text(viewModel.user.displayName)
                            .font(BelongFont.h1())
                            .foregroundStyle(BelongColor.textPrimary)

                        HStack(spacing: Spacing.xs) {
                            Text(viewModel.user.school)
                            Text("•")
                            Text(viewModel.user.city)
                        }
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                    }

                    // MARK: Stats Row
                    HStack(spacing: 0) {
                        StatColumn(number: viewModel.user.stats.attended, label: "Attended")
                        Divider().frame(height: 40)
                        StatColumn(number: viewModel.user.stats.hosted, label: "Hosted")
                        Divider().frame(height: 40)
                        StatColumn(number: viewModel.user.stats.connections, label: "Connections")
                    }
                    .padding(.vertical, Spacing.base)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                    .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)

                    // MARK: Cultural Tags
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Text("Cultural tags")
                                .font(BelongFont.h2())
                                .foregroundStyle(BelongColor.textPrimary)

                            Spacer()

                            Button {
                                viewModel.beginEditingTags()
                                navigateToEditTags = true
                            } label: {
                                Text("Edit")
                                    .font(BelongFont.secondaryMedium())
                                    .foregroundStyle(BelongColor.primary)
                            }
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
                    Button {
                        navigateToSaved = true
                    } label: {
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
                .padding(.bottom, Spacing.xxxl)
            }
            .background(BelongColor.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigateToSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18))
                            .foregroundStyle(BelongColor.textPrimary)
                            .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(isPresented: $navigateToEditTags) {
                EditCulturalTagsScreen(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToSaved) {
                SavedGatheringsScreen(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsScreen()
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

// MARK: - Stat Column

private struct StatColumn: View {
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

#Preview {
    ProfileScreen()
        .environment(AppState())
}
