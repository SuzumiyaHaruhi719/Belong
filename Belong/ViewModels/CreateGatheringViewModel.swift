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

    // Cover image upload
    var coverImage: UIImage?
    var coverImageURL: URL?
    var coverUploadState: ImageUploadOverlay.UploadState = .idle

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
            imageURL: coverImageURL,
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

    // MARK: - Cover Image Upload

    func selectCoverImage(_ image: UIImage) {
        coverImage = image
        Task { await uploadCoverImage(image) }
    }

    private func uploadCoverImage(_ image: UIImage) async {
        coverUploadState = .uploading
        do {
            let userId = "current-user" // In production: auth.uid()
            let filename = "\(UUID().uuidString).jpg"
            let path = "\(userId)/\(filename)"

            let result = try await container.storageService.uploadImage(
                image,
                bucket: .gatheringImages,
                path: path
            )
            coverImageURL = result.publicURL
            coverUploadState = .success

            // Reset to idle after showing success briefly
            try? await Task.sleep(for: .seconds(1.5))
            coverUploadState = .idle
        } catch {
            coverUploadState = .error("Upload failed")
        }
    }

    func removeCoverImage() {
        coverImage = nil
        coverImageURL = nil
        coverUploadState = .idle
    }

    // MARK: - Template Selection

    func selectTemplate(_ template: HostingTemplate) {
        selectedTemplate = template
        if title.isEmpty { title = "" } // keep blank so user fills in
        maxAttendees = template.defaultMaxAttendees
        selectedVisibility = template.defaultVisibility
        selectedVibe = template.defaultVibe
        selectedTags = Set(template.defaultTags)
    }

    // MARK: - Validation

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

    // MARK: - Publish

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
    }
}
