import SwiftUI

// MARK: - PublishedConfirmScreen (S22)
// Success screen after publishing a gathering.
// UX Decision: Celebration screen with clear next steps reduces
// post-action anxiety and guides the host toward engagement.

struct PublishedConfirmScreen: View {
    let viewModel: HostViewModel
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(BelongColor.success)
                .accessibilityLabel("Success")

            // Title
            Text("Your gathering is live!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
                .multilineTextAlignment(.center)

            // Bullet points
            VStack(alignment: .leading, spacing: Spacing.base) {
                BulletPoint(
                    icon: "message",
                    text: "You'll get a welcome message"
                )
                BulletPoint(
                    icon: "bell",
                    text: "We'll notify you when people join"
                )
                BulletPoint(
                    icon: "pencil",
                    text: "You can edit or cancel anytime"
                )
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            // Action buttons
            VStack(spacing: Spacing.sm) {
                BelongButton(
                    title: "Share",
                    style: .secondary,
                    systemImage: "square.and.arrow.up"
                ) {
                    // Share action placeholder
                }
                .accessibilityLabel("Share your gathering")

                BelongButton(
                    title: "View my gathering",
                    style: .primary
                ) {
                    appState.selectedTab = .events
                }
                .accessibilityLabel("View my gathering in events")
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Bullet Point

private struct BulletPoint: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(BelongColor.primary)
                .frame(width: 28)

            Text(text)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

#Preview {
    NavigationStack {
        PublishedConfirmScreen(viewModel: HostViewModel())
            .environment(AppState())
    }
}
