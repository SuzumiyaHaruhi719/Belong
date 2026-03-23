import SwiftUI
import Supabase

@Observable @MainActor
final class EditProfileViewModel {
    // MARK: - Dependencies
    private let userService: any UserServiceProtocol

    // MARK: - State
    var displayName = ""
    var bio = ""
    var selectedCity = ""
    var selectedSchool = ""
    var editingBackground: Set<String> = []
    var editingLanguages: Set<String> = []
    var editingInterests: Set<String> = []
    var isSaving = false
    var error: String?

    // Dropdowns
    var availableCities: [String] = []
    var availableSchools: [String] = []

    // Original values for change detection
    private var originalDisplayName = ""
    private var originalBio = ""
    private var originalCity = ""
    private var originalSchool = ""

    var hasChanges: Bool {
        displayName != originalDisplayName ||
        bio != originalBio ||
        selectedCity != originalCity ||
        selectedSchool != originalSchool
    }

    init(userService: any UserServiceProtocol) {
        self.userService = userService
    }

    // MARK: - Load

    /// Load existing tags from database so the edit screen pre-selects them
    func loadExistingTags() async {
        guard let userId = SupabaseManager.shared.currentUserId else { return }
        do {
            let rows: [DBUserTag] = try await SupabaseManager.shared.client.from("user_tags")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            for row in rows {
                switch TagCategory(rawValue: row.category) {
                case .culturalBackground:
                    editingBackground.insert(row.tagValue)
                case .language:
                    editingLanguages.insert(row.tagValue)
                case .interestVibe:
                    editingInterests.insert(row.tagValue)
                case .none:
                    break
                }
            }
        } catch {
            self.error = "Could not load your tags. Starting with empty selection."
        }
    }

    func loadCurrentValues(from user: User) {
        displayName = user.displayName
        bio = user.bio
        selectedCity = user.city
        selectedSchool = user.school

        originalDisplayName = user.displayName
        originalBio = user.bio
        originalCity = user.city
        originalSchool = user.school
    }

    func loadCities() async {
        do {
            availableCities = try await userService.fetchCities(query: "")
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadSchools() async {
        guard !selectedCity.isEmpty else {
            availableSchools = []
            return
        }
        do {
            availableSchools = try await userService.fetchSchools(city: selectedCity)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadTagPresets() async {
        do {
            async let bg = userService.fetchTagPresets(category: .culturalBackground)
            async let lang = userService.fetchTagPresets(category: .language)
            async let interests = userService.fetchTagPresets(category: .interestVibe)
            _ = try await (bg, lang, interests)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Save

    func save() async -> User? {
        isSaving = true
        error = nil
        do {
            let updatedUser = try await userService.updateProfile(
                displayName: displayName,
                bio: bio,
                city: selectedCity,
                school: selectedSchool
            )
            isSaving = false
            originalDisplayName = displayName
            originalBio = bio
            originalCity = selectedCity
            originalSchool = selectedSchool
            return updatedUser
        } catch {
            self.error = error.localizedDescription
            isSaving = false
            return nil
        }
    }

    func saveTags() async -> Bool {
        isSaving = true
        error = nil
        do {
            var tags: [UserTag] = []
            for bg in editingBackground {
                tags.append(UserTag(id: UUID().uuidString, userId: "", category: .culturalBackground, value: bg))
            }
            for lang in editingLanguages {
                tags.append(UserTag(id: UUID().uuidString, userId: "", category: .language, value: lang))
            }
            for interest in editingInterests {
                tags.append(UserTag(id: UUID().uuidString, userId: "", category: .interestVibe, value: interest))
            }
            try await userService.updateTags(tags)
            isSaving = false
            return true
        } catch {
            self.error = error.localizedDescription
            isSaving = false
            return false
        }
    }
}
