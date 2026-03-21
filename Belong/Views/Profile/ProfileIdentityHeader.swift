import SwiftUI

// MARK: - Profile Identity Header
// Avatar, display name, school, and city.
// UX: Camera badge on avatar hints at editability without a separate button.

struct ProfileIdentityHeader: View {
    let user: User

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Avatar with camera badge
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    emoji: user.avatarEmoji,
                    imageURL: user.avatarURL,
                    size: 80
                )

                Image(systemName: "camera.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(BelongColor.textOnPrimary)
                    .frame(width: 28, height: 28)
                    .background(BelongColor.primary)
                    .clipShape(Circle())
                    .overlay {
                        Circle().strokeBorder(BelongColor.background, lineWidth: 2)
                    }
            }
            .accessibilityLabel("Profile avatar, tap to edit")

            Text(user.displayName)
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            HStack(spacing: Spacing.xs) {
                Text(user.school)
                Text("•")
                Text(user.city)
            }
            .font(BelongFont.secondary())
            .foregroundStyle(BelongColor.textSecondary)
        }
        .padding(.horizontal, Layout.screenPadding)
    }
}
