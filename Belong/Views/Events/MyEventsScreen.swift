import SwiftUI

// MARK: - MyEventsScreen (S14)
// Three-segment view for Upcoming, Past, and Saved gatherings.
// UX Decision: Segmented control keeps all event states one tap away.
// Past events prompt for ratings; saved events support swipe-to-remove.

struct MyEventsScreen: View {
    @State private var viewModel = EventsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented picker
                Picker("Events", selection: $viewModel.selectedSegment) {
                    ForEach(EventsViewModel.Segment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.vertical, Spacing.md)

                // Content
                Group {
                    if viewModel.isLoading {
                        loadingState
                    } else if viewModel.displayedGatherings.isEmpty {
                        emptyState
                    } else {
                        gatheringsList
                    }
                }
            }
            .background(BelongColor.background)
            .navigationTitle("My Events")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Gathering.self) { gathering in
                GatheringDetailScreen(
                    gathering: gathering,
                    viewModel: {
                        let hvm = HomeViewModel()
                        hvm.gatherings = viewModel.allGatherings
                        hvm.loadState = .loaded
                        return hvm
                    }()
                )
            }
            .sheet(isPresented: $viewModel.showFeedbackSheet) {
                if let gathering = viewModel.feedbackGathering {
                    FeedbackPlaceholderSheet(gathering: gathering)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Gatherings List

    private var gatheringsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.base) {
                ForEach(viewModel.displayedGatherings) { gathering in
                    gatheringRow(gathering)
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.xxxl)
        }
        .refreshable {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private func gatheringRow(_ gathering: Gathering) -> some View {
        switch viewModel.selectedSegment {
        case .upcoming:
            upcomingRow(gathering)
        case .past:
            pastRow(gathering)
        case .saved:
            savedRow(gathering)
        }
    }

    // MARK: - Upcoming Row

    private func upcomingRow(_ gathering: Gathering) -> some View {
        VStack(spacing: Spacing.sm) {
            NavigationLink(value: gathering) {
                GatheringCard(
                    gathering: gathering,
                    isCompact: true,
                    onBookmarkToggle: { viewModel.toggleBookmark(for: gathering) }
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: ChatDestination(gathering: gathering)) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 14, weight: .medium))
                    Text("Chat")
                        .font(BelongFont.secondaryMedium())
                }
                .foregroundStyle(BelongColor.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(BelongColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Past Row

    private func pastRow(_ gathering: Gathering) -> some View {
        VStack(spacing: Spacing.sm) {
            NavigationLink(value: gathering) {
                GatheringCard(
                    gathering: gathering,
                    isCompact: true
                )
            }
            .buttonStyle(.plain)

            Button {
                viewModel.feedbackGathering = gathering
                viewModel.showFeedbackSheet = true
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "star")
                        .font(.system(size: 14, weight: .medium))
                    Text("Rate")
                        .font(BelongFont.secondaryMedium())
                }
                .foregroundStyle(BelongColor.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(BelongColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Saved Row

    private func savedRow(_ gathering: Gathering) -> some View {
        NavigationLink(value: gathering) {
            GatheringCard(
                gathering: gathering,
                isCompact: true,
                onBookmarkToggle: { viewModel.toggleBookmark(for: gathering) }
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.toggleBookmark(for: gathering)
            } label: {
                Label("Remove", systemImage: "bookmark.slash")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        let config = viewModel.emptyStateConfig
        return EmptyStateView(
            systemImage: config.image,
            title: config.title,
            message: config.message
        )
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

// MARK: - Chat Navigation Destination

struct ChatDestination: Hashable {
    let gathering: Gathering
}

// MARK: - Feedback Placeholder Sheet

private struct FeedbackPlaceholderSheet: View {
    let gathering: Gathering
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(BelongColor.primary)
                .padding(.top, Spacing.xxl)

            Text("Rate your experience")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("How was \(gathering.title)?")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()

            BelongButton(title: "Done", style: .primary) {
                dismiss()
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.xxl)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview("My Events") {
    MyEventsScreen()
}

#Preview("My Events - Empty") {
    MyEventsScreen()
}
