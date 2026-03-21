import SwiftUI

struct ImageCarousel: View {
    let imageURLs: [URL]
    @State private var currentPage: Int = 0

    var body: some View {
        if imageURLs.isEmpty { EmptyView() } else {
            ZStack(alignment: .bottom) {
                TabView(selection: $currentPage) {
                    ForEach(Array(imageURLs.prefix(9).enumerated()), id: \.offset) { index, url in
                        ImageCarouselPage(url: url)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                if imageURLs.count > 1 {
                    ImageCarouselDots(count: min(imageURLs.count, 9), current: currentPage)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: Layout.radiusLg,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: Layout.radiusLg
                )
            )
        }
    }
}

struct ImageCarouselPage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                ZStack {
                    BelongColor.skeleton
                    Image(systemName: "photo")
                        .foregroundStyle(BelongColor.textTertiary)
                }
            default:
                BelongColor.skeleton
            }
        }
    }
}

struct ImageCarouselDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? BelongColor.textOnPrimary : BelongColor.textOnPrimary.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    ImageCarousel(imageURLs: [
        URL(string: "https://picsum.photos/400/300?1")!,
        URL(string: "https://picsum.photos/400/300?2")!,
        URL(string: "https://picsum.photos/400/300?3")!
    ])
    .frame(height: 240)
    .padding()
    .background(BelongColor.background)
}
