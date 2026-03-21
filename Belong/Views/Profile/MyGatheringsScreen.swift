import SwiftUI

struct MyGatheringsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                MyGatheringsContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("My Gatherings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(userService: container.userService)
            }
            await viewModel?.loadMyGatherings()
        }
    }
}

// MARK: - Content

private struct MyGatheringsContent: View {
    @Bindable var viewModel: ProfileViewModel

    private var draftGatherings: [Gathering] {
        viewModel.myGatherings.filter { $0.isDraft }
    }

    private var publishedGatherings: [Gathering] {
        viewModel.myGatherings.filter { !$0.isDraft }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.myGatherings.isEmpty {
                ScrollView {
                    VStack(spacing: Spacing.base) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonCard()
                        }
                    }
                    .padding(Layout.screenPadding)
                }
            } else if let error = viewModel.error, viewModel.myGatherings.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadMyGatherings() }
                }
            } else if viewModel.myGatherings.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.plus",
                    title: "No hosted gatherings",
                    message: "Create your first gathering to bring people together."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.base) {
                        if !draftGatherings.isEmpty {
                            MyGatheringsDraftBanner(count: draftGatherings.count)
                        }

                        ForEach(publishedGatherings) { gathering in
                            NavigationLink(value: GatheringsRoute.detail(gathering)) {
                                MyGatheringsStatusCard(gathering: gathering)
                            }
                            .buttonStyle(.plain)
                        }

                        if !draftGatherings.isEmpty {
                            MyGatheringsSectionHeader(title: "Drafts")
                            ForEach(draftGatherings) { gathering in
                                NavigationLink(value: GatheringsRoute.detail(gathering)) {
                                    MyGatheringsStatusCard(gathering: gathering)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(Layout.screenPadding)
                    .padding(.bottom, Spacing.xxxl)
                }
            }
        }
    }
}

// MARK: - Draft Banner

private struct MyGatheringsDraftBanner: View {
    let count: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "doc.text")
                .foregroundStyle(BelongColor.warning)
            Text("You have \(count) draft\(count == 1 ? "" : "s")")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textPrimary)
            Spacer()
        }
        .padding(Spacing.md)
        .background(BelongColor.warningLight)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
    }
}

// MARK: - Section Header

private struct MyGatheringsSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(BelongFont.h3())
            .foregroundStyle(BelongColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.sm)
    }
}

// MARK: - Status Card

private struct MyGatheringsStatusCard: View {
    let gathering: Gathering

    var body: some View {
        ZStack(alignment: .topTrailing) {
            GatheringCard(gathering: gathering)
            MyGatheringsStatusBadge(status: gathering.status, isDraft: gathering.isDraft)
        }
    }
}

private struct MyGatheringsStatusBadge: View {
    let status: GatheringStatus
    let isDraft: Bool

    private var badgeText: String {
        if isDraft { return "Draft" }
        return status.rawValue.capitalized
    }

    private var badgeColor: Color {
        if isDraft { return BelongColor.warning }
        switch status {
        case .upcoming: return BelongColor.primary
        case .ongoing: return BelongColor.success
        case .completed: return BelongColor.textSecondary
        case .cancelled: return BelongColor.error
        }
    }

    var body: some View {
        Text(badgeText)
            .font(BelongFont.captionMedium())
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(badgeColor)
            .clipShape(Capsule())
            .padding(Spacing.sm)
    }
}

#Preview {
    NavigationStack {
        MyGatheringsScreen()
    }
    .environment(DependencyContainer())
}
