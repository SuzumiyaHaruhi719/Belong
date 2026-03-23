import SwiftUI

struct GatheringDetailScreen: View {
    let gatheringId: String
    let initialGathering: Gathering?
    @State private var viewModel: GatheringDetailViewModel
    @State private var showEditFlow = false
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container

    init(gathering: Gathering, container: DependencyContainer) {
        self.gatheringId = gathering.id
        self.initialGathering = gathering
        _viewModel = State(initialValue: GatheringDetailViewModel(container: container))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isLoading && viewModel.gathering == nil {
                GatheringDetailLoadingContent()
            } else if let errorMessage = viewModel.error, viewModel.gathering == nil {
                GatheringDetailErrorContent(
                    message: errorMessage,
                    onRetry: { Task { await viewModel.loadDetail(id: gatheringId) } }
                )
            } else if let gathering = viewModel.gathering ?? initialGathering {
                GatheringDetailScrollContent(
                    gathering: gathering,
                    attendees: viewModel.attendees,
                    onBookmarkToggle: { Task { await viewModel.save() } },
                    onAttendeesTapped: { /* Navigation handled via NavigationLink in AttendeePile */ }
                )

                // Bottom action bar
                if !gathering.isPast {
                    GatheringDetailBottomBar(
                        gathering: gathering,
                        joinState: viewModel.joinState,
                        onJoin: { Task { await viewModel.join() } },
                        onMaybe: { Task { await viewModel.maybe() } },
                        onLeave: { Task { await viewModel.leave() } },
                        onEdit: { showEditFlow = true }
                    )
                }
            }
        }
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                GatheringDetailBackButton(action: { dismiss() })
            }
            ToolbarItem(placement: .topBarTrailing) {
                GatheringDetailBookmarkButton(
                    isBookmarked: viewModel.gathering?.isBookmarked ?? initialGathering?.isBookmarked ?? false,
                    action: { Task { await viewModel.save() } }
                )
            }
        }
        .sheet(isPresented: $viewModel.showJoinConfirmation) {
            GatheringJoinConfirmationSheet()
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showEditFlow) {
            if let g = viewModel.gathering ?? initialGathering {
                EditGatheringFlow(gathering: g, container: container) {
                    Task { await viewModel.loadDetail(id: gatheringId) }
                }
            } else {
                Text("Unable to load gathering")
            }
        }
        .task {
            await viewModel.loadDetail(id: gatheringId)
        }
    }
}

// MARK: - Back Button

struct GatheringDetailBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(BelongColor.textPrimary)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .accessibilityLabel("Back")
    }
}

// MARK: - Toolbar Bookmark Button

struct GatheringDetailBookmarkButton: View {
    let isBookmarked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isBookmarked ? BelongColor.primary : BelongColor.textPrimary)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark gathering")
    }
}

// MARK: - Loading

struct GatheringDetailLoadingContent: View {
    var body: some View {
        VStack(spacing: Spacing.base) {
            SkeletonView(height: Layout.heroImageHeight, cornerRadius: 0)
            VStack(alignment: .leading, spacing: Spacing.md) {
                SkeletonView(width: 200, height: 28)
                SkeletonView(width: 160, height: 16)
                SkeletonView(height: 16)
                SkeletonView(height: 16)
                SkeletonView(width: 120, height: 16)
            }
            .padding(.horizontal, Layout.screenPadding)
            Spacer()
        }
    }
}

// MARK: - Error

struct GatheringDetailErrorContent: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ErrorStateView(message: message, onRetry: onRetry)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Scroll Content

struct GatheringDetailScrollContent: View {
    let gathering: Gathering
    let attendees: [GatheringMember]
    let onBookmarkToggle: () -> Void
    let onAttendeesTapped: () -> Void

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
        return formatter.string(from: gathering.startsAt)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                GatheringDetailHeroImage(
                    imageURL: gathering.imageURL,
                    emoji: gathering.emoji
                )

                VStack(alignment: .leading, spacing: Spacing.base) {
                    // Cultural tag chips
                    GatheringDetailTagChips(tags: gathering.tags)

                    // Title
                    Text(gathering.title)
                        .font(BelongFont.h1())
                        .foregroundStyle(BelongColor.textPrimary)

                    // Host row
                    GatheringDetailHostRow(
                        hostName: gathering.hostName,
                        hostEmoji: gathering.hostAvatarEmoji,
                        hostAvatarURL: gathering.hostAvatarURL,
                        hostRating: gathering.hostRating
                    )

                    // Date/time
                    Label(dateText, systemImage: "calendar")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)

                    // Location
                    Label(gathering.locationName, systemImage: "mappin.and.ellipse")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)

                    // Attendee face pile
                    GatheringDetailAttendeePile(
                        avatars: gathering.attendeeAvatars,
                        count: gathering.attendeeCount,
                        gatheringId: gathering.id,
                        onTap: onAttendeesTapped
                    )

                    Divider()
                        .background(BelongColor.divider)

                    // Description
                    Text(gathering.description)
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.base)
                .padding(.bottom, 120) // space for bottom bar
            }
        }
    }
}

// MARK: - Hero Image

struct GatheringDetailHeroImage: View {
    let imageURL: URL?
    let emoji: String

    var body: some View {
        if let url = imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    GatheringCardImagePlaceholder(emoji: emoji)
                }
            }
            .frame(height: Layout.heroImageHeight)
            .frame(maxWidth: .infinity)
            .clipped()
        } else {
            GatheringCardImagePlaceholder(emoji: emoji)
                .frame(height: Layout.heroImageHeight)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Tag Chips

struct GatheringDetailTagChips: View {
    let tags: [String]

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(tags, id: \.self) { tag in
                ChipView(title: tag, isSelected: true)
            }
        }
    }
}

