import SwiftUI

struct EmailConfirmedScreen: View {
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            EmailConfirmedBadge()
            EmailConfirmedText()
            Spacer()
            EmailConfirmedAction(path: $path)
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(true)
    }
}

struct EmailConfirmedBadge: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(BelongColor.successLight)
                .frame(width: 120, height: 120)
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 1.0 : 0.0)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(BelongColor.success)
                .scaleEffect(animate ? 1.0 : 0.3)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
        .task { animate = true }
    }
}

struct EmailConfirmedText: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("You're in!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)

            Text("Your account is ready. Let's set up your profile.")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct EmailConfirmedAction: View {
    @Binding var path: [AppState.OnboardingStep]

    var body: some View {
        BelongButton(
            title: "Set up profile \u{2192}",
            style: .primary,
            isFullWidth: true
        ) {
            path.append(.avatar)
        }
    }
}

#Preview {
    struct EmailConfirmedPreview: View {
        @State private var path: [AppState.OnboardingStep] = []
        var body: some View {
            NavigationStack(path: $path) {
                EmailConfirmedScreen(path: $path)
            }
        }
    }
    return EmailConfirmedPreview()
}
