import SwiftUI

// MARK: - GatheringsFeedScreen
// The app's landing page / home screen. Welcomes the user by name and
// presents a curated top pick based on their cultural tags + location.
//
// UX Decisions (from UI/UX Pro Max + SwiftUI Pro):
// - Personal welcome builds emotional connection on first glance.
// - "for you" in accent color draws the eye to the personalized pick.
// - Tags mentioned below the greeting explain WHY this was chosen (trust).
// - Join + Maybe buttons directly on the top pick card reduce friction
//   (one less tap than navigating to detail first).
// - Filter chips + feed below let users explore beyond the curated pick.
// - Bell icon in toolbar is the only toolbar item — clean, uncluttered.

struct GatheringsFeedScreen: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: GatheringsViewModel
    @State private var hasLoadedOnce = false

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
                GatheringsFeedLoadedContent(
                    viewModel: viewModel,
                    userName: appState.currentUser?.displayName
                )
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
            hasLoadedOnce = true
        }
        .onAppear {
            if hasLoadedOnce {
                Task { await viewModel.refresh() }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Notification Button

struct GatheringsFeedNotificationButton: View {
    let badgeCount: Int

    var body: some View {
        NavigationLink(value: ChatRoute.notificationsComments) {
            Image(systemName: "bell")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(BelongColor.textPrimary)
                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                .overlay(alignment: .topTrailing) {
                    if badgeCount > 0 {
                        Text("\(min(badgeCount, 99))")
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

// MARK: - Loading

struct GatheringsFeedLoadingContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Greeting skeleton
            SkeletonView(width: 200, height: 28)
            SkeletonView(width: 260, height: 28)
            SkeletonView(width: 180, height: 16)
                .padding(.bottom, Spacing.sm)

            // Card skeleton
            SkeletonCard()
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.base)
    }
}

// MARK: - Error

struct GatheringsFeedErrorContent: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ErrorStateView(message: message, onRetry: onRetry)
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xxxxl)
    }
}

// MARK: - Empty

struct GatheringsFeedEmptyContent: View {
    var body: some View {
        EmptyStateView(
            icon: "calendar",
            title: "No gatherings yet",
            message: "Nothing happening nearby right now. You could be the first to host one.",
            ctaTitle: "Host a gathering",
            onCTA: {}
        )
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxl)
    }
}

// MARK: - Loaded Content

struct GatheringsFeedLoadedContent: View {
    @Bindable var viewModel: GatheringsViewModel
    let userName: String?

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            // MARK: Welcome greeting
            WelcomeGreeting(
                name: userName,
                matchingTags: viewModel.topPick?.tags ?? []
            )
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.lg)

            // MARK: Top pick section
            if let topPick = viewModel.topPick {
                TopPickSection(
                    gathering: topPick,
                    onBookmark: { viewModel.toggleBookmark(id: topPick.id) }
                )
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Spacing.xl)
            }

            // MARK: Filter + Browse
            FilterChipRow(
                filters: viewModel.filterOptions,
                selected: Binding(
                    get: { viewModel.selectedFilterBinding },
                    set: { viewModel.selectedFilterBinding = $0 }
                )
            )
            .padding(.bottom, Spacing.md)

            // Feed cards
            LazyVStack(spacing: Spacing.base) {
                ForEach(viewModel.filteredGatherings) { gathering in
                    NavigationLink(value: GatheringsRoute.detail(gathering)) {
                        GatheringCard(
                            gathering: gathering,
                            onBookmarkToggle: { viewModel.toggleBookmark(id: gathering.id) }
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Layout.screenPadding)
                    .onAppear {
                        if gathering.id == viewModel.filteredGatherings.last?.id {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }
                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                }
            }
            .padding(.bottom, Spacing.xxl)
        }
    }
}

// MARK: - Welcome Greeting
// Editorial header: wordmark + personal greeting. No AI-style "Here's
// a curated pick for you". Instead, quieter trust signals.

private struct WelcomeGreeting: View {
    let name: String?
    let matchingTags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Wordmark — smaller than welcome screen, functions as page header
            Text("Belong")
                .font(BelongFont.display(24))
                .foregroundStyle(BelongColor.primary)

            // Greeting — warm but not chatty
            Text(greetingText)
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
                .lineSpacing(2)

            // Tag context — restrained, not "AI picked this for you"
            if !matchingTags.isEmpty {
                Text(matchingTags.prefix(3).joined(separator: "  \u{00B7}  "))
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
                    .tracking(0.5)
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        switch hour {
        case 5..<12: greeting = "Good morning"
        case 12..<17: greeting = "Good afternoon"
        default: greeting = "Good evening"
        }
        if let name, !name.isEmpty {
            return "\(greeting), \(name)"
        }
        return greeting
    }
}

// MARK: - Top Pick Section
// Elevated card with subtle border accent. No shouting "TOP PICK" badge —
// the visual weight and placement already communicate priority.

private struct TopPickSection: View {
    let gathering: Gathering
    let onBookmark: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section label — quiet, editorial
            Text("Recommended for you")
                .font(BelongFont.overline())
                .foregroundStyle(BelongColor.textTertiary)
                .tracking(1)
                .textCase(.uppercase)

            // Featured card
            NavigationLink(value: GatheringsRoute.detail(gathering)) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero image
                    ZStack(alignment: .bottomLeading) {
                        if let url = gathering.imageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    topPickGradient
                                }
                            }
                            .frame(height: 200)
                            .clipped()
                        } else {
                            topPickGradient
                                .frame(height: 200)
                                .overlay {
                                    Text(gathering.emoji)
                                        .font(.system(size: 48))
                                }
                        }

                        // Tags on image — bottom left
                        HStack(spacing: Spacing.xs) {
                            ForEach(gathering.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(BelongFont.captionMedium())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(.black.opacity(0.35))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(Spacing.md)
                    }

                    // Card body — tighter spacing
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(gathering.title)
                            .font(BelongFont.h2())
                            .foregroundStyle(BelongColor.textPrimary)
                            .lineLimit(2)

                        // Date + location — compact
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Label(gathering.startsAt.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()),
                                  systemImage: "calendar")
                            Label(gathering.locationName, systemImage: "mappin.and.ellipse")
                                .lineLimit(1)
                        }
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)

                        // Spots remaining
                        Text(gathering.formattedSpots)
                            .font(BelongFont.captionMedium())
                            .foregroundStyle(
                                gathering.isFull ? BelongColor.error :
                                gathering.spotsRemaining <= 3 ? BelongColor.warning :
                                BelongColor.textTertiary
                            )
                    }
                    .padding(Spacing.base)
                }
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                .shadow(
                    color: BelongShadow.level2.color,
                    radius: BelongShadow.level2.radius,
                    x: BelongShadow.level2.x,
                    y: BelongShadow.level2.y
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var topPickGradient: some View {
        LinearGradient(
            colors: [BelongColor.primaryMuted, BelongColor.surfaceSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    NavigationStack {
        GatheringsFeedScreen(container: DependencyContainer())
    }
    .environment(AppState())
}
