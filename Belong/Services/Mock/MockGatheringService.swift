import Foundation

@MainActor
final class MockGatheringService: GatheringServiceProtocol {
    private var gatherings: [Gathering] = []
    private var savedIds: Set<String> = []

    nonisolated init() {}

    private func ensureLoaded() {
        if gatherings.isEmpty {
            gatherings = SampleData.gatherings
        }
    }

    nonisolated func fetchRecommended(city: String, limit: Int) async throws -> [Gathering] {
        try await Task.sleep(for: .milliseconds(700))
        return await MainActor.run {
            ensureLoaded()
            return Array(gatherings.prefix(limit))
        }
    }

    nonisolated func fetchFeed(city: String, page: Int, filter: String?) async throws -> [Gathering] {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            ensureLoaded()
            if let filter {
                return gatherings.filter { $0.templateType.rawValue == filter }
            }
            return gatherings
        }
    }

    nonisolated func fetchDetail(id: String) async throws -> Gathering {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run {
            ensureLoaded()
            guard let gathering = gatherings.first(where: { $0.id == id }) else {
                return gatherings[0]
            }
            return gathering
        }
    }

    nonisolated func join(gatheringId: String) async throws -> Gathering {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            ensureLoaded()
            if let index = gatherings.firstIndex(where: { $0.id == gatheringId }) {
                gatherings[index].isJoined = true
                gatherings[index].attendeeCount += 1
                return gatherings[index]
            }
            return gatherings[0]
        }
    }

    nonisolated func maybe(gatheringId: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    nonisolated func save(gatheringId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            savedIds.insert(gatheringId)
            if let index = gatherings.firstIndex(where: { $0.id == gatheringId }) {
                gatherings[index].isBookmarked = true
            }
        }
    }

    nonisolated func unsave(gatheringId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            savedIds.remove(gatheringId)
            if let index = gatherings.firstIndex(where: { $0.id == gatheringId }) {
                gatherings[index].isBookmarked = false
            }
        }
    }

    nonisolated func leave(gatheringId: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        await MainActor.run {
            ensureLoaded()
            if let index = gatherings.firstIndex(where: { $0.id == gatheringId }) {
                gatherings[index].isJoined = false
                gatherings[index].attendeeCount = max(0, gatherings[index].attendeeCount - 1)
            }
        }
    }

    nonisolated func create(_ gathering: Gathering) async throws -> Gathering {
        try await Task.sleep(for: .milliseconds(800))
        return await MainActor.run {
            let newGathering = gathering
            gatherings.insert(newGathering, at: 0)
            return newGathering
        }
    }

    nonisolated func update(_ gathering: Gathering) async throws -> Gathering {
        try await Task.sleep(for: .milliseconds(700))
        return await MainActor.run {
            if let index = gatherings.firstIndex(where: { $0.id == gathering.id }) {
                gatherings[index] = gathering
            }
            return gathering
        }
    }

    nonisolated func cancel(gatheringId: String) async throws {
        try await Task.sleep(for: .milliseconds(600))
        await MainActor.run {
            gatherings.removeAll { $0.id == gatheringId }
        }
    }

    nonisolated func submitFeedback(gatheringId: String, emoji: FeedbackLevel) async throws {
        try await Task.sleep(for: .milliseconds(500))
    }

    nonisolated func fetchAttendees(gatheringId: String) async throws -> [GatheringMember] {
        try await Task.sleep(for: .milliseconds(600))
        return SampleData.gatheringMembers
    }

    nonisolated func fetchTemplates() async throws -> [HostingTemplate] {
        try await Task.sleep(for: .milliseconds(500))
        return SampleData.hostingTemplates
    }

    nonisolated func search(query: String, city: String) async throws -> [Gathering] {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            ensureLoaded()
            let lowered = query.lowercased()
            return gatherings.filter {
                $0.title.lowercased().contains(lowered) ||
                $0.description.lowercased().contains(lowered)
            }
        }
    }

    // MARK: - Draft Support

    nonisolated func fetchDrafts() async throws -> [Gathering] {
        try await Task.sleep(for: .milliseconds(400))
        return await MainActor.run {
            gatherings.filter { $0.isDraft }
        }
    }

    nonisolated func saveDraft(_ gathering: Gathering) async throws -> Gathering {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run {
            var draft = gathering
            draft.isDraft = true
            if let index = gatherings.firstIndex(where: { $0.id == gathering.id }) {
                gatherings[index] = draft
            } else {
                gatherings.insert(draft, at: 0)
            }
            return draft
        }
    }

    nonisolated func publishDraft(gatheringId: String) async throws -> Gathering {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            if let index = gatherings.firstIndex(where: { $0.id == gatheringId }) {
                gatherings[index].isDraft = false
                return gatherings[index]
            }
            return gatherings[0]
        }
    }

    nonisolated func deleteDraft(gatheringId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            gatherings.removeAll { $0.id == gatheringId && $0.isDraft }
        }
    }
}
