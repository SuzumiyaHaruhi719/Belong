import SwiftUI

// MARK: - BS01: Join Confirmation Sheet
// Spec: Drag handle, success animation, "You're going! 🎉" title,
// event summary, social proof, calendar + done buttons.
//
// UX Decision: Presented as a .sheet (not fullScreenCover) so the user
// can swipe down to dismiss. Success feedback is immediate and celebratory
// to reinforce the decision and reduce post-join anxiety.

struct JoinConfirmationSheet: View {
    let gathering: Gathering
    var onDone: () -> Void

    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Drag handle
            Capsule()
                .fill(BelongColor.border)
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.sm)

            // Success animation
            ZStack {
                Circle()
                    .fill(BelongColor.successLight)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(BelongColor.success)
                    .scaleEffect(showCheckmark ? 1 : 0.3)
                    .opacity(showCheckmark ? 1 : 0)
            }
            .accessibilityLabel("Success")

            // Title
            Text("You're going!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            // Event summary card
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(gathering.title)
                    .font(BelongFont.bodyMedium())
                    .foregroundStyle(BelongColor.textPrimary)

                HStack(spacing: Spacing.base) {
                    Label(gathering.date.formatted(.dateTime.month(.abbreviated).day().hour().minute()),
                          systemImage: "calendar")
                    Spacer()
                    Label(gathering.location, systemImage: "mappin")
                        .lineLimit(1)
                }
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
            }
            .padding(Spacing.base)
            .background(BelongColor.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))

            // Social proof
            HStack(spacing: -6) {
                ForEach(Array(gathering.attendeeAvatars.prefix(3).enumerated()), id: \.offset) { _, emoji in
                    Text(emoji)
                        .font(.system(size: 14))
                        .frame(width: 24, height: 24)
                        .background(BelongColor.surface)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(BelongColor.background, lineWidth: 1.5))
                }
                Text("\(gathering.attendeeCount) people are going")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
                    .padding(.leading, Spacing.sm)
            }

            Spacer()

            // Actions
            VStack(spacing: Spacing.sm) {
                BelongButton(title: "Add to my calendar", style: .secondary, systemImage: "calendar.badge.plus") {
                    // In production: EventKit integration
                }

                BelongButton(title: "Done", style: .primary) {
                    onDone()
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.xl)
        .background(BelongColor.background)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                showCheckmark = true
            }
        }
    }
}

#Preview {
    JoinConfirmationSheet(gathering: SampleData.topPick) {}
        .presentationDetents([.medium])
}
