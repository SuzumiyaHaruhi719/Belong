import SwiftUI

struct ShareSheet: View {
    let shareURL: URL
    let shareTitle: String
    var recentContacts: [ShareContact] = []

    @Environment(\.dismiss) private var dismiss
    @State private var showSharedToast = false
    @State private var showActivitySheet = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            SheetDragHandle()

            Text("Share")
                .font(BelongFont.h2())
                .foregroundStyle(BelongColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            if !recentContacts.isEmpty {
                ShareRecentContacts(contacts: recentContacts) { contact in
                    shareToContact(contact)
                }

                Divider()
                    .background(BelongColor.divider)
            }

            ShareActionRow(
                icon: "link",
                title: "Copy link",
                accessibilityLabel: "Copy share link to clipboard"
            ) {
                copyLink()
            }

            ShareActionRow(
                icon: "square.and.arrow.up",
                title: "Share via...",
                accessibilityLabel: "Open system share menu"
            ) {
                showActivitySheet = true
            }

            Spacer()

            if showSharedToast {
                ShareToastBanner()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.md)
        .background(BelongColor.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showActivitySheet) {
            ActivityViewControllerWrapper(items: [shareTitle, shareURL])
                .presentationDetents([.medium, .large])
        }
    }

    private func copyLink() {
        UIPasteboard.general.url = shareURL
        showToastAndDismiss()
    }

    private func shareToContact(_ contact: ShareContact) {
        // Copy link and show success — DM integration deferred to v1.1
        UIPasteboard.general.url = shareURL
        showToastAndDismiss()
    }

    private func showToastAndDismiss() {
        withAnimation(.easeIn(duration: 0.3)) {
            showSharedToast = true
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

// MARK: - Share Contact Model

struct ShareContact: Identifiable, Hashable {
    let id: String
    let name: String
    let avatarEmoji: String
}

// MARK: - Recent Contacts

private struct ShareRecentContacts: View {
    let contacts: [ShareContact]
    let onTap: (ShareContact) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent")
                .font(BelongFont.captionMedium())
                .foregroundStyle(BelongColor.textTertiary)
                .textCase(.uppercase)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.base) {
                    ForEach(contacts) { contact in
                        ShareContactBubble(contact: contact) {
                            onTap(contact)
                        }
                    }
                }
            }
        }
    }
}

private struct ShareContactBubble: View {
    let contact: ShareContact
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.xs) {
                AvatarView(emoji: contact.avatarEmoji, size: .medium)

                Text(contact.name)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
                    .lineLimit(1)
                    .frame(width: 56)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Share with \(contact.name)")
    }
}

// MARK: - Action Row

private struct ShareActionRow: View {
    let icon: String
    let title: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(BelongColor.primary)
                    .frame(width: 24)

                Text(title)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(BelongColor.textTertiary)
            }
            .padding(Spacing.md)
            .frame(minHeight: Layout.touchTargetMin)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Toast

private struct ShareToastBanner: View {
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BelongColor.success)
            Text("Shared!")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.success)
        }
        .padding(Spacing.md)
        .background(BelongColor.successLight)
        .clipShape(Capsule())
        .accessibilityLabel("Shared successfully")
    }
}

// MARK: - UIActivityViewController Wrapper

struct ActivityViewControllerWrapper: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ShareSheet(
                shareURL: URL(string: "https://belong.app/gathering/abc123")!,
                shareTitle: "Korean BBQ Night",
                recentContacts: [
                    ShareContact(id: "1", name: "Min-Jun", avatarEmoji: "🧑‍🍳"),
                    ShareContact(id: "2", name: "Sakura", avatarEmoji: "🎎"),
                    ShareContact(id: "3", name: "Wei", avatarEmoji: "🌸"),
                    ShareContact(id: "4", name: "Priya", avatarEmoji: "🪷"),
                ]
            )
        }
}
