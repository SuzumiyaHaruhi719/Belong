import SwiftUI

struct GatheringAttendeesScreen: View {
    let gatheringId: String
    @State private var attendees: [GatheringMember] = []
    @State private var isLoading = false
    @State private var error: String?
    private let container: DependencyContainer

    init(gatheringId: String, container: DependencyContainer) {
        self.gatheringId = gatheringId
        self.container = container
    }

    var body: some View {
        Group {
            if isLoading && attendees.isEmpty {
                GatheringAttendeesLoadingContent()
            } else if let errorMessage = error, attendees.isEmpty {
                ErrorStateView(
                    message: errorMessage,
                    onRetry: { Task { await loadAttendees() } }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if attendees.isEmpty {
                EmptyStateView(
                    icon: "person.3",
                    title: "No attendees yet",
                    message: "Be the first to join this gathering!"
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GatheringAttendeesListContent(attendees: attendees)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Attendees")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if attendees.isEmpty {
                await loadAttendees()
            }
        }
    }

    private func loadAttendees() async {
        isLoading = true
        error = nil
        do {
            attendees = try await container.gatheringService.fetchAttendees(gatheringId: gatheringId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Loading Content

struct GatheringAttendeesLoadingContent: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { _ in
                HStack(spacing: Spacing.md) {
                    SkeletonView(width: 40, height: 40, cornerRadius: 20)
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        SkeletonView(width: 120, height: 16)
                        SkeletonView(width: 80, height: 12)
                    }
                    Spacer()
                }
                .padding(.horizontal, Layout.screenPadding)
                .frame(height: 56)
            }
        }
    }
}

// MARK: - List Content

struct GatheringAttendeesListContent: View {
    let attendees: [GatheringMember]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(attendees) { member in
                    VStack(spacing: 0) {
                        GatheringAttendeeRow(member: member)
                        if member.id != attendees.last?.id {
                            Divider()
                                .padding(.leading, Layout.screenPadding + Layout.touchTargetMin + Spacing.md)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Attendee Row

struct GatheringAttendeeRow: View {
    let member: GatheringMember

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(emoji: member.userAvatarEmoji, size: .medium)
                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(member.userName)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(1)

                if !member.sharedTags.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        ForEach(member.sharedTags, id: \.self) { tag in
                            Text(tag)
                                .font(BelongFont.caption())
                                .foregroundStyle(BelongColor.tagChipText)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, 2)
                                .background(BelongColor.tagChipBackground)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()

            Button(action: {}) {
                Text("Follow")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.primary)
                    .padding(.horizontal, Spacing.md)
                    .frame(height: 34)
                    .background(BelongColor.surfaceSecondary)
                    .clipShape(Capsule())
            }
            .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
            .accessibilityLabel("Follow \(member.userName)")
        }
        .frame(height: 56)
        .padding(.horizontal, Layout.screenPadding)
    }
}

#Preview {
    NavigationStack {
        GatheringAttendeesScreen(
            gatheringId: SampleData.gatheringIdPho,
            container: DependencyContainer()
        )
    }
}
