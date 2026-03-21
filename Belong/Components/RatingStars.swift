import SwiftUI

struct RatingStars: View {
    let rating: Double
    var starSize: CGFloat = 16

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                RatingStar(
                    fillAmount: fillAmount(for: index),
                    size: starSize
                )
            }
        }
        .accessibilityLabel("Rating: \(String(format: "%.1f", rating)) out of 5 stars")
    }

    private func fillAmount(for index: Int) -> Double {
        let starValue = rating - Double(index)
        if starValue >= 1.0 { return 1.0 }
        if starValue >= 0.5 { return 0.5 }
        return 0.0
    }
}

struct RatingStar: View {
    let fillAmount: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            Image(systemName: "star")
                .font(.system(size: size))
                .foregroundStyle(BelongColor.gold.opacity(0.3))

            if fillAmount >= 1.0 {
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundStyle(BelongColor.gold)
            } else if fillAmount >= 0.5 {
                Image(systemName: "star.leadinghalf.filled")
                    .font(.system(size: size))
                    .foregroundStyle(BelongColor.gold)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.md) {
        HStack {
            RatingStars(rating: 5.0)
            Text("5.0")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
        HStack {
            RatingStars(rating: 4.5)
            Text("4.5")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
        HStack {
            RatingStars(rating: 3.0)
            Text("3.0")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
        HStack {
            RatingStars(rating: 1.5, starSize: 24)
            Text("1.5")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
    .padding()
    .background(BelongColor.background)
}
