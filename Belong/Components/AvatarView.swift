import SwiftUI

// MARK: - AvatarView
// Shows either a photo (AsyncImage) or an emoji fallback.
// Spec: Profile avatar is 80×80pt. Attendee avatars vary by context.

struct AvatarView: View {
    let emoji: String
    var imageURL: URL? = nil
    var size: CGFloat = 80

    var body: some View {
        Group {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        emojiFallback
                    }
                }
            } else {
                emojiFallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel("Avatar")
    }

    private var emojiFallback: some View {
        ZStack {
            Circle()
                .fill(BelongColor.surfaceSecondary)
            Text(emoji)
                .font(.system(size: size * 0.45))
        }
    }
}

// MARK: - AvatarGrid
// Spec S07: 8–10 default avatar options in a grid for selection.

struct AvatarGrid: View {
    let avatars: [String]
    @Binding var selected: String

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.base), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.base) {
            ForEach(avatars, id: \.self) { emoji in
                Button {
                    selected = emoji
                } label: {
                    Text(emoji)
                        .font(.system(size: 32))
                        .frame(width: 56, height: 56)
                        .background(selected == emoji ? BelongColor.surfaceSecondary : BelongColor.surface)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(selected == emoji ? BelongColor.primary : BelongColor.border, lineWidth: selected == emoji ? 2 : 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Avatar \(emoji)")
                .accessibilityAddTraits(selected == emoji ? [.isButton, .isSelected] : .isButton)
            }
        }
    }
}

#Preview("Avatars") {
    struct Preview: View {
        @State var selected = "🌿"
        var body: some View {
            VStack(spacing: 24) {
                AvatarView(emoji: "🌿")
                AvatarView(emoji: "🌸", size: 40)
                AvatarGrid(avatars: SampleData.defaultAvatars, selected: $selected)
            }
            .padding()
            .background(BelongColor.background)
        }
    }
    return Preview()
}
