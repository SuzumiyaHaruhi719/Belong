import SwiftUI

struct GatheringPublishedScreen: View {
    let gatheringId: String
    let onViewGathering: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            GatheringPublishedHero()
            GatheringPublishedInfo()

            Spacer()

            GatheringPublishedActions(
                onViewGathering: onViewGathering,
                onShare: onShare
            )
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.xxl)
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Hero

private struct GatheringPublishedHero: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("🎉")
                .font(.system(size: 72))

            Text("Your gathering is live!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Info Bullets

private struct GatheringPublishedInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            GatheringPublishedBullet(
                icon: "envelope.fill",
                text: "We'll send a welcome message"
            )
            GatheringPublishedBullet(
                icon: "bell.fill",
                text: "You'll be notified when people join"
            )
            GatheringPublishedBullet(
                icon: "pencil.circle.fill",
                text: "You can edit or cancel anytime"
            )
        }
        .padding(Spacing.lg)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
    }
}

private struct GatheringPublishedBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(BelongColor.primary)
                .frame(width: 24)
            Text(text)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
        }
    }
}

// MARK: - Actions

private struct GatheringPublishedActions: View {
    let onViewGathering: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: Spacing.sm) {
            BelongButton(
                title: "View my gathering",
                style: .primary,
                isFullWidth: true,
                action: onViewGathering
            )
            BelongButton(
                title: "Share",
                style: .secondary,
                isFullWidth: true,
                leadingIcon: "square.and.arrow.up",
                action: onShare
            )
        }
    }
}

#Preview {
    NavigationStack {
        GatheringPublishedScreen(
            gatheringId: "test-id",
            onViewGathering: {},
            onShare: {}
        )
    }
}
