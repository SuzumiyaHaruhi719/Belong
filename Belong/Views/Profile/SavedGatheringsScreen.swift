import SwiftUI

// MARK: - SavedGatheringsScreen (S25)
// Lists bookmarked gatherings with swipe-to-delete.
// UX Decision: Compact cards save space in a list context.
// Empty state guides users back to discovery.

struct SavedGatheringsScreen: View {
    @Bindable var viewModel: ProfileViewModel
    @State private var showUndoBanner = false
    @State private var lastDeleted: (gathering: Gathering, index: Int)?
    @State private var undoTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.savedGatherings.isEmpty {
                EmptyStateView(
                    systemImage: "bookmark",
                    title: "No saved gatherings",
                    message: "Bookmark gatherings you're interested in and they'll show up here."
                )
            } else {
                List {
                    ForEach(viewModel.savedGatherings) { gathering in
                        GatheringCard(gathering: gathering, isCompact: true)
                            .listRowInsets(EdgeInsets(
                                top: Spacing.sm,
                                leading: Layout.screenPadding,
                                bottom: Spacing.sm,
                                trailing: Layout.screenPadding
                            ))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete { offsets in
                        handleDelete(at: offsets)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }

            // Undo banner
            if showUndoBanner {
                HStack {
                    Text("Gathering removed")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textPrimary)

                    Spacer()

                    Button {
                        undoDelete()
                    } label: {
                        Text("Undo")
                            .font(BelongFont.bodySemiBold())
                            .foregroundStyle(BelongColor.primary)
                    }
                    .accessibilityLabel("Undo remove gathering")
                }
                .padding(Spacing.base)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.sm)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: showUndoBanner)
    }

    private func handleDelete(at offsets: IndexSet) {
        // Cancel any pending undo timeout
        undoTask?.cancel()

        guard let index = offsets.first else { return }
        let gathering = viewModel.savedGatherings[index]
        lastDeleted = (gathering, index)

        viewModel.removeSavedGathering(at: offsets)
        showUndoBanner = true

        // Auto-dismiss banner after 3 seconds
        undoTask = Task {
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                await MainActor.run {
                    showUndoBanner = false
                    lastDeleted = nil
                }
            }
        }
    }

    private func undoDelete() {
        undoTask?.cancel()
        guard let deleted = lastDeleted else { return }
        let insertIndex = min(deleted.index, viewModel.savedGatherings.count)
        viewModel.savedGatherings.insert(deleted.gathering, at: insertIndex)
        showUndoBanner = false
        lastDeleted = nil
    }
}

#Preview("With Saved") {
    NavigationStack {
        SavedGatheringsScreen(viewModel: ProfileViewModel())
    }
}

#Preview("Empty") {
    NavigationStack {
        SavedGatheringsScreen(viewModel: {
            let vm = ProfileViewModel()
            vm.savedGatherings = []
            return vm
        }())
    }
}
