import SwiftUI

struct ChatDetailScreen: View {
    let conversation: Conversation
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    @Environment(InAppBannerManager.self) private var bannerManager
    @State private var viewModel: ChatDetailViewModel?

    /// When true, hides DM gating (used by GroupChatScreen wrapper).
    var isGatheringContext: Bool = false

    var body: some View {
        Group {
            if let viewModel {
                ChatDetailContent(
                    viewModel: viewModel,
                    conversation: conversation,
                    isGatheringContext: isGatheringContext
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BelongColor.background)
            }
        }
        .task {
            if viewModel == nil {
                let vm = ChatDetailViewModel(chatService: container.chatService)
                vm.conversation = conversation
                viewModel = vm
                await vm.loadMessages(conversationId: conversation.id)
                // Refresh badge from backend after marking as read (avoids stale subtraction)
                await refreshBadgeCount()
            }
        }
        .onAppear {
            bannerManager.activeConversationId = conversation.id
        }
        .onDisappear {
            bannerManager.activeConversationId = nil
            Task { await viewModel?.unsubscribe() }
        }
    }

    /// Fetch true unread count from backend to correct any drift from incremental updates.
    private func refreshBadgeCount() async {
        do {
            let conversations = try await container.chatService.fetchConversations()
            appState.unreadChatCount = conversations.reduce(0) { $0 + $1.unreadCount }
        } catch {
            // Badge refresh is best-effort
        }
    }
}

// MARK: - Content

private struct ChatDetailContent: View {
    @Bindable var viewModel: ChatDetailViewModel
    let conversation: Conversation
    let isGatheringContext: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Gathering header info
            if isGatheringContext, let gatheringId = conversation.gatheringId {
                GatheringChatHeader(title: conversation.displayTitle, memberCount: conversation.members.count)
            }

            // Pinned message (example: first message in gathering group)
            if conversation.type == .gatheringGroup,
               let pinned = viewModel.messages.first(where: { $0.messageType == .text && !$0.isCurrentUser }) {
                PinnedMessageBanner(
                    senderName: pinned.senderName,
                    messagePreview: pinned.content ?? ""
                )
            }

            // Messages list
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.error {
                ErrorStateView(message: error, onRetry: {
                    Task { await viewModel.loadMessages(conversationId: conversation.id) }
                })
            } else if viewModel.messages.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "bubble.left",
                    title: "No messages yet",
                    message: "Send the first message to start the conversation."
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .contextMenu {
                                    if message.messageType != .system {
                                        Button {
                                            viewModel.beginReply(to: message)
                                        } label: {
                                            Label("Reply", systemImage: "arrowshape.turn.up.left")
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.vertical, Spacing.sm)
                }
                .defaultScrollAnchor(.bottom)
            }

            // DM gating banner
            if !isGatheringContext, viewModel.showDMGatingBanner, let gatingMessage = viewModel.dmGatingMessage {
                DMGatingBanner(message: gatingMessage)
            }

            // Reply preview
            if let replyMsg = viewModel.replyingTo {
                ReplyPreviewBar(
                    senderName: replyMsg.senderName,
                    messagePreview: replyMsg.content ?? "",
                    onCancel: { viewModel.cancelReply() }
                )
            }

            // Composer
            if viewModel.isComposerDisabled && !isGatheringContext {
                // Show disabled state - composer is hidden
            } else {
                ChatComposer(text: $viewModel.newMessageText) {
                    Task { await viewModel.sendMessage() }
                }
                .disabled(viewModel.isSending)
            }
        }
        .background(BelongColor.background)
        .navigationTitle(conversation.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: ChatRoute.conversationInfo(conversation.id)) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(BelongColor.primary)
                }
                .accessibilityLabel("Conversation info")
            }
        }
    }
}

// MARK: - DM Gating Banner

private struct DMGatingBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "lock.fill")
                .font(.system(size: 14))
                .foregroundStyle(BelongColor.info)
            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(BelongColor.surfaceSecondary)
    }
}

// MARK: - Gathering Chat Header

private struct GatheringChatHeader: View {
    let title: String
    let memberCount: Int

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(title)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)
            Text("\(memberCount) members")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(BelongColor.surfaceSecondary)
    }
}

// MARK: - Preview

#Preview("DM - Mutual Follow") {
    NavigationStack {
        ChatDetailScreen(conversation: SampleData.conversations[0])
            .environment(DependencyContainer())
    }
}

#Preview("DM - Not Mutual") {
    NavigationStack {
        ChatDetailScreen(conversation: SampleData.conversations[2])
            .environment(DependencyContainer())
    }
}

#Preview("Group Chat") {
    NavigationStack {
        ChatDetailScreen(conversation: SampleData.conversations[1])
            .environment(DependencyContainer())
    }
}
