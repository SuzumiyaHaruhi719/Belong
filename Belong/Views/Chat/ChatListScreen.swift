import SwiftUI

// MARK: - ChatListScreen
// UX Redesign: Notifications are NOT a separate tab — they're 3 compact icon
// buttons at the top (Comments, Likes, Mentions). Each opens its own page.
// The remaining 3/4 of the screen is dedicated to chat conversations.
//
// This matches the user's mental model: "Chat" = messages. Notifications
// are a secondary glanceable feature, not competing for equal space.

struct ChatListScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ChatListViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ChatListContent(viewModel: viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BelongColor.background)
            }
        }
        .task {
            if viewModel == nil {
                let vm = ChatListViewModel(
                    chatService: container.chatService,
                    notificationService: container.notificationService
                )
                viewModel = vm
                await vm.loadAll()
            }
        }
    }
}

// MARK: - Content

private struct ChatListContent: View {
    @Bindable var viewModel: ChatListViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Notification icons strip at top
            NotificationIconStrip(viewModel: viewModel)

            Rectangle()
                .fill(BelongColor.divider)
                .frame(height: 1)

            // Chat conversations take the rest of the space
            if let error = viewModel.error {
                ErrorStateView(message: error, onRetry: {
                    Task { await viewModel.loadAll() }
                })
            } else if viewModel.isLoading {
                ChatListLoadingView()
            } else {
                ChatConversationsList(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: ChatRoute.newConversation) {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(BelongColor.primary)
                }
                .accessibilityLabel("New message")
            }
        }
    }
}

// MARK: - Notification Icon Strip
// Three icon buttons: Comments, Likes, Mentions (@).
// Each shows a badge count and opens a filtered notification page.
// UX: Compact horizontal strip takes minimal vertical space,
// leaving maximum room for the conversation list below.

private struct NotificationIconStrip: View {
    let viewModel: ChatListViewModel

    private var commentCount: Int {
        viewModel.notifications.filter { !$0.isRead && $0.type == .comment }.count
    }

    private var likeCount: Int {
        viewModel.notifications.filter { !$0.isRead && $0.type == .like }.count
    }

    private var mentionCount: Int {
        viewModel.notifications.filter { !$0.isRead && $0.type == .mention }.count
    }

    var body: some View {
        HStack(spacing: 0) {
            NotificationIconButton(
                icon: "bubble.left.fill",
                label: "Comments",
                count: commentCount,
                color: BelongColor.primary
            )

            NotificationIconButton(
                icon: "heart.fill",
                label: "Likes",
                count: likeCount,
                color: BelongColor.error
            )

            NotificationIconButton(
                icon: "at",
                label: "Mentions",
                count: mentionCount,
                color: BelongColor.sage
            )
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.sm)
        .background(BelongColor.surface)
    }
}

// MARK: - Single Notification Icon Button

private struct NotificationIconButton: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        Button(action: {}) {
            VStack(spacing: Spacing.xs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                        .frame(width: 44, height: 36)

                    if count > 0 {
                        Text("\(min(count, 99))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(BelongColor.error)
                            .clipShape(Circle())
                            .offset(x: 4, y: -2)
                    }
                }

                Text(label)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), \(count) unread")
    }
}

// MARK: - Conversations List

private struct ChatConversationsList: View {
    let viewModel: ChatListViewModel

    var body: some View {
        if viewModel.filteredConversations.isEmpty {
            EmptyStateView(
                icon: "bubble.left.and.bubble.right",
                title: "No conversations yet",
                message: "Start a conversation with someone from a gathering or your community."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredConversations) { conversation in
                        NavigationLink(value: ChatRoute.conversation(conversation)) {
                            ConversationRow(conversation: conversation)
                        }
                        Divider().padding(.leading, Layout.screenPadding + 56)
                    }
                }
            }
        }
    }
}

// MARK: - Loading

private struct ChatListLoadingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ForEach(0..<5, id: \.self) { _ in
                    HStack(spacing: Spacing.md) {
                        SkeletonView(width: 48, height: 48, cornerRadius: 24)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            SkeletonView(width: 140, height: 16)
                            SkeletonView(width: 200, height: 14)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.vertical, Spacing.sm)
                }
            }
        }
    }
}

// MARK: - Conversation Row

private struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(emoji: conversation.displayAvatar, size: .large)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(conversation.displayTitle)
                        .font(conversation.unreadCount > 0 ? BelongFont.bodySemiBold() : BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    if let date = conversation.lastMessageAt {
                        Text(conversationTimeAgo(date))
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.textTertiary)
                    }
                }
                HStack {
                    Text(conversation.lastMessageText ?? "No messages yet")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineLimit(1)
                    Spacer()
                    if conversation.unreadCount > 0 {
                        BadgeView(count: conversation.unreadCount)
                    }
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.md)
        .background(BelongColor.surface)
        .contentShape(Rectangle())
    }

    private func conversationTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        if interval < 604800 { return "\(Int(interval / 86400))d" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChatListScreen()
            .environment(DependencyContainer())
    }
}
