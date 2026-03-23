import Foundation

protocol GatheringServiceProtocol: Sendable {
    func fetchRecommended(city: String, limit: Int) async throws -> [Gathering]
    func fetchFeed(city: String, page: Int, filter: String?) async throws -> [Gathering]
    func fetchDetail(id: String) async throws -> Gathering
    func join(gatheringId: String) async throws -> Gathering
    func maybe(gatheringId: String) async throws
    func save(gatheringId: String) async throws
    func unsave(gatheringId: String) async throws
    func leave(gatheringId: String) async throws
    func create(_ gathering: Gathering) async throws -> Gathering
    func update(_ gathering: Gathering) async throws -> Gathering
    func cancel(gatheringId: String) async throws
    func submitFeedback(gatheringId: String, emoji: FeedbackLevel) async throws
    func fetchAttendees(gatheringId: String) async throws -> [GatheringMember]
    func fetchTemplates() async throws -> [HostingTemplate]
    func search(query: String, city: String) async throws -> [Gathering]
    func fetchDrafts() async throws -> [Gathering]
    func saveDraft(_ gathering: Gathering) async throws -> Gathering
    func publishDraft(gatheringId: String) async throws -> Gathering
    func deleteDraft(gatheringId: String) async throws
}
