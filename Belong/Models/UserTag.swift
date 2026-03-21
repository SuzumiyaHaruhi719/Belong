import Foundation

struct UserTag: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    var category: TagCategory
    var value: String
}

enum TagCategory: String, Codable, CaseIterable {
    case culturalBackground = "cultural_background"
    case language = "language"
    case interestVibe = "interest_vibe"
}
