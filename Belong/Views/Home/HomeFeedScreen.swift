import SwiftUI

// MARK: - HomeFeedScreen (S12)
// Main feed showing top pick, cultural filters, and recommended gatherings.
// UX Decision: Pull-to-refresh + skeleton loading for perceived speed.
// Filter chips let users narrow by culture without leaving the feed.

struct HomeFeedScreen: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.loadState {
                case .loading:
                    loadingState
                case .error(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.retry() }
                    }
                case .loaded:
                    loadedContent
                }
            }
            .background(BelongColor.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Belong")
                        .font(BelongFont.display(28))
                        .foregroundStyle(BelongColor.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Notifications action
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(BelongColor.textPrimary)
                    }
                    .accessibilityLabel("Notifications")
                }
            }
            .navigationDestination(for: Gathering.self) { gathering in
                GatheringDetailScreen(gathering: gathering, viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadGatherings()
        }
    }

    // MARK: - Loaded Content

    private var loadedContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Location chip
                locationChip

                // Top pick section
                if let topPick = viewModel.topPick {
                    topPickSection(topPick)
                }

                // Filter chips
                filterChips

                // Recommended section
                recommendedSection

                // Browse all button
                browseAllButton
            }
            .padding(.bottom, Spacing.xxxl)
        }
        .refreshable {
            await viewModel.loadGatherings()
        }
    }

    // MARK: - Location Chip

    private var locationChip: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "mappin")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(BelongColor.primary)
            Text("Melbourne")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)
            Image(systemName: "chevron.down")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(BelongColor.textTertiary)
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: Layout.chipHeight)
        .background(BelongColor.surface)
        .clipShape(Capsule())
        .overlay {
            Capsule().strokeBorder(BelongColor.border, lineWidth: 1)
        }
        .padding(.horizontal, Layout.screenPadding)
    }

    // MARK: - Top Pick

    private func topPickSection(_ gathering: Gathering) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Top pick for you")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .padding(.horizontal, Layout.screenPadding)

            NavigationLink(value: gathering) {
                GatheringCard(
                    gathering: gathering,
                    isCompact: false,
                    onBookmarkToggle: { viewModel.toggleBookmark(for: gathering) }
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Layout.screenPadding)
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(viewModel.availableFilters, id: \.self) { tag in
                        ChipView(
                            title: tag,
                            isSelected: viewModel.selectedFilterTags.contains(tag)
                        ) {
                            if viewModel.selectedFilterTags.contains(tag) {
                                viewModel.selectedFilterTags.removeAll { $0 == tag }
                            } else {
                                viewModel.selectedFilterTags.append(tag)
                            }
                        }
                    }
                }
                .padding(.horizontal, Layout.screenPadding)
            }
        }
    }

    // MARK: - Recommended Section

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recommended for you")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .padding(.horizontal, Layout.screenPadding)

            if viewModel.filteredGatherings.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "No matches",
                    message: "Try adjusting your filters to see more gatherings"
                )
                .frame(minHeight: 200)
            } else {
                LazyVStack(spacing: Spacing.base) {
                    ForEach(viewModel.filteredGatherings) { gathering in
                        NavigationLink(value: gathering) {
                            GatheringCard(
                                gathering: gathering,
                                isCompact: true,
                                onBookmarkToggle: { viewModel.toggleBookmark(for: gathering) }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Layout.screenPadding)
            }
        }
    }

    // MARK: - Browse All

    private var browseAllButton: some View {
        Button {
            // Browse all action
        } label: {
            HStack(spacing: Spacing.xs) {
                Text("Browse all gatherings")
                    .font(BelongFont.bodySemiBold())
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(BelongColor.primary)
        }
        .padding(.horizontal, Layout.screenPadding)
    }

    // MARK: - Loading State

    private var loadingState: some View {
        ScrollView {
            VStack(spacing: Spacing.base) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonCard()
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.base)
        }
    }
}

#Preview("Home Feed") {
    HomeFeedScreen()
}

#Preview("Home Feed - Loading") {
    HomeFeedScreen()
}
