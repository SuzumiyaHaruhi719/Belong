import SwiftUI

enum MyEventsTab: String, CaseIterable {
    case upcoming = "Upcoming"
    case past = "Past"
    case saved = "Saved"
}

struct MyEventsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?
    @State private var selectedTab: MyEventsTab = .upcoming

    var body: some View {
        Group {
            if let vm = viewModel {
                MyEventsContent(viewModel: vm, selectedTab: $selectedTab)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("My Events")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(userService: container.userService)
            }
            await viewModel?.loadMyGatherings()
            await viewModel?.loadSaved()
        }
    }
}

// MARK: - Content

private struct MyEventsContent: View {
    @Bindable var viewModel: ProfileViewModel
    @Binding var selectedTab: MyEventsTab

    private var upcomingGatherings: [Gathering] {
        viewModel.myGatherings.filter { !$0.isPast && $0.status == .upcoming }
    }

    private var pastGatherings: [Gathering] {
        viewModel.myGatherings.filter { $0.isPast || $0.status == .completed }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Events", selection: $selectedTab) {
                ForEach(MyEventsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)

            switch selectedTab {
            case .upcoming:
                MyEventsGatheringList(
                    gatherings: upcomingGatherings,
                    emptyIcon: "calendar",
                    emptyTitle: "No upcoming events \u{1F4C5}",
                    emptyMessage: "Join a gathering to see it here.",
                    showChatButton: true
                )
            case .past:
                MyEventsGatheringList(
                    gatherings: pastGatherings,
                    emptyIcon: "clock.arrow.circlepath",
                    emptyTitle: "No past events \u{1F550}",
                    emptyMessage: "Your attended gatherings will appear here.",
                    showRateBadge: true
                )
            case .saved:
                MyEventsSavedList(
                    gatherings: viewModel.savedGatherings,
                    onRemove: { offsets in
                        viewModel.removeSavedGathering(at: offsets)
                    }
                )
            }
        }
    }
}

// MARK: - Gathering List

private struct MyEventsGatheringList: View {
    let gatherings: [Gathering]
    let emptyIcon: String
    let emptyTitle: String
    let emptyMessage: String
    var showChatButton = false
    var showRateBadge = false

    var body: some View {
        if gatherings.isEmpty {
            EmptyStateView(icon: emptyIcon, title: emptyTitle, message: emptyMessage)
        } else {
            ScrollView {
                LazyVStack(spacing: Spacing.base) {
                    ForEach(gatherings) { gathering in
                        NavigationLink(value: GatheringsRoute.detail(gathering)) {
                            ZStack(alignment: .topTrailing) {
                                GatheringCard(gathering: gathering)

                                if showChatButton {
                                    MyEventsOverlayBadge(text: "Chat", color: BelongColor.primary)
                                }

                                if showRateBadge {
                                    MyEventsOverlayBadge(text: "Rate", color: BelongColor.gold)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Layout.screenPadding)
            }
        }
    }
}

// MARK: - Overlay Badge

private struct MyEventsOverlayBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(BelongFont.captionMedium())
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(color)
            .clipShape(Capsule())
            .padding(Spacing.sm)
    }
}

// MARK: - Saved List

private struct MyEventsSavedList: View {
    let gatherings: [Gathering]
    let onRemove: (IndexSet) -> Void

    var body: some View {
        if gatherings.isEmpty {
            EmptyStateView(
                icon: "bookmark",
                title: "No saved events \u{1F516}",
                message: "Bookmark gatherings to find them here."
            )
        } else {
            List {
                ForEach(gatherings) { gathering in
                    NavigationLink(value: GatheringsRoute.detail(gathering)) {
                        GatheringCard(gathering: gathering)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(
                        top: Spacing.sm,
                        leading: Layout.screenPadding,
                        bottom: Spacing.sm,
                        trailing: Layout.screenPadding
                    ))
                }
                .onDelete(perform: onRemove)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    NavigationStack {
        MyEventsScreen()
    }
    .environment(DependencyContainer())
}
