import Foundation

struct PostImage: Identifiable, Codable, Hashable {
    let id: String
    let postId: String
    var imageURL: URL
    var displayOrder: Int
    var width: Int?
    var height: Int?

    var aspectRatio: Double {
        guard let w = width, let h = height, h > 0 else { return 1.0 }
        return Double(w) / Double(h)
    }
}
