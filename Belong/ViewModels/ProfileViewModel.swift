import SwiftUI

// MARK: - ProfileViewModel
// Drives S23–S26: Profile, Edit Cultural Tags, Saved Gatherings, Settings.
// Enhanced with browsing history, join history, and host history.

@Observable
final class ProfileViewModel {
    var user: User = SampleData.currentUser
    var savedGatherings: [Gathering] = SampleData.savedGatherings
    var connections: [Connection] = SampleData.connections
    var isLoading = false

    // MARK: - History Data
    var browsingHistory: [BrowsingHistoryItem] = []
    var joinHistory: [EventJoinHistoryItem] = []
    var hostHistory: [EventHostHistoryItem] = []
    var isHistoryLoading = false

    // Profile tab selection
    enum ProfileSection: String, CaseIterable {
        case overview = "Overview"
        case activity = "Activity"
        case hosted = "Hosted"
    }
    var selectedSection: ProfileSection = .overview

    // Edit Cultural Tags (S24)
    var editingBackground: [String] = []
    var editingLanguages: [String] = []
    var editingInterests: [String] = []
    var hasTagChanges: Bool {
        editingBackground != user.culturalTags.background
        || editingLanguages != user.culturalTags.languages
        || editingInterests != user.culturalTags.interests
    }

    // Settings
    var showLogoutConfirmation = false
    var showDeleteConfirmation = false

    // MARK: - Computed Properties

    var upcomingJoined: [EventJoinHistoryItem] {
        joinHistory.filter { $0.status == .confirmed }
    }

    var pastAttended: [EventJoinHistoryItem] {
        joinHistory.filter { $0.status == .attended }
    }

    var unratedEvents: [EventJoinHistoryItem] {
        pastAttended.filter { $0.ratingGiven == nil }
    }

    var publishedHosted: [EventHostHistoryItem] {
        hostHistory.filter { $0.status == .completed || $0.status == .published }
    }

    var averageHostRating: Double? {
        let rated = hostHistory.compactMap(\.averageRating)
        guard !rated.isEmpty else { return nil }
        return rated.reduce(0, +) / Double(rated.count)
    }

    var totalAttendeesHosted: Int {
        hostHistory.filter { $0.status == .completed }.reduce(0) { $0 + $1.attendeeCount }
    }

    // MARK: - Actions

    func beginEditingTags() {
        editingBackground = user.culturalTags.background
        editingLanguages = user.culturalTags.languages
        editingInterests = user.culturalTags.interests
    }

    func saveTags() {
        user.culturalTags = CulturalTags(
            background: editingBackground,
            languages: editingLanguages,
            interests: editingInterests
        )
    }

    func clearAllTags() {
        editingBackground = []
        editingLanguages = []
        editingInterests = []
    }

    func removeSavedGathering(at offsets: IndexSet) {
        let ids = offsets.map { savedGatherings[$0].id }
        savedGatherings.remove(atOffsets: offsets)
        _ = ids // Suppress unused warning
    }

    func clearBrowsingHistory() {
        browsingHistory = []
    }

    func removeBrowsingItem(_ item: BrowsingHistoryItem) {
        browsingHistory.removeAll { $0.id == item.id }
    }

    // MARK: - Load

    func load() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(0.5))
        user = SampleData.currentUser
        savedGatherings = SampleData.savedGatherings
        connections = SampleData.connections
        browsingHistory = SampleData.browsingHistory
        joinHistory = SampleData.joinHistory
        hostHistory = SampleData.hostHistory
        isLoading = false
    }
}
