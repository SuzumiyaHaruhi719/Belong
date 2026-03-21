import SwiftUI

@Observable @MainActor
final class CreatePostViewModel {
    // MARK: - State

    var content: String = ""
    var selectedImageURLs: [URL] = []
    var visibility: PostVisibility = .publicPost
    var linkedGatheringId: String?
    var isPublishing: Bool = false
    var publishError: String?
    var isPublished: Bool = false

    // Tag support
    var tagSuggestions: [String] = []
    var isLoadingTags: Bool = false

    // MARK: - Computed

    var extractedTags: [String] {
        parseHashtags()
    }

    var canPublish: Bool {
        !selectedImageURLs.isEmpty
    }

    var imageCount: Int { selectedImageURLs.count }
    var canAddMoreImages: Bool { selectedImageURLs.count < 9 }

    // MARK: - Dependencies

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Image Management

    func addImage(url: URL) {
        guard canAddMoreImages else { return }
        selectedImageURLs.append(url)
    }

    func removeImage(at index: Int) {
        guard selectedImageURLs.indices.contains(index) else { return }
        selectedImageURLs.remove(at: index)
    }

    func reorderImages(from source: IndexSet, to destination: Int) {
        selectedImageURLs.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Tag Support

    func parseHashtags() -> [String] {
        let pattern = #"#(\w+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex.matches(in: content, range: range)
        return matches.compactMap { match -> String? in
            guard let tagRange = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[tagRange])
        }
    }

    func fetchTagSuggestions(query: String) async {
        guard !query.isEmpty else {
            tagSuggestions = []
            return
        }
        isLoadingTags = true
        do {
            tagSuggestions = try await container.postService.fetchTrendingTags(query: query)
        } catch {
            tagSuggestions = []
        }
        isLoadingTags = false
    }

    // MARK: - Publish

    func publish() async {
        guard canPublish else { return }

        isPublishing = true
        publishError = nil

        do {
            _ = try await container.postService.create(
                content: content,
                imageURLs: selectedImageURLs,
                tags: extractedTags,
                visibility: visibility,
                linkedGatheringId: linkedGatheringId
            )
            isPublished = true
        } catch {
            publishError = error.localizedDescription
        }

        isPublishing = false
    }
}
