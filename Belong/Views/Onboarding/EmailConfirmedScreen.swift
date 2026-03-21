import SwiftUI

// MARK: - EmailConfirmedScreen (S06)
// Success state after account creation steps are complete.
// Large checkmark, congratulatory text, single CTA. No back button.

struct EmailConfirmedScreen: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            BelongColor.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(BelongColor.success)
                    .accessibilityHidden(true)

                // Text
                VStack(spacing: Spacing.sm) {
                    Text("You're verified!")
                        .font(BelongFont.h1())
                        .foregroundStyle(BelongColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    Text("Your account is ready. Let's set up your profile.")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // CTA
                BelongButton(title: "Set up my profile", style: .primary) {
                    onContinue()
                }
                .accessibilityHint("Continue to profile setup")
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.xxxl)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        EmailConfirmedScreen(onContinue: {})
    }
}
