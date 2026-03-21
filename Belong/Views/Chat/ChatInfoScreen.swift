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

    private var otherMember: ConversationMemberInfo? {
        conversation.members.first { $0.userId != SampleData.currentUser.id }
    }

    var body: some View {
        // Profile preview
        Section {
            if let member = otherMember {
                VStack(spacing: Spacing.md) {
                    AvatarView(imageURL: member.avatarURL, emoji: member.avatarEmoji, size: .xlarge)
                    Text(member.displayName)
                        .font(BelongFont.h2())
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .listRowBackground(Color.clear)
            }
        }

        // Shared Media
        Section("Shared Media") {
            NavigationLink(value: ChatRoute.conversationInfo(conversation.id)) {
                Label("Photos & Media", systemImage: "photo.on.rectangle")
                    .foregroundStyle(BelongColor.textPrimary)
            }
        }

        // Actions
        Section {
            Toggle(isOn: $isMuted) {
                Label("Mute Notifications", systemImage: "bell.slash")
                    .foregroundStyle(BelongColor.textPrimary)
            }
            .tint(BelongColor.primary)

            Button(role: .destructive) {
                // Block action placeholder
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
                UserRow(
                    avatarURL: member.avatarURL,
                    avatarEmoji: member.avatarEmoji,
                    name: member.displayName
                )
                .listRowInsets(EdgeInsets())
            }
        }

        // Shared Media
        Section("Shared Media") {
            NavigationLink(value: ChatRoute.conversationInfo(conversation.id)) {
                Label("Photos & Media", systemImage: "photo.on.rectangle")
                    .foregroundStyle(BelongColor.textPrimary)
            }
        }

        // Actions
        Section {
            Toggle(isOn: $isMuted) {
                Label("Mute Notifications", systemImage: "bell.slash")
                    .foregroundStyle(BelongColor.textPrimary)
            }
            .tint(BelongColor.primary)

            Button(role: .destructive) {
                // Leave group placeholder
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
