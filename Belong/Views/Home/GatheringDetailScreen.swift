import SwiftUI

// MARK: - GatheringDetailScreen (S13)
// Full detail view for a gathering with hero image, host info, and join actions.
// UX Decision: Floating buttons on the hero image for back/bookmark keep the
// image immersive. Fixed bottom bar ensures the primary action is always reachable.

struct GatheringDetailScreen: View {
    let gathering: Gathering
    @Bindable var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    private var displayGathering: Gathering {
        // Use the latest version from the view model if available
        viewModel.gatherings.first(where: { $0.id == gathering.id }) ?? gathering
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage
                    detailContent
                }
                .padding(.bottom, 100) // Space for bottom bar
            }

            bottomBar
        }
        .background(BelongColor.background)
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showJoinConfirmation) {
            if let selected = viewModel.selectedGathering {
                JoinConfirmationSheet(gathering: selected) {
                    viewModel.showJoinConfirmation = false
                }
            }
        }
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        ZStack(alignment: .top) {
            AsyncImage(url: displayGathering.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    imagePlaceholder
                case .empty:
                    SkeletonView(height: 240)
                @unknown default:
                    imagePlaceholder
                }
            }
            .frame(height: 240)
            .clipped()

            // Floating buttons
            HStack {
                // Back button
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(BelongColor.textPrimary)
                        .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Back")

                Spacer()

                // Bookmark button
                Button { viewModel.toggleBookmark(for: displayGathering) } label: {
                    Image(systemName: displayGathering.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(displayGathering.isBookmarked ? BelongColor.primary : BelongColor.textPrimary)
                        .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel(displayGathering.isBookmarked ? "Remove bookmark" : "Bookmark")
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.sm)
        }
    }

    // MARK: - Detail Content

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Cultural tags
            if !displayGathering.culturalTags.isEmpty {
                HStack(spacing: Spacing.sm) {
                    ForEach(displayGathering.culturalTags, id: \.self) { tag in
                        Text(tag)
                            .font(BelongFont.captionMedium())
                            .foregroundStyle(BelongColor.primary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(BelongColor.accent)
                            .clipShape(Capsule())
                    }
                }
            }

            // Title
            Text(displayGathering.title)
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            // Host row
            HStack(spacing: Spacing.md) {
                AvatarView(emoji: displayGathering.hostAvatarEmoji, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayGathering.hostName)
                        .font(BelongFont.bodyMedium())
                        .foregroundStyle(BelongColor.textPrimary)

                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(BelongColor.warning)
                        Text(String(format: "%.1f", displayGathering.hostRating))
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                }
            }

            // Date/time row
            HStack(spacing: Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundStyle(BelongColor.textTertiary)
                    .frame(width: 24)
                Text(displayGathering.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day().hour().minute()))
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textSecondary)
            }

            // Location row
            HStack(spacing: Spacing.sm) {
                Image(systemName: "mappin")
                    .font(.system(size: 16))
                    .foregroundStyle(BelongColor.textTertiary)
                    .frame(width: 24)
                Text(displayGathering.location)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textSecondary)
            }

            // Attendee section
            HStack(spacing: Spacing.md) {
                // Face pile
                HStack(spacing: -8) {
                    ForEach(Array(displayGathering.attendeeAvatars.prefix(5).enumerated()), id: \.offset) { _, emoji in
                        Text(emoji)
                            .font(.system(size: 14))
                            .frame(width: 32, height: 32)
                            .background(BelongColor.surfaceSecondary)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(BelongColor.surface, lineWidth: 2))
                    }
                }

                Text("\(displayGathering.attendeeCount) attending")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textSecondary)
            }

            // Divider
            Rectangle()
                .fill(BelongColor.divider)
                .frame(height: 1)

            // Description
            Text(displayGathering.description)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
                .lineSpacing(4)
        }
        .padding(Layout.screenPadding)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BelongColor.divider)
                .frame(height: 1)

            Group {
                if displayGathering.isPast {
                    pastState
                } else if displayGathering.isFull {
                    fullState
                } else {
                    actionButtons
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.md)
        }
        .background(BelongColor.surface)
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            BelongButton(title: "Join", style: .primary) {
                viewModel.joinGathering(displayGathering)
            }

            BelongButton(title: "Maybe", style: .secondary) {
                // Maybe action
            }
        }
    }

    private var fullState: some View {
        HStack {
            Spacer()
            Text("This gathering is full")
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.disabledText)
            Spacer()
        }
        .frame(height: Layout.buttonHeight)
    }

    private var pastState: some View {
        HStack {
            Spacer()
            Text("This gathering has ended")
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.disabledText)
            Spacer()
        }
        .frame(height: Layout.buttonHeight)
    }

    // MARK: - Helpers

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(BelongColor.skeleton)
            .overlay {
                Image(systemName: "photo")
                    .font(.title)
                    .foregroundStyle(BelongColor.textTertiary)
            }
    }
}

#Preview("Gathering Detail") {
    NavigationStack {
        GatheringDetailScreen(
            gathering: SampleData.topPick,
            viewModel: {
                let vm = HomeViewModel()
                vm.gatherings = SampleData.gatherings
                vm.loadState = .loaded
                return vm
            }()
        )
    }
}

#Preview("Gathering Detail - Past") {
    NavigationStack {
        GatheringDetailScreen(
            gathering: SampleData.pastGatherings[0],
            viewModel: {
                let vm = HomeViewModel()
                vm.gatherings = SampleData.gatherings
                vm.loadState = .loaded
                return vm
            }()
        )
    }
}

#Preview("Join Confirmation") {
    JoinConfirmationSheet(gathering: SampleData.topPick) {}
}
