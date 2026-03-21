import SwiftUI

struct JoinConfirmationSheet: View {
    let gathering: Gathering
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            SheetDragHandle()

            Spacer()

            JoinConfirmationCheckmark(isVisible: showCheckmark)

            Text("You're going!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.primary)
                .accessibilityAddTraits(.isHeader)

            JoinConfirmationSummary(gathering: gathering)

            JoinConfirmationSocialProof(
                count: gathering.attendeeCount,
                avatars: gathering.attendeeAvatars
            )

            Spacer()

            JoinConfirmationActions(dismiss: dismiss)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.top, Spacing.md)
        .background(BelongColor.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15)) {
                showCheckmark = true
            }
        }
    }
}

// MARK: - Checkmark Animation

private struct JoinConfirmationCheckmark: View {
    let isVisible: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(BelongColor.success)
                .frame(width: 80, height: 80)
            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
        }
        .scaleEffect(isVisible ? 1.0 : 0.3)
        .opacity(isVisible ? 1.0 : 0.0)
        .accessibilityLabel("Success checkmark")
    }
}

// MARK: - Event Summary

private struct JoinConfirmationSummary: View {
    let gathering: Gathering

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(gathering.title)
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(gathering.startsAt.formatted(date: .abbreviated, time: .shortened))
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)

            Text(gathering.locationName)
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)

            Text("Hosted by \(gathering.hostName)")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
    }
}

// MARK: - Social Proof

private struct JoinConfirmationSocialProof: View {
    let count: Int
    let avatars: [String]

    var body: some View {
        VStack(spacing: Spacing.sm) {
            JoinConfirmationFacePile(avatars: avatars)

            Text("\(count) people like you are attending")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

private struct JoinConfirmationFacePile: View {
    let avatars: [String]

    var body: some View {
        HStack(spacing: -8) {
            ForEach(Array(avatars.prefix(5).enumerated()), id: \.offset) { index, emoji in
                AvatarView(emoji: emoji, size: .small)
                    .overlay(
                        Circle().stroke(BelongColor.background, lineWidth: 2)
                    )
                    .zIndex(Double(5 - index))
            }
        }
        .accessibilityLabel("\(avatars.count) attendee avatars")
    }
}

// MARK: - Actions

private struct JoinConfirmationActions: View {
    let dismiss: DismissAction

    var body: some View {
        VStack(spacing: Spacing.md) {
            BelongButton(
                title: "Add to my calendar",
                style: .secondary,
                isFullWidth: true,
                leadingIcon: "calendar"
            ) {
                // Calendar integration placeholder
            }
            .accessibilityLabel("Add gathering to my calendar")

            BelongButton(
                title: "Done",
                style: .primary,
                isFullWidth: true
            ) {
                dismiss()
            }
            .accessibilityLabel("Done, close confirmation")
        }
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - Preview

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            JoinConfirmationSheet(
                gathering: Gathering(
                    id: "preview-1",
                    hostId: "host-1",
                    title: "Korean BBQ Night",
                    description: "Join us for an evening of Korean BBQ",
                    templateType: .food,
                    emoji: "🥩",
                    city: "Austin",
                    locationName: "Kbbq House",
                    startsAt: Date().addingTimeInterval(86400),
                    maxAttendees: 12,
                    visibility: .open,
                    vibe: .welcoming,
                    status: .upcoming,
                    isDraft: false,
                    tags: ["Korean", "Food"],
                    attendeeCount: 8,
                    attendeeAvatars: ["🧑‍🍳", "🎎", "🌸", "🎭", "🏮"],
                    hostName: "Min-Jun Park",
                    hostAvatarEmoji: "🧑‍🍳",
                    hostRating: 4.8,
                    isBookmarked: false,
                    isJoined: true,
                    isMaybe: false,
                    createdAt: Date()
                )
            )
        }
}
