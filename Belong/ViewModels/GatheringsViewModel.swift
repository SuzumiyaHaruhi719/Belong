import SwiftUI

@Observable @MainActor
final class GatheringsViewModel {
    // MARK: - State

    var gatherings: [Gathering] = []
    var topPick: Gathering?
    var isLoading = false
    var error: String?
    var selectedFilter: String? = nil

    var filterOptions: [String] {
        let allTags = gatherings.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }

    var filteredGatherings: [Gathering] {
        guard let filter = selectedFilter else { return gatherings }
        return gatherings.filter { $0.tags.contains(filter) }
    }

    // MARK: - FilterChipRow binding helper

    /// Bridges the optional selectedFilter to the "All" / tag string that FilterChipRow expects.
    var selectedFilterBinding: String {
        get { selectedFilter ?? "All" }
        set { selectedFilter = newValue == "All" ? nil : newValue }
    }

    // MARK: - Dependencies

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Actions

    func loadFeed() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            async let recommended = container.gatheringService.fetchRecommended(city: "Melbourne", limit: 1)
            async let feed = container.gatheringService.fetchFeed(city: "Melbourne", page: 1, filter: nil)
            let recResult = try await recommended
            let feedResult = try await feed
            topPick = recResult.first
            gatherings = feedResult
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        await loadFeed()
    }

    func toggleBookmark(id: String) {
        guard let index = gatherings.firstIndex(where: { $0.id == id }) else { return }
        let isCurrentlyBookmarked = gatherings[index].isBookmarked
        gatherings[index].isBookmarked.toggle()
        if topPick?.id == id {
            topPick?.isBookmarked.toggle()
        }
        Task {
            do {
                if isCurrentlyBookmarked {
                    try await container.gatheringService.unsave(gatheringId: id)
                } else {
                    try await container.gatheringService.save(gatheringId: id)
                }
            } catch {
                // Revert on failure
                if let idx = gatherings.firstIndex(where: { $0.id == id }) {
                    gatherings[idx].isBookmarked = isCurrentlyBookmarked
                }
                if topPick?.id == id {
                    topPick?.isBookmarked = isCurrentlyBookmarked
                }
            }
        }
    }
}
