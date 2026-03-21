import SwiftUI

enum JoinState: Equatable {
    case idle
    case joining
    case joined
    case error(String)
}

@Observable @MainActor
final class GatheringDetailViewModel {
    // MARK: - State

    var gathering: Gathering?
    var attendees: [GatheringMember] = []
    var isLoading = false
    var error: String?
    var joinState: JoinState = .idle
    var showJoinConfirmation = false

    // MARK: - Dependencies

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Actions

    func loadDetail(id: String) async {
        isLoading = true
        error = nil
        do {
            async let detail = container.gatheringService.fetchDetail(id: id)
            async let members = container.gatheringService.fetchAttendees(gatheringId: id)
            gathering = try await detail
            attendees = try await members
            if gathering?.isJoined == true {
                joinState = .joined
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func join() async {
        guard let g = gathering, !g.isFull else { return }
        joinState = .joining
        do {
            let updated = try await container.gatheringService.join(gatheringId: g.id)
            gathering = updated
            joinState = .joined
            showJoinConfirmation = true
        } catch {
            joinState = .error(error.localizedDescription)
        }
    }

    func maybe() async {
        guard let g = gathering else { return }
        do {
            try await container.gatheringService.maybe(gatheringId: g.id)
            gathering?.isMaybe = true
        } catch {
            self.error = error.localizedDescription
        }
    }

    func save() async {
        guard let g = gathering else { return }
        gathering?.isBookmarked.toggle()
        do {
            if g.isBookmarked {
                try await container.gatheringService.unsave(gatheringId: g.id)
            } else {
                try await container.gatheringService.save(gatheringId: g.id)
            }
        } catch {
            gathering?.isBookmarked = g.isBookmarked
        }
    }

    func leave() async {
        guard let g = gathering else { return }
        do {
            try await container.gatheringService.leave(gatheringId: g.id)
            gathering?.isJoined = false
            gathering?.attendeeCount = max(0, (gathering?.attendeeCount ?? 1) - 1)
            joinState = .idle
        } catch {
            self.error = error.localizedDescription
        }
    }
}
