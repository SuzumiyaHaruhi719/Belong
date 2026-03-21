import SwiftUI

struct CreateSelectorSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.xl) {
            CreateSelectorDragHandle()

            Text("What would you like to create?")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            CreateSelectorOptionCard(
                icon: "calendar.badge.plus",
                title: "Host a Gathering",
                description: "Share your culture through events"
            ) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    appState.showCreateGatheringFlow = true
                }
            }

            CreateSelectorOptionCard(
                icon: "camera.fill",
                title: "Share a Post",
                description: "Tell your story with photos"
            ) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    appState.showCreatePostScreen = true
                }
            }

            Spacer()
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.md)
        .background(BelongColor.background)
    }
}

// MARK: - Drag Handle

struct CreateSelectorDragHandle: View {
    var body: some View {
        Capsule()
            .fill(BelongColor.border)
            .frame(width: 36, height: 5)
            .padding(.top, Spacing.sm)
    }
}

// MARK: - Option Card

struct CreateSelectorOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.base) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(BelongColor.primary)
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(BelongFont.h3())
                        .foregroundStyle(BelongColor.textPrimary)
                    Text(description)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .padding(Spacing.base)
            .frame(height: 80)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
            .shadow(
                color: BelongShadow.level1.color,
                radius: BelongShadow.level1.radius,
                x: BelongShadow.level1.x,
                y: BelongShadow.level1.y
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    CreateSelectorSheet()
        .environment(AppState())
}
