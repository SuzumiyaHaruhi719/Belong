import SwiftUI

struct GatheringSearchScreen: View {
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var results: [Gathering] = []
    @State private var isSearching = false
    @State private var hasSearched = false
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    private var filterOptions: [String] {
        let allTags = results.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }

    private var filteredResults: [Gathering] {
        if selectedFilter == "All" { return results }
        return results.filter { $0.tags.contains(selectedFilter) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBar(
                text: $searchText,
                placeholder: "Search gatherings...",
                onDebouncedChange: { query in
                    Task { await performSearch(query: query) }
                }
            )
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.sm)

            // Filter chips (only when we have results)
            if !results.isEmpty {
                FilterChipRow(
                    filters: filterOptions,
                    selected: $selectedFilter
                )
                .padding(.vertical, Spacing.sm)
            }

            // Content
            if isSearching {
                GatheringSearchLoadingContent()
            } else if !hasSearched {
                GatheringSearchInitialContent()
            } else if filteredResults.isEmpty {
                GatheringSearchNoResultsContent()
            } else {
                GatheringSearchResultsContent(
                    results: filteredResults,
                    container: container
                )
            }

            Spacer()
        }
        .background(BelongColor.background)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            hasSearched = false
            selectedFilter = "All"
            return
        }
        isSearching = true
        do {
            results = try await container.gatheringService.search(query: trimmed, city: "Melbourne")
            hasSearched = true
            selectedFilter = "All"
        } catch {
            results = []
            hasSearched = true
        }
        isSearching = false
    }
}

// MARK: - Initial Content

struct GatheringSearchInitialContent: View {
    var body: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Discover gatherings",
            message: "Search for gatherings by name, tag, or location"
        )
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxxl)
    }
}

// MARK: - Loading

struct GatheringSearchLoadingContent: View {
    var body: some View {
        VStack(spacing: Spacing.base) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonCard()
            }
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.base)
    }
}

// MARK: - No Results

struct GatheringSearchNoResultsContent: View {
    var body: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No results",
            message: "No gatherings match your search"
        )
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxxxl)
    }
}

// MARK: - Results

struct GatheringSearchResultsContent: View {
    let results: [Gathering]
    let container: DependencyContainer

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.base) {
                ForEach(results) { gathering in
                    NavigationLink(value: GatheringsRoute.detail(gathering)) {
                        GatheringCard(gathering: gathering)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Layout.screenPadding)
                }
            }
            .padding(.vertical, Spacing.base)
        }
    }
}

#Preview {
    NavigationStack {
        GatheringSearchScreen(container: DependencyContainer())
    }
}
