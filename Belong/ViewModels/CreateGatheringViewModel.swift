import SwiftUI

@Observable @MainActor
final class CreateGatheringViewModel {
    // MARK: - State

    var selectedTemplate: HostingTemplate?
    var title: String = ""
    var descriptionText: String = ""
    var locationName: String = ""
    var selectedDate: Date = Date().addingTimeInterval(86400) // tomorrow
    var maxAttendees: Int = 8
    var selectedVisibility: GatheringVisibility = .open
    var selectedVibe: GatheringVibe = .welcoming
    var selectedTags: Set<String> = []

    var isDraft: Bool = false
    var isPublishing: Bool = false
    var publishError: String?

    // Validation
    var titleError: String?
    var locationError: String?
    var dateError: String?

    // Published gathering ID after success
    var publishedGatheringId: String?

    // MARK: - Computed

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !locationName.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedDate > Date()
    }

    /// Preview-ready Gathering built from current form state.
    var previewGathering: Gathering {
        Gathering(
            id: "preview",
            hostId: "current-user",
            title: title,
            description: descriptionText,
            templateType: templateTypeFromTemplate,
            emoji: selectedTemplate?.emoji ?? "🎉",
            imageURL: nil,
            city: "",
            school: nil,
            locationName: locationName,
            latitude: nil,
            longitude: nil,
            startsAt: selectedDate,
            endsAt: nil,
            maxAttendees: maxAttendees,
            visibility: selectedVisibility,
            vibe: selectedVibe,
            status: .upcoming,
            isDraft: isDraft,
            tags: Array(selectedTags),
            attendeeCount: 1,
            attendeeAvatars: ["🙂"],
            hostName: "You",
            hostAvatarEmoji: "🙂",
            hostRating: 5.0,
            isBookmarked: false,
            isJoined: true,
            isMaybe: false,
            createdAt: Date()
        )
    }

    private var templateTypeFromTemplate: GatheringTemplate {
        guard let id = selectedTemplate?.id else { return .hangout }
        if id.contains("food") { return .food }
        if id.contains("study") { return .study }
        if id.contains("cultural") { return .cultural }
        if id.contains("faith") { return .faith }
        if id.contains("active") { return .active }
        return .hangout
    }

    // MARK: - Dependencies

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Actions

    func selectTemplate(_ template: HostingTemplate) {
        selectedTemplate = template
        if title.isEmpty { title = "" } // keep blank so user fills in
        maxAttendees = template.defaultMaxAttendees
        selectedVisibility = template.defaultVisibility
        selectedVibe = template.defaultVibe
        selectedTags = Set(template.defaultTags)
    }

    @discardableResult
    func validateForm() -> Bool {
        titleError = nil
        locationError = nil
        dateError = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedLocation = locationName.trimmingCharacters(in: .whitespaces)

        if trimmedTitle.isEmpty {
            titleError = "Title is required"
        }
        if trimmedLocation.isEmpty {
            locationError = "Location is required"
        }
        if selectedDate <= Date() {
            dateError = "Date must be in the future"
        }

        return titleError == nil && locationError == nil && dateError == nil
    }

    func publish() async {
        guard validateForm() else { return }

        isPublishing = true
        publishError = nil

        do {
            let gathering = previewGathering
            let created = try await container.gatheringService.create(gathering)
            publishedGatheringId = created.id
        } catch {
            publishError = error.localizedDescription
        }

        isPublishing = false
    }

    func saveDraft() {
        isDraft = true
        // In production: persist to local storage or API
    }
}
