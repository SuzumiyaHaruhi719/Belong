import SwiftUI

// MARK: - HomeViewModel
// Drives the Home Feed (S12) and Gathering Detail (S13).
//
// UX Decision: Data loads optimistically with skeleton states.
// Bookmarks toggle instantly (optimistic UI) — no waiting for server.

@Observable
final class HomeViewModel {
    enum LoadState {
        case loading
        case loaded
        case error(String)
    }

    var loadState: LoadState = .loading
    var gatherings: [Gathering] = []
    var topPick: Gathering?
    var selectedFilterTags: [String] = []

    // Gathering detail
    var selectedGathering: Gathering?
    var showJoinConfirmation = false

    // Available filter tags (derived from loaded data)
    var availableFilters: [String] {
        Array(Set(gatherings.flatMap(\.culturalTags))).sorted()
    }

    var filteredGatherings: [Gathering] {
        guard !selectedFilterTags.isEmpty else { return gatherings.filter { $0.status == .upcoming } }
        return gatherings
            .filter { $0.status == .upcoming }
            .filter { gathering in
                !Set(gathering.culturalTags).isDisjoint(with: Set(selectedFilterTags))
            }
    }

    // MARK: Actions

    func loadGatherings() async {
        loadState = .loading
        try? await Task.sleep(for: .seconds(1))

        // Mock data
        gatherings = SampleData.gatherings
        topPick = SampleData.topPick
        loadState = .loaded
    }

    func toggleBookmark(for gathering: Gathering) {
        guard let index = gatherings.firstIndex(where: { $0.id == gathering.id }) else { return }
        gatherings[index].isBookmarked.toggle()
        // Also update top pick if it's the same
        if topPick?.id == gathering.id {
            topPick?.isBookmarked.toggle()
        }
    }

    func joinGathering(_ gathering: Gathering) {
        guard let index = gatherings.firstIndex(where: { $0.id == gathering.id }) else { return }
        gatherings[index].attendeeCount += 1
        selectedGathering = gatherings[index]
        showJoinConfirmation = true
    }

    func retry() async {
        await loadGatherings()
    }
}
