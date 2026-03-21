import SwiftUI

struct BadgeView: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text(displayText)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .frame(minWidth: 18, minHeight: 18)
                .padding(.horizontal, count > 9 ? 4 : 0)
                .background(BelongColor.error)
                .clipShape(Capsule())
        }
    }

    private var displayText: String {
        count > 99 ? "99+" : "\(count)"
    }
}

#Preview {
    HStack(spacing: Spacing.xl) {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bell")
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
            BadgeView(count: 3)
                .offset(x: 8, y: -8)
        }
        ZStack(alignment: .topTrailing) {
            Image(systemName: "envelope")
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
            BadgeView(count: 42)
                .offset(x: 10, y: -8)
        }
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bubble.left")
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
            BadgeView(count: 150)
                .offset(x: 14, y: -8)
        }
    }
    .padding()
    .background(BelongColor.background)
}
