import Foundation

struct FeedbackEmoji: Identifiable, Hashable {
    let id: String
    let emoji: String
    let label: String
    let score: Int

    static let options: [FeedbackEmoji] = [
        .init(id: "meh", emoji: "😕", label: "Meh", score: 1),
        .init(id: "okay", emoji: "🙂", label: "Okay", score: 2),
        .init(id: "good", emoji: "😊", label: "Good", score: 3),
        .init(id: "great", emoji: "🎉", label: "Great!", score: 4),
        .init(id: "amazing", emoji: "🤝", label: "Amazing", score: 5),
    ]
}
