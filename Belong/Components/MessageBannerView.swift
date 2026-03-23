import SwiftUI

struct MessageBannerView: View {
    let banner: InAppBanner
    let onTap: () -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Avatar
                avatarView

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(banner.senderName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .lineLimit(1)

                        Spacer()

                        Text(timeAgo(banner.timestamp))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Text(banner.messagePreview)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThickMaterial)
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            }
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height < -30 {
                        // Swiped up — dismiss
                        withAnimation(.spring(duration: 0.3)) {
                            dragOffset = -200
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDismiss()
                            dragOffset = 0
                        }
                    } else {
                        withAnimation(.spring(duration: 0.3)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .accessibilityLabel("New message from \(banner.senderName): \(banner.messagePreview)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Tap to open conversation. Swipe up to dismiss.")
    }

    @ViewBuilder
    private var avatarView: some View {
        if let url = banner.senderAvatarURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())
                default:
                    emojiAvatar
                }
            }
        } else {
            emojiAvatar
        }
    }

    private var emojiAvatar: some View {
        ZStack {
            Circle()
                .fill(BelongColor.primary.opacity(0.15))
                .frame(width: 42, height: 42)
            Text(banner.senderAvatarEmoji)
                .font(.system(size: 20))
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let diff = Date().timeIntervalSince(date)
        if diff < 60 { return "now" }
        if diff < 3600 { return "\(Int(diff / 60))m" }
        return "\(Int(diff / 3600))h"
    }
}

// MARK: - Banner Overlay Modifier

struct InAppBannerOverlay: ViewModifier {
    @Environment(InAppBannerManager.self) private var bannerManager
    @Environment(AppState.self) private var appState
    @State private var hapticTrigger = 0

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if bannerManager.isVisible, let banner = bannerManager.currentBanner {
                MessageBannerView(
                    banner: banner,
                    onTap: {
                        handleTap(banner)
                    },
                    onDismiss: {
                        bannerManager.dismiss()
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 8)
                .zIndex(9999)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
        .onChange(of: bannerManager.currentBanner?.id) { _, newId in
            if newId != nil {
                hapticTrigger += 1
            }
        }
    }

    private func handleTap(_ banner: InAppBanner) {
        bannerManager.dismiss()
        // Navigate to chat tab and the specific conversation
        appState.selectedTab = .chat
        // Post a notification to open the conversation
        NotificationCenter.default.post(
            name: .openConversation,
            object: nil,
            userInfo: [
                "conversationId": banner.conversationId,
                "conversation": banner.conversation
            ]
        )
    }
}

extension View {
    func inAppBannerOverlay() -> some View {
        modifier(InAppBannerOverlay())
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openConversation = Notification.Name("openConversation")
}
