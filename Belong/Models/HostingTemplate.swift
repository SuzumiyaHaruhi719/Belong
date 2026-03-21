import Foundation

// MARK: - Hosting Template

struct HostingTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String   // SF Symbol name
    let description: String
    let defaultTags: [String]
}