// MARK: - Host Row

struct GatheringDetailHostRow: View {
    let hostName: String
    let hostEmoji: String
    var hostAvatarURL: URL? = nil
    let hostRating: Double

    var body: some View {
        HStack(spacing: Spacing.sm) {
            AvatarView(imageURL: hostAvatarURL, emoji: hostEmoji, size: .medium)
            VStack(alignment: .leading, spacing: 2) {
                Text(hostName)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                if hostRating > 0 {
                    HStack(spacing: Spacing.xs) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < Int(hostRating.rounded()) ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundStyle(BelongColor.gold)
                        }
                        Text(String(format: "%.1f", hostRating))
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                } else {
                    Text("New host")
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textTertiary)
                }
            }
        }
    }
}

// MARK: - Attendee Pile

struct GatheringDetailAttendeePile: View {
    let avatars: [String]
    let count: Int
    let gatheringId: String
    let onTap: () -> Void

    var body: some View {
        NavigationLink(value: GatheringsRoute.attendees(gatheringId)) {
            HStack(spacing: Spacing.sm) {
                GatheringCardFacePile(avatarEmojis: avatars)
                Text("\(count) attending")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.primary)
            }
        }
        .accessibilityLabel("\(count) people attending, tap to view")
    }
}

// MARK: - Bottom Bar

struct GatheringDetailBottomBar: View {
    let gathering: Gathering
    let joinState: JoinState
    let onJoin: () -> Void
    let onMaybe: () -> Void
    let onLeave: () -> Void
    var onEdit: (() -> Void)? = nil

    private var isHost: Bool {
        guard let currentUserId = SupabaseManager.shared.currentUserId else { return false }
        return gathering.hostId == currentUserId
    }

    var body: some View {
        VStack(spacing: 0) {
            if case .error(let message) = joinState {
                Text(message)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.error)
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.top, Spacing.sm)
            }
            Divider()
            HStack(spacing: Spacing.md) {
                if joinState == .joined || gathering.isJoined {
                    BelongButton(
                        title: "Joined",
                        style: .primary,
                        isFullWidth: true,
                        isDisabled: true,
                        leadingIcon: "checkmark",
                        action: {}
                    )
                    BelongButton(
                        title: "Leave",
                        style: .tertiary,
                        action: onLeave
                    )
                } else if gathering.isMaybe {
                    BelongButton(
                        title: "Maybe",
                        style: .secondary,
                        isFullWidth: true,
                        isDisabled: true,
                        leadingIcon: "questionmark.circle",
                        action: {}
                    )
                    BelongButton(
                        title: "Leave",
                        style: .tertiary,
                        action: onLeave
                    )
                } else if gathering.isFull {
                    BelongButton(
                        title: "Full",
                        style: .primary,
                        isFullWidth: true,
                        isDisabled: true,
                        action: {}
                    )
                } else if isHost {
                    BelongButton(
                        title: "Edit",
                        style: .secondary,
                        isFullWidth: true,
                        leadingIcon: "pencil",
                        action: { onEdit?() }
                    )
                } else {
                    BelongButton(
                        title: "Join",
                        style: .primary,
                        isFullWidth: true,
                        isLoading: joinState == .joining,
                        action: onJoin
                    )
                    BelongButton(
                        title: "Maybe",
                        style: .secondary,
                        action: onMaybe
                    )
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.md)
            .background(BelongColor.surface)
        }
        .shadow(
            color: BelongShadow.level3.color,
            radius: BelongShadow.level3.radius,
            x: BelongShadow.level3.x,
            y: BelongShadow.level3.y
        )
    }
}

// MARK: - Join Confirmation Sheet

struct GatheringJoinConfirmationSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(BelongColor.success)
            Text("\u{2705} You're in!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
            Text("You've joined this gathering. We'll send you a reminder before it starts.")
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
            BelongButton(title: "Got it", style: .primary, isFullWidth: true) {
                dismiss()
            }
        }
        .padding(Spacing.xxl)
    }
}

// MARK: - Edit Gathering Flow

struct EditGatheringFlow: View {
    let gathering: Gathering
    let container: DependencyContainer
    var onSaved: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var editViewModel: CreateGatheringViewModel?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let vm = editViewModel {
                    CustomizeGatheringScreen(viewModel: vm, template: nil, path: $path)
                } else {
                    ProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .navigationTitle("Edit Gathering")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: CreateRoute.self) { route in
                switch route {
                case .previewGathering:
                    if let vm = editViewModel {
                        GatheringPreviewScreen(viewModel: vm, path: $path)
                    }
                case .publishedGathering(let gatheringId):
                    GatheringPublishedScreen(
                        gatheringId: gatheringId,
                        onViewGathering: {
                            onSaved?()
                            dismiss()
                        },
                        onShare: {}
                    )
                default:
                    EmptyView()
                }
            }
        }
        .environment(AppState())
        .environment(container)
        .onAppear {
            if editViewModel == nil {
                let vm = CreateGatheringViewModel(container: container)
                vm.loadDraft(gathering)
                editViewModel = vm
            }
        }
    }
}

#Preview {
    NavigationStack {
        GatheringDetailScreen(
            gathering: SampleData.gatherings[0],
            container: DependencyContainer()
        )
    }
    .environment(AppState())
    .environment(DependencyContainer())
}
