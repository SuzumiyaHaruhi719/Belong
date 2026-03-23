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
            title: "No gatherings yet \u{1F4C5}",
            message: "No gatherings in your area yet. Check back soon or host one yourself!"
        )
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxxl)
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
                }
            }
            .padding(.bottom, Spacing.xxl)
        }
    }
}

// MARK: - Welcome Greeting
// UX: Personal greeting builds warmth. "for you" in accent color draws
// attention to the personalized pick. Tag explanation builds trust in
// the recommendation — users understand WHY they see this gathering.

private struct WelcomeGreeting: View {
    let name: String?
    let matchingTags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // App wordmark (moved here from toolbar so there's no nav bar)
            Text("Belong")
                .font(BelongFont.display(28))
                .foregroundStyle(BelongColor.textPrimary)
                .padding(.bottom, Spacing.xs)

            // "Welcome, Mai!"
            (Text("Welcome, ")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
            + Text(name ?? "friend")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.primary)
            + Text("!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary))

            // "Here's a curated pick for you"
            (Text("Here's a curated pick ")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
            + Text("for you")
                .font(BelongFont.bodySemiBold())
                .foregroundStyle(BelongColor.primary))

            // Tag explanation
            if !matchingTags.isEmpty {
                Text("Based on \(matchingTags.prefix(3).joined(separator: ", "))")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }
        }
    }
}

// MARK: - Top Pick Section
// UX: The top pick card has a prominent border + label to distinguish it
// from regular feed cards. Join + Maybe buttons are directly on the card
// so users can act without navigating to the detail screen first.

private struct TopPickSection: View {
    let gathering: Gathering
    let onBookmark: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section label with accent line
            HStack(spacing: Spacing.sm) {
                Text("\u{2B50} TOP PICK")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.primary)
                    .tracking(1)

                Rectangle()
                    .fill(BelongColor.primary.opacity(0.3))
                    .frame(height: 1)
            }

            // Card with border highlight
            NavigationLink(value: GatheringsRoute.detail(gathering)) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero image area
                    ZStack(alignment: .topLeading) {
                        // Image or gradient
                        if let url = gathering.imageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                default:
                                    topPickGradient
                                }
                            }
                            .frame(height: 180)
                            .clipped()
                        } else {
                            topPickGradient
                                .frame(height: 180)
                                .overlay {
                                    Text(gathering.emoji)
                                        .font(.system(size: 56))
                                }
                        }

                        // TOP PICK badge
                        Text("TOP PICK")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(BelongColor.textOnPrimary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(BelongColor.primary)
                            .clipShape(Capsule())
                            .padding(Spacing.md)

                        // Spots badge top right
                        VStack {
                            Text(gathering.formattedSpots)
                                .font(BelongFont.captionMedium())
                                .foregroundStyle(BelongColor.textPrimary)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, Spacing.xs)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .padding(Spacing.md)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // Card body
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        // Tags
                        HStack(spacing: Spacing.xs) {
                            ForEach(gathering.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(BelongFont.captionMedium())
                                    .foregroundStyle(BelongColor.primary)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, 3)
                                    .background(BelongColor.surfaceSecondary)
                                    .clipShape(Capsule())
                            }
                        }

                        // Title
                        HStack {
                            Text(gathering.title)
                                .font(BelongFont.h2())
                                .foregroundStyle(BelongColor.textPrimary)
                            if !gathering.emoji.isEmpty {
                                Text(gathering.emoji)
                            }
                        }

                        // Date + location
                        Label(gathering.startsAt.formatted(.dateTime.weekday(.wide).month(.abbreviated).day().hour().minute()),
                              systemImage: "calendar")
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textSecondary)

                        Label(gathering.locationName, systemImage: "mappin.and.ellipse")
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                    .padding(Spacing.base)
                }
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusLg)
                        .stroke(BelongColor.primary.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
        }
    }

    private var topPickGradient: some View {
        LinearGradient(
            colors: [BelongColor.primary.opacity(0.2), BelongColor.surfaceSecondary],
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
