import SwiftUI

struct SavedGatheringsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                SavedGatheringsContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Saved Gatherings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = ProfileViewModel(userService: container.userService)
                vm.gatheringService = container.gatheringService
                viewModel = vm
            }
            await viewModel?.loadSaved()
        }
        .onAppear {
            if viewModel != nil {
                Task { await viewModel?.loadSaved() }
            }
        }
    }
}

// MARK: - Content

private struct SavedGatheringsContent: View {
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.savedGatherings.isEmpty {
                ScrollView {
                    VStack(spacing: Spacing.base) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonCard()
                        }
                    }
                    .padding(Layout.screenPadding)
                }
            } else if let error = viewModel.error, viewModel.savedGatherings.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadSaved() }
                }
            } else if viewModel.savedGatherings.isEmpty {
                EmptyStateView(
                    icon: "bookmark",
                    title: "Nothing saved yet",
                    message: "Tap the bookmark icon on any gathering to save it for later."
                )
            } else {
                List {
                    ForEach(viewModel.savedGatherings) { gathering in
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
                    .onDelete { offsets in
                        viewModel.removeSavedGathering(at: offsets)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SavedGatheringsScreen()
    }
    .environment(DependencyContainer())
}
