import SwiftUI

// MARK: - Loading / Empty / Error States
// Every screen needs these three states handled explicitly.
// UX Decision: Use skeleton rectangles for loading (not spinner-only) —
// gives spatial context of what's coming. Error states always have a retry action.

// MARK: Loading Skeleton

struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var radius: CGFloat = Layout.radiusSm

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(BelongColor.skeleton)
            .frame(width: width, height: height)
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .fill(BelongColor.skeletonHighlight)
                    .opacity(isAnimating ? 1 : 0)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            .accessibilityLabel("Loading")
    }
}

struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SkeletonView(height: 200, radius: Layout.radiusXl)
            SkeletonView(width: 200, height: 20)
            SkeletonView(width: 140, height: 16)
            SkeletonView(width: 100, height: 14)
        }
        .padding(Spacing.base)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusXl))
    }
}

// MARK: Empty State

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(BelongColor.textTertiary)

            Text(title)
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)

            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let actionTitle, let action {
                BelongButton(title: actionTitle, style: .secondary, isFullWidth: false, action: action)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Layout.screenPadding)
        .accessibilityElement(children: .combine)
    }
}

// MARK: Error State

struct ErrorStateView: View {
    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(BelongColor.error)

            Text("Something went wrong")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)

            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let retryAction {
                BelongButton(title: "Try again", style: .secondary, systemImage: "arrow.clockwise", isFullWidth: false, action: retryAction)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Layout.screenPadding)
        .accessibilityElement(children: .combine)
    }
}

// MARK: Inline Error Banner

struct InlineErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(BelongColor.error)
            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.error)
            Spacer()
        }
        .padding(Spacing.md)
        .background(BelongColor.errorLight)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
    }
}

// MARK: Success Banner

struct SuccessBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BelongColor.success)
            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textPrimary)
            Spacer()
        }
        .padding(Spacing.md)
        .background(BelongColor.successLight)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
    }
}

#Preview("State Views") {
    ScrollView {
        VStack(spacing: 32) {
            SkeletonCard()
            EmptyStateView(systemImage: "calendar.badge.plus", title: "No events yet",
                          message: "Join a gathering to see it here", actionTitle: "Browse gatherings") {}
            ErrorStateView(message: "Could not load gatherings. Check your connection.") {}
            InlineErrorBanner(message: "That email is already registered")
            SuccessBanner(message: "Your gathering has been published!")
        }
        .padding()
    }
    .background(BelongColor.background)
}
