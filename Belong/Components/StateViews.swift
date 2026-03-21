import SwiftUI

// MARK: - SkeletonView

struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = Layout.radiusSm
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [BelongColor.skeleton, BelongColor.skeletonHighlight, BelongColor.skeleton],
                    startPoint: isAnimating ? .trailing : .leading,
                    endPoint: isAnimating ? .leading : .trailing
                )
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - SkeletonCard

struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SkeletonView(height: Layout.cardImageHeight, cornerRadius: 0)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SkeletonView(width: 200, height: 20)
                SkeletonView(width: 140, height: 14)
                SkeletonView(height: 14)
                HStack {
                    SkeletonView(width: 80, height: 14)
                    Spacer()
                    SkeletonView(width: 60, height: 14)
                }
            }
            .padding(.horizontal, Spacing.base)
            .padding(.bottom, Spacing.base)
        }
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var ctaTitle: String? = nil
    var onCTA: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(BelongColor.textTertiary)
            Text(title)
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
            if let ctaTitle = ctaTitle, let onCTA = onCTA {
                BelongButton(title: ctaTitle, style: .primary, action: onCTA)
            }
        }
        .padding(Spacing.xxl)
    }
}

// MARK: - ErrorStateView

struct ErrorStateView: View {
    let message: String
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.base) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(BelongColor.error)
            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
            if let onRetry = onRetry {
                BelongButton(title: "Retry", style: .secondary, action: onRetry)
            }
        }
        .padding(Spacing.xxl)
    }
}

// MARK: - InlineErrorBanner

struct InlineErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(BelongColor.error)
            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.error)
            Spacer()
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(BelongColor.error)
                        .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
                }
                .accessibilityLabel("Dismiss error")
            }
        }
        .padding(Spacing.md)
        .background(BelongColor.errorLight)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
    }
}

// MARK: - SuccessBanner

struct SuccessBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BelongColor.success)
            Text(message)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.success)
            Spacer()
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(BelongColor.success)
                        .frame(minWidth: Layout.touchTargetMin, minHeight: Layout.touchTargetMin)
                }
                .accessibilityLabel("Dismiss success message")
            }
        }
        .padding(Spacing.md)
        .background(BelongColor.successLight)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            SkeletonCard()
            EmptyStateView(
                icon: "calendar",
                title: "No gatherings yet",
                message: "Create or join a gathering to connect with your community.",
                ctaTitle: "Create Gathering",
                onCTA: {}
            )
            ErrorStateView(message: "Something went wrong. Please try again.", onRetry: {})
            InlineErrorBanner(message: "Failed to load data", onDismiss: {})
            SuccessBanner(message: "Profile updated successfully", onDismiss: {})
        }
        .padding()
    }
    .background(BelongColor.background)
}
