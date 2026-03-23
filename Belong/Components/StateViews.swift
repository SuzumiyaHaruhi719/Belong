import SwiftUI

// MARK: - SkeletonView
// Gentle pulse instead of sliding gradient — feels calmer, less "loading screen".

struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = Layout.radiusSm
    @State private var opacity: Double = 0.4

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(BelongColor.skeleton)
            .frame(width: width, height: height)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    opacity = 1.0
                }
            }
    }
}

// MARK: - SkeletonCard

struct SkeletonCard: View {
    var staggerIndex: Int = 0

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
        .opacity(0.001)
        .onAppear {} // Stagger handled by parent
    }
}

// MARK: - EmptyStateView
// Warmer, more encouraging. Serif title + supportive body copy.
// Icon uses a soft circle backing instead of floating bare.

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var ctaTitle: String? = nil
    var onCTA: (() -> Void)? = nil
    @State private var appeared = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Icon with soft circular backing
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(BelongColor.primary.opacity(0.7))
                .frame(width: 64, height: 64)
                .background(BelongColor.primarySubtle)
                .clipShape(Circle())
                .scaleEffect(appeared ? 1.0 : 0.8)
                .opacity(appeared ? 1.0 : 0)

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(BelongFont.h3())
                    .foregroundStyle(BelongColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .opacity(appeared ? 1.0 : 0)

            if let ctaTitle = ctaTitle, let onCTA = onCTA {
                BelongButton(title: ctaTitle, style: .primary, action: onCTA)
                    .opacity(appeared ? 1.0 : 0)
            }
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xxxl)
        .onAppear {
            withAnimation(BelongMotion.expressive) {
                appeared = true
            }
        }
    }
}

// MARK: - ErrorStateView

struct ErrorStateView: View {
    let message: String
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(BelongColor.error.opacity(0.7))
                .frame(width: 64, height: 64)
                .background(BelongColor.errorLight)
                .clipShape(Circle())

            VStack(spacing: Spacing.sm) {
                Text("Something went wrong")
                    .font(BelongFont.h3())
                    .foregroundStyle(BelongColor.textPrimary)
                Text(message)
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            if let onRetry = onRetry {
                BelongButton(title: "Try again", style: .secondary, action: onRetry)
            }
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xxxl)
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
