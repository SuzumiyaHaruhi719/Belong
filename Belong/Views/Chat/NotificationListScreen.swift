import SwiftUI

// MARK: - NotificationListScreen
// Filtered notification page for Comments, Likes, or Mentions.
// Each of the 3 icon buttons in the ChatListScreen's notification strip
// navigates here with a different filter.
//
// UX Decisions:
// - Dedicated page per type reduces cognitive load — users see ONLY
//   the notifications they tapped on, not a mixed feed.
// - "Mark all as read" in toolbar for quick bulk action.
// - Empty state is specific to the type ("No comments yet" vs generic).
// - Tapping a notification marks it read + could deep-link to content.
// - Unread notifications have a subtle peach background highlight.

enum NotificationFilter: String {
    case comments = "Comments"
    case likes = "Likes"
    case mentions = "Mentions"

    var matchingTypes: [NotificationType] {
        switch self {
        case .comments: [.comment]
        case .likes: [.like]
        case .mentions: [.mention]
        }
    }

    var icon: String {
        switch self {
        case .comments: "bubble.left.fill"
        case .likes: "heart.fill"
        case .mentions: "at"
        }
    }

    var iconColor: Color {
        switch self {
        case .comments: BelongColor.primary
        case .likes: BelongColor.error
        case .mentions: BelongColor.sage
        }
    }

    var emptyTitle: String {
        switch self {
        case .comments: "No comments yet"
        case .likes: "No likes yet"
        case .mentions: "No mentions yet"
        }
    }

    var emptyMessage: String {
        switch self {
        case .comments: "When someone comments on your posts, you'll see it here."
        case .likes: "When someone likes your posts or gatherings, you'll see it here."
        case .mentions: "When someone @mentions you, you'll see it here."
        }
    }
}

struct NotificationListScreen: View {
    let filter: NotificationFilter
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: NotificationListViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                NotificationListContent(viewModel: vm, filter: filter)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle(filter.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = NotificationListViewModel(
                    notificationService: container.notificationService,
                    filter: filter
                )
                viewModel = vm
                await vm.load()
            }
        }
    }
}

// MARK: - Content

private struct NotificationListContent: View {
    @Bindable var viewModel: NotificationListViewModel
    let filter: NotificationFilter

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                NotificationListLoading()
            } else if let error = viewModel.error, viewModel.notifications.isEmpty {
                ErrorStateView(message: error, onRetry: {
                    Task { await viewModel.load() }
                })
            } else if viewModel.notifications.isEmpty {
                NotificationListEmpty(filter: filter)
            } else {
                NotificationListLoaded(viewModel: viewModel, filter: filter)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.hasUnread {
                    Button("Read all") {
                        Task { await viewModel.markAllRead() }
                    }
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.primary)
                }
            }
        }
    }
}

// MARK: - Loaded

private struct NotificationListLoaded: View {
    @Bindable var viewModel: NotificationListViewModel
    let filter: NotificationFilter

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Unread section
                if !viewModel.unread.isEmpty {
                    NotificationSectionHeader(title: "New", count: viewModel.unread.count)

                    ForEach(viewModel.unread) { notification in
                        NotificationRow(notification: notification) {
                            Task { await viewModel.markRead(id: notification.id) }
                        }
                        Divider().padding(.leading, Layout.screenPadding + 48)
                    }
                }

                // Read section
                if !viewModel.read.isEmpty {
                    NotificationSectionHeader(title: "Earlier", count: nil)
                        .padding(.top, viewModel.unread.isEmpty ? 0 : Spacing.md)

                    ForEach(viewModel.read) { notification in
                        NotificationRow(notification: notification)
                        Divider().padding(.leading, Layout.screenPadding + 48)
                    }
                }
            }
            .padding(.bottom, Spacing.xxl)
        }
        .refreshable {
            await viewModel.load()
        }
    }
}

// MARK: - Section Header

private struct NotificationSectionHeader: View {
    let title: String
    let count: Int?

    var body: some View {
        HStack {
            Text(title)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)

            if let count {
                Text("\(count)")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textOnPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(BelongColor.primary)
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.sm)
        .background(BelongColor.background)
    }
}

// MARK: - Empty

private struct NotificationListEmpty: View {
    let filter: NotificationFilter

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: filter.icon)
                .font(.system(size: 48))
                .foregroundStyle(filter.iconColor.opacity(0.4))

            Text(filter.emptyTitle)
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)

            Text(filter.emptyMessage)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Layout.screenPadding)
    }
}

// MARK: - Loading

private struct NotificationListLoading: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { _ in
                    HStack(spacing: Spacing.md) {
                        SkeletonView(width: 36, height: 36, cornerRadius: 18)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            SkeletonView(width: 200, height: 14)
                            SkeletonView(width: 120, height: 12)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Layout.screenPadding)
                    .padding(.vertical, Spacing.md)
                    Divider().padding(.leading, Layout.screenPadding + 48)
                }
            }
        }
    }
}

#Preview("Comments") {
    NavigationStack {
        NotificationListScreen(filter: .comments)
            .environment(DependencyContainer())
    }
}

#Preview("Likes - Empty") {
    NavigationStack {
        NotificationListScreen(filter: .likes)
            .environment(DependencyContainer())
    }
}
