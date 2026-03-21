import SwiftUI

enum BrowsingHistoryTab: String, CaseIterable {
    case posts = "Posts"
    case gatherings = "Gatherings"
}

struct BrowsingHistoryScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?
    @State private var selectedTab: BrowsingHistoryTab = .posts

    var body: some View {
        Group {
            if let vm = viewModel {
                BrowsingHistoryContent(viewModel: vm, selectedTab: $selectedTab)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Browsing History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear All") {
                    Task { await viewModel?.clearHistory() }
                }
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.primary)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(userService: container.userService)
            }
            await viewModel?.loadHistory()
        }
    }
}

// MARK: - Content

private struct BrowsingHistoryContent: View {
    @Bindable var viewModel: ProfileViewModel
    @Binding var selectedTab: BrowsingHistoryTab

    private var filteredHistory: [BrowseHistoryEntry] {
        switch selectedTab {
        case .posts:
            return viewModel.browseHistory.filter { $0.targetType == .post }
        case .gatherings:
            return viewModel.browseHistory.filter { $0.targetType == .gathering }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("History", selection: $selectedTab) {
                ForEach(BrowsingHistoryTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)

            if viewModel.isLoading && viewModel.browseHistory.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error, viewModel.browseHistory.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadHistory() }
                }
            } else if filteredHistory.isEmpty {
                EmptyStateView(
                    icon: "clock",
                    title: "No history",
                    message: "Your browsing history will appear here."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredHistory) { entry in
                            BrowsingHistoryRow(entry: entry)
                            Divider()
                                .padding(.leading, Layout.screenPadding + 56 + Spacing.md)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - History Row

private struct BrowsingHistoryRow: View {
    let entry: BrowseHistoryEntry

    private var timeAgoText: String {
        let interval = Date().timeIntervalSince(entry.viewedAt)
        let hours = Int(interval / 3600)
        if hours < 1 { return "Just now" }
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            BrowsingHistoryThumbnail(imageURL: entry.imageURL, targetType: entry.targetType)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(entry.title)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(2)
                Text(timeAgoText)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(BelongColor.textTertiary)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Thumbnail

private struct BrowsingHistoryThumbnail: View {
    let imageURL: URL?
    let targetType: BrowseTargetType

    var body: some View {
        Group {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        thumbnailPlaceholder
                    }
                }
            } else {
                thumbnailPlaceholder
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
    }

    private var thumbnailPlaceholder: some View {
        ZStack {
            BelongColor.surfaceSecondary
            Image(systemName: targetType == .post ? "text.quote" : "person.3")
                .font(.system(size: 16))
                .foregroundStyle(BelongColor.textTertiary)
        }
    }
}

#Preview {
    NavigationStack {
        BrowsingHistoryScreen()
    }
    .environment(DependencyContainer())
}
