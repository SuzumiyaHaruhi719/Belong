import SwiftUI

// MARK: - ProfileViewModel
// Drives S23–S26: Profile, Edit Cultural Tags, Saved Gatherings, Settings.

@Observable
final class ProfileViewModel {
    var user: User = SampleData.currentUser
    var savedGatherings: [Gathering] = SampleData.savedGatherings
    var connections: [Connection] = SampleData.connections
    var isLoading = false

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
        // In production, also update the server
        _ = ids // Suppress unused warning
    }

    func load() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(0.5))
        user = SampleData.currentUser
        savedGatherings = SampleData.savedGatherings
        connections = SampleData.connections
        isLoading = false
    }
}
