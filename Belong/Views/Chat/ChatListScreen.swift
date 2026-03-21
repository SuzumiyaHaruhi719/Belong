import SwiftUI

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
            Picker("Segment", selection: $viewModel.selectedSegment) {
                ForEach(ChatSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)

            if let error = viewModel.error {
                ErrorStateView(message: error, onRetry: {
                    Task { await viewModel.loadAll() }
                })
            } else if viewModel.isLoading {
                ChatListLoadingView()
            } else {
                switch viewModel.selectedSegment {
                case .notifications:
                    ChatListNotificationsView(viewModel: viewModel)
                case .messages:
                    ChatListMessagesView(viewModel: viewModel)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
        .navigationTitle("Chat")
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

// MARK: - Notifications Segment

private struct ChatListNotificationsView: View {
    let viewModel: ChatListViewModel

    var body: some View {
        if viewModel.notifications.isEmpty {
            EmptyStateView(
                icon: "bell.slash",
                title: "No notifications",
                message: "When someone interacts with your posts or gatherings, you'll see it here."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if !viewModel.unreadNotifications.isEmpty {
                        ChatListNotificationSectionHeader(title: "New", viewModel: viewModel)
                        ForEach(viewModel.unreadNotifications) { notification in
                            NotificationRow(notification: notification) {
                                Task { await viewModel.markNotificationRead(id: notification.id) }
                            }
                            Divider().padding(.leading, Layout.screenPadding + 48)
                        }
                    }

                    if !viewModel.readNotifications.isEmpty {
                        ChatListNotificationSectionHeader(title: "Earlier", viewModel: nil)
                        ForEach(viewModel.readNotifications) { notification in
                            NotificationRow(notification: notification)
                            Divider().padding(.leading, Layout.screenPadding + 48)
                        }
                    }
                }
            }
        }
    }
}

private struct ChatListNotificationSectionHeader: View {
    let title: String
    let viewModel: ChatListViewModel?

    var body: some View {
        HStack {
            Text(title)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)
            Spacer()
            if let viewModel {
                Button("Mark all read") {
                    Task { await viewModel.markAllNotificationsRead() }
                }
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.primary)
            }
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.sm)
        .background(BelongColor.background)
    }
}

// MARK: - Messages Segment

private struct ChatListMessagesView: View {
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
