import SwiftUI

enum AvatarSize: CGFloat {
    case small = 32
    case medium = 40
    case large = 52
    case xlarge = 80

    var fontSize: CGFloat {
        switch self {
        case .small: 14
        case .medium: 18
        case .large: 24
        case .xlarge: 36
        }
    }
}

struct AvatarView: View {
    var imageURL: URL? = nil
    var emoji: String = ""
    var size: AvatarSize = .medium

    var body: some View {
        if let url = imageURL {
            AvatarAsyncImage(url: url, size: size)
        } else {
            AvatarEmojiFallback(emoji: emoji, size: size)
        }
    }
}

struct AvatarAsyncImage: View {
    let url: URL
    let size: AvatarSize

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                AvatarEmojiFallback(emoji: "?", size: size)
            default:
                Circle()
                    .fill(BelongColor.skeleton)
            }
        }
        .frame(width: size.rawValue, height: size.rawValue)
        .clipShape(Circle())
    }
}

struct AvatarEmojiFallback: View {
    let emoji: String
    let size: AvatarSize

    var body: some View {
        ZStack {
            Circle()
                .fill(BelongColor.surfaceSecondary)
            Text(emoji.isEmpty ? "?" : emoji)
                .font(.system(size: size.fontSize))
        }
        .frame(width: size.rawValue, height: size.rawValue)
    }
}

#Preview {
    HStack(spacing: Spacing.base) {
        AvatarView(emoji: "🧑‍🍳", size: .small)
        AvatarView(emoji: "🎎", size: .medium)
        AvatarView(emoji: "🌸", size: .large)
        AvatarView(emoji: "🎭", size: .xlarge)
    }
    .padding()
    .background(BelongColor.background)
}
