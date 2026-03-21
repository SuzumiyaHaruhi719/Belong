import SwiftUI

// MARK: - HostViewModel
// Drives S19–S22: Template Picker → Customize → Preview → Published.
//
// UX Decision: Draft auto-saves locally so the user never loses work
// if they navigate away. The form validates per-section with inline errors.

@Observable
final class HostViewModel {
    // Template selection
    var selectedTemplate: HostingTemplate?

    // Form fields (S20)
    var title = ""
    var description = ""
    var date = Date().addingTimeInterval(86400 * 3) // Default: 3 days from now
    var location = ""
    var maxAttendees = 10
    var culturalTags: [String] = []

    // Validation
    var fieldErrors: [String: String] = [:]

    // State
    var isPublishing = false
    var isPublished = false
    var publishedGathering: Gathering?

    // MARK: Computed

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !description.trimmingCharacters(in: .whitespaces).isEmpty
        && !location.trimmingCharacters(in: .whitespaces).isEmpty
        && date > Date()
        && maxAttendees >= 2 && maxAttendees <= 50
    }

    // MARK: Actions

    func selectTemplate(_ template: HostingTemplate) {
        selectedTemplate = template
        culturalTags = template.defaultTags
        // Pre-fill title suggestion
        if title.isEmpty { title = "" } // Let user fill it
    }

    func validateForm() -> Bool {
        fieldErrors.removeAll()
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedDesc = description.trimmingCharacters(in: .whitespaces)
        let trimmedLoc = location.trimmingCharacters(in: .whitespaces)

        if trimmedTitle.isEmpty { fieldErrors["title"] = "Title is required" }
        else if trimmedTitle.count > 60 { fieldErrors["title"] = "Max 60 characters" }
        if trimmedDesc.isEmpty { fieldErrors["description"] = "Description is required" }
        if trimmedLoc.isEmpty { fieldErrors["location"] = "Location is required" }
        if date <= Date() { fieldErrors["date"] = "Must be in the future" }
        if maxAttendees < 2 { fieldErrors["maxAttendees"] = "At least 2 people" }
        if maxAttendees > 50 { fieldErrors["maxAttendees"] = "Max 50 people" }

        return fieldErrors.isEmpty
    }

    func publish() async {
        guard validateForm() else { return }
        isPublishing = true
        defer { isPublishing = false }

        try? await Task.sleep(for: .seconds(1.5))

        publishedGathering = Gathering(
            id: UUID().uuidString,
            title: title,
            description: description,
            imageURL: nil,
            hostName: SampleData.currentUser.displayName,
            hostAvatarEmoji: SampleData.currentUser.avatarEmoji,
            hostRating: 0,
            date: date,
            location: location,
            attendeeCount: 1,
            maxAttendees: maxAttendees,
            attendeeAvatars: [SampleData.currentUser.avatarEmoji],
            culturalTags: culturalTags,
            isBookmarked: false,
            status: .upcoming
        )
        isPublished = true
    }

    func reset() {
        selectedTemplate = nil
        title = ""
        description = ""
        date = Date().addingTimeInterval(86400 * 3)
        location = ""
        maxAttendees = 10
        culturalTags = []
        fieldErrors.removeAll()
        isPublished = false
        publishedGathering = nil
    }
}
