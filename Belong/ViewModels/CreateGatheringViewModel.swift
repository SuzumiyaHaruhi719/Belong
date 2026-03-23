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

    // Draft support
    var isSavingDraft: Bool = false
    var draftSaved: Bool = false
    var draftError: String?
    var existingDraftId: String?

    // MARK: - Computed

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !locationName.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedDate > Date()
    }

    /// Preview-ready Gathering built from current form state.
    var previewGathering: Gathering {
        Gathering(
            id: existingDraftId ?? "",
            hostId: SupabaseManager.shared.currentUserId ?? "",
            title: title,
            description: descriptionText,
            templateType: templateTypeFromTemplate,
            emoji: selectedTemplate?.emoji ?? "🎉",
            imageURL: coverImageURL,
            city: userCity,
            school: userSchool,
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

    private(set) var container: DependencyContainer
    var userCity: String = ""
    var userSchool: String?

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
            let userId = SupabaseManager.shared.currentUserId ?? "anonymous"
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

    /// True when a cover image upload is in progress — blocks publish/preview.
    var isCoverUploading: Bool {
        coverUploadState == .uploading
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
        return titleError == nil && locationError == nil && dateError == nil && !isCoverUploading
    }

    // MARK: - Publish

    func publish() async {
        guard validateForm(), !isPublishing else { return }

        isPublishing = true
        publishError = nil

        do {
            if let draftId = existingDraftId {
                // Update draft with latest form data, then flip to published
                var gathering = previewGathering
                gathering.isDraft = true // keep as draft during update
                _ = try await container.gatheringService.update(gathering)
                // Now flip isDraft=false atomically
                let published = try await container.gatheringService.publishDraft(gatheringId: draftId)
                publishedGatheringId = published.id
            } else {
                var gathering = previewGathering
                gathering.isDraft = false
                let created = try await container.gatheringService.create(gathering)
                publishedGatheringId = created.id
            }
        } catch {
            publishError = error.localizedDescription
        }

        isPublishing = false
    }

    func saveDraft() async {
        guard !isSavingDraft else { return }
        isSavingDraft = true
        draftError = nil
        draftSaved = false

        do {
            var draft = previewGathering
            draft.isDraft = true

            let saved: Gathering
            if existingDraftId != nil {
                // Update existing draft — don't create a duplicate
                saved = try await container.gatheringService.update(draft)
            } else {
                // Create new draft
                saved = try await container.gatheringService.create(draft)
            }
            existingDraftId = saved.id
            isDraft = true
            draftSaved = true
        } catch {
            draftError = error.localizedDescription
        }
        isSavingDraft = false
    }

    /// Load an existing draft for editing
    func loadDraft(_ gathering: Gathering) {
        existingDraftId = gathering.id
        title = gathering.title
        descriptionText = gathering.description
        locationName = gathering.locationName
        selectedDate = gathering.startsAt
        maxAttendees = gathering.maxAttendees
        selectedVisibility = gathering.visibility
        selectedVibe = gathering.vibe
        selectedTags = Set(gathering.tags)
        coverImageURL = gathering.imageURL
        isDraft = true
    }
}
