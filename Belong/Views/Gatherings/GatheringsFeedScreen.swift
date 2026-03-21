import SwiftUI

struct GatheringsFeedScreen: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: GatheringsViewModel

    init(container: DependencyContainer) {
        _viewModel = State(initialValue: GatheringsViewModel(container: container))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.gatherings.isEmpty {
                GatheringsFeedLoadingContent()
            } else if let errorMessage = viewModel.error, viewModel.gatherings.isEmpty {
                GatheringsFeedErrorContent(
                    message: errorMessage,
                    onRetry: { Task { await viewModel.refresh() } }
                )
            } else if viewModel.gatherings.isEmpty {
                GatheringsFeedEmptyContent()
            } else {
                GatheringsFeedLoadedContent(viewModel: viewModel)
            }
        }
        .background(BelongColor.background)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            if viewModel.gatherings.isEmpty {
                await viewModel.loadFeed()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Belong")
                    .font(BelongFont.display(28))
                    .foregroundStyle(BelongColor.textPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                GatheringsFeedNotificationButton(badgeCount: appState.unreadNotificationCount)
            }
        }
    }
}

// MARK: - Notification Button

struct GatheringsFeedNotificationButton: View {
    let badgeCount: Int

    var body: some View {
        Button(action: {}) {
            Image(systemName: "bell")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(BelongColor.textPrimary)
                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                .overlay(alignment: .topTrailing) {
                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(BelongColor.error)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                    }
                }
        }
        .accessibilityLabel("Notifications, \(badgeCount) unread")
    }
}

// MARK: - Loading Content

struct GatheringsFeedLoadingContent: View {
    var body: some View {
        LazyVStack(spacing: Spacing.base) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonCard()
            }
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.base)
    }
}

// MARK: - Error Content

struct GatheringsFeedErrorContent: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ErrorStateView(message: message, onRetry: onRetry)
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xxxxl)
    }
}

// MARK: - Empty Content

struct GatheringsFeedEmptyContent: View {
    var body: some View {
        EmptyStateView(
            icon: "calendar",
            title: "No gatherings yet",
            message: "No gatherings in your area yet"
        )
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxxl)
    }
}

// MARK: - Loaded Content

struct GatheringsFeedLoadedContent: View {
    @Bindable var viewModel: GatheringsViewModel

    var body: some View {
        LazyVStack(spacing: Spacing.base) {
            // Top pick hero card
            if let topPick = viewModel.topPick {
                NavigationLink(value: GatheringsRoute.detail(topPick)) {
                    HeroCard(
                        gathering: topPick,
                        mutualFriendsCount: 2,
                        onBookmarkToggle: { viewModel.toggleBookmark(id: topPick.id) }
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Layout.screenPadding)
            }

            // Filter chips
            FilterChipRow(
                filters: viewModel.filterOptions,
                selected: Binding(
                    get: { viewModel.selectedFilterBinding },
                    set: { viewModel.selectedFilterBinding = $0 }
                )
            )
            .padding(.vertical, Spacing.sm)

            // Feed cards
            ForEach(viewModel.filteredGatherings) { gathering in
                NavigationLink(value: GatheringsRoute.detail(gathering)) {
                    GatheringCard(
                        gathering: gathering,
                        onBookmarkToggle: { viewModel.toggleBookmark(id: gathering.id) }
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Layout.screenPadding)
            }
        }
        .padding(.vertical, Spacing.base)
    }
}

#Preview {
    NavigationStack {
        GatheringsFeedScreen(container: DependencyContainer())
    }
    .environment(AppState())
}
