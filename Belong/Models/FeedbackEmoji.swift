import Foundation

// MARK: - Post-event feedback emoji options
// Spec: 5 emojis at 64×64pt — 😕 🙂 😊 🎉 🤝
// Each has a semantic label for accessibility.

struct FeedbackEmoji: Identifiable, Hashable {
    let id: String
    let emoji: String
    let label: String
    let value: Int   // 1–5 rating

    static let options: [FeedbackEmoji] = [
        FeedbackEmoji(id: "meh", emoji: "😕", label: "Not great", value: 1),
        FeedbackEmoji(id: "okay", emoji: "🙂", label: "It was okay", value: 2),
        FeedbackEmoji(id: "good", emoji: "😊", label: "Enjoyed it", value: 3),
        FeedbackEmoji(id: "great", emoji: "🎉", label: "Loved it!", value: 4),
        FeedbackEmoji(id: "connected", emoji: "🤝", label: "Made connections", value: 5),
    ]
}
