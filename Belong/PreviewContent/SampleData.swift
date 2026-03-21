import Foundation

enum SampleData {
    // MARK: - User Convenience
    static var currentUser: User { users[0] }
    static var topPick: Gathering { upcomingGatherings[0] }
    static var upcomingGatherings: [Gathering] { gatherings.filter { $0.status == .upcoming } }
    static var pastGatherings: [Gathering] { gatherings.filter { $0.status == .completed } }
    static var savedGatherings: [Gathering] { gatherings.filter { $0.isBookmarked } }
}
