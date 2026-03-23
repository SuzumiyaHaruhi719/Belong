import SwiftUI

@Observable @MainActor
final class GatheringsViewModel {
    // MARK: - State

    var gatherings: [Gathering] = []
    var topPick: Gathering?
    var isLoading = false
    var isLoadingMore = false
    var hasMorePages = true
    var currentPage = 0
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
            // Fetch feed (empty city = all cities, page 0 = first page)
            let feedResult = try await container.gatheringService.fetchFeed(city: "", page: 0, filter: nil)
            gatherings = feedResult
            topPick = feedResult.first

            // Try recommendations separately (may fail if user has no tag data yet)
            // Use empty city — the RPC reads the user's city from their profile
            if let rec = try? await container.gatheringService.fetchRecommended(city: "", limit: 1),
               let first = rec.first {
                topPick = first
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        currentPage = 0
        hasMorePages = true
        await loadFeed()
    }

    func loadMore() async {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        let nextPage = currentPage + 1
        do {
            let more = try await container.gatheringService.fetchFeed(city: "", page: nextPage, filter: nil)
            if more.isEmpty {
                hasMorePages = false
            } else {
                let existingIds = Set(gatherings.map(\.id))
                let newItems = more.filter { !existingIds.contains($0.id) }
                gatherings.append(contentsOf: newItems)
                currentPage = nextPage
            }
        } catch {
            // Silent pagination failure — user can pull to refresh
        }
        isLoadingMore = false
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
