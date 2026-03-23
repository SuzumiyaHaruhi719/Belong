import SwiftUI

struct ChatInfoScreen: View {
    let conversationId: String
    @Environment(DependencyContainer.self) private var container
    @State private var conversation: Conversation?
    @State private var isLoading = true
    @State private var isMuted = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let conversation {
                ChatInfoContent(
                    conversation: conversation,
                    isMuted: $isMuted
                )
            } else {
                ErrorStateView(message: "Could not load conversation info")
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                let convos = try await container.chatService.fetchConversations()
                conversation = convos.first { $0.id == conversationId }
            } catch {}
            isLoading = false
        }
    }
}

// MARK: - Content

private struct ChatInfoContent: View {
    let conversation: Conversation
    @Binding var isMuted: Bool

    var body: some View {
        List {
            switch conversation.type {
            case .dm:
                ChatInfoDMSections(conversation: conversation, isMuted: $isMuted)
            case .gatheringGroup:
                ChatInfoGroupSections(conversation: conversation, isMuted: $isMuted)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - DM Sections

private struct ChatInfoDMSections: View {
    let conversation: Conversation
    @Binding var isMuted: Bool
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    private var otherMember: ConversationMemberInfo? {
        conversation.members.first { $0.userId != SupabaseManager.shared.currentUserId }
    }

    var body: some View {
        // Profile preview
        Section {
            if let member = otherMember {
                NavigationLink(value: ProfileRoute.userProfile(member.userId)) {
                    VStack(spacing: Spacing.md) {
                        AvatarView(imageURL: member.avatarURL, emoji: member.avatarEmoji, size: .xlarge)
                        Text(member.displayName)
                            .font(BelongFont.h2())
                            .foregroundStyle(BelongColor.textPrimary)
                        Text("View Profile")
                            .font(BelongFont.secondaryMedium())
                            .foregroundStyle(BelongColor.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            }
        }

        // Shared Media
        Section("Shared Media") {
            Label("Photos & Media", systemImage: "photo.on.rectangle")
                .foregroundStyle(BelongColor.textTertiary)
        }

        // Actions
        Section {
            Toggle(isOn: $isMuted) {
                Label("Mute Notifications", systemImage: "bell.slash")
                    .foregroundStyle(BelongColor.textPrimary)
            }
            .tint(BelongColor.primary)

            Button(role: .destructive) {
                guard let userId = otherMember?.userId else { return }
                Task {
                    do {
                        try await container.userService.block(userId: userId)
                        dismiss()
                    } catch {
                        // Block failed silently for now
                    }
                }
            } label: {
                Label("Block User", systemImage: "hand.raised")
            }
        }
    }
}

// MARK: - Group Sections

private struct ChatInfoGroupSections: View {
    let conversation: Conversation
    @Binding var isMuted: Bool
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // Gathering header
        Section {
            VStack(spacing: Spacing.sm) {
                AvatarView(emoji: conversation.displayAvatar, size: .xlarge)
                Text(conversation.displayTitle)
                    .font(BelongFont.h2())
                    .foregroundStyle(BelongColor.textPrimary)
                Text("\(conversation.members.count) members")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .listRowBackground(Color.clear)
        }

        // Members
        Section("Members") {
            ForEach(conversation.members, id: \.userId) { member in
                NavigationLink(value: ProfileRoute.userProfile(member.userId)) {
                    UserRow(
                        avatarURL: member.avatarURL,
                        avatarEmoji: member.avatarEmoji,
                        name: member.displayName
                    )
                    .listRowInsets(EdgeInsets())
                }
                .buttonStyle(.plain)
            }
        }

        // Shared Media
        Section("Shared Media") {
            Label("Photos & Media", systemImage: "photo.on.rectangle")
                .foregroundStyle(BelongColor.textTertiary)
        }

        // Actions
        Section {
            Toggle(isOn: $isMuted) {
                Label("Mute Notifications", systemImage: "bell.slash")
                    .foregroundStyle(BelongColor.textPrimary)
            }
            .tint(BelongColor.primary)

            Button(role: .destructive) {
                guard let gatheringId = conversation.gatheringId else { return }
                Task {
                    do {
                        try await container.gatheringService.leave(gatheringId: gatheringId)
                        dismiss()
                    } catch {
                        // Leave failed silently for now
                    }
                }
            } label: {
                Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}

// MARK: - Preview

#Preview("DM Info") {
    NavigationStack {
        ChatInfoScreen(conversationId: SampleData.conversationIdMaiYuki)
            .environment(DependencyContainer())
    }
}

#Preview("Group Info") {
    NavigationStack {
        ChatInfoScreen(conversationId: SampleData.conversationIdPhoGroup)
            .environment(DependencyContainer())
    }
}
