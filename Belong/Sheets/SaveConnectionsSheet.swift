import SwiftUI

struct SaveConnectionsSheet: View {
    let attendees: [GatheringMember]
    @Environment(\.dismiss) private var dismiss
    @State private var connectedIds: Set<String> = []

    private var connectedCount: Int { connectedIds.count }

    var body: some View {
        VStack(spacing: 0) {
            SheetDragHandle()
                .padding(.top, Spacing.md)

            SaveConnectionsHeader()
                .padding(.top, Spacing.lg)

            SaveConnectionsList(
                attendees: attendees,
                connectedIds: $connectedIds
            )

            SaveConnectionsFooter(
                connectedCount: connectedCount,
                dismiss: dismiss
            )
        }
        .background(BelongColor.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Header

private struct SaveConnectionsHeader: View {
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text("Save your connections")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Stay in touch with people you met")
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.base)
    }
}

// MARK: - Attendee List

private struct SaveConnectionsList: View {
    let attendees: [GatheringMember]
    @Binding var connectedIds: Set<String>

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(attendees) { member in
                    SaveConnectionRow(
                        member: member,
                        isConnected: connectedIds.contains(member.userId)
                    ) {
                        toggleConnection(member.userId)
                    }

                    if member.id != attendees.last?.id {
                        Divider()
                            .padding(.leading, Layout.screenPadding + 56)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func toggleConnection(_ userId: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if connectedIds.contains(userId) {
                connectedIds.remove(userId)
            } else {
                connectedIds.insert(userId)
            }
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

private struct SaveConnectionRow: View {
    let member: GatheringMember
    let isConnected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(emoji: member.userAvatarEmoji, size: .medium)
                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.userName)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(1)

                if !member.sharedTags.isEmpty {
                    Text(member.sharedTags.prefix(3).joined(separator: " · "))
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            SaveConnectionButton(isConnected: isConnected, onTap: onTap)
        }
        .frame(height: 56)
        .padding(.horizontal, Layout.screenPadding)
    }
}

private struct SaveConnectionButton: View {
    let isConnected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.xs) {
                if isConnected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                Text(isConnected ? "Connected" : "Connect")
                    .font(BelongFont.secondaryMedium())
            }
            .foregroundStyle(isConnected ? BelongColor.success : BelongColor.primary)
            .padding(.horizontal, Spacing.md)
            .frame(height: 34)
            .background(
                isConnected ? BelongColor.successLight : BelongColor.surfaceSecondary
            )
            .clipShape(Capsule())
        }
        .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
        .accessibilityLabel(isConnected ? "Connected to \(isConnected)" : "Connect")
        .accessibilityHint(isConnected ? "Tap to disconnect" : "Tap to connect")
    }
}

// MARK: - Footer

private struct SaveConnectionsFooter: View {
    let connectedCount: Int
    let dismiss: DismissAction

    var body: some View {
        VStack(spacing: Spacing.md) {
            BelongButton(
                title: connectedCount > 0 ? "Done (\(connectedCount) connected)" : "Done",
                style: .primary,
                isFullWidth: true
            ) {
                dismiss()
            }
            .accessibilityLabel("Done, \(connectedCount) connections saved")

            Button(action: { dismiss() }) {
                Text("Skip")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .accessibilityLabel("Skip saving connections")
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.base)
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SaveConnectionsSheet(
                attendees: [
                    GatheringMember(gatheringId: "g1", userId: "u1", status: .joined, joinedAt: Date(), userName: "Min-Jun Park", userAvatarEmoji: "🧑‍🍳", sharedTags: ["Korean", "Food"]),
                    GatheringMember(gatheringId: "g1", userId: "u2", status: .joined, joinedAt: Date(), userName: "Sakura Tanaka", userAvatarEmoji: "🎎", sharedTags: ["Japanese", "Art"]),
                    GatheringMember(gatheringId: "g1", userId: "u3", status: .joined, joinedAt: Date(), userName: "Wei Lin", userAvatarEmoji: "🌸", sharedTags: ["Chinese"]),
                    GatheringMember(gatheringId: "g1", userId: "u4", status: .joined, joinedAt: Date(), userName: "Priya Sharma", userAvatarEmoji: "🪷", sharedTags: ["Indian", "Dance"]),
                    GatheringMember(gatheringId: "g1", userId: "u5", status: .joined, joinedAt: Date(), userName: "Ahmed Hassan", userAvatarEmoji: "🕌", sharedTags: ["Arabic", "Music"]),
                    GatheringMember(gatheringId: "g1", userId: "u6", status: .joined, joinedAt: Date(), userName: "Sofia Rodriguez", userAvatarEmoji: "💃", sharedTags: ["Latin"]),
                ]
            )
        }
}
