import SwiftUI
import Supabase

struct OnboardingCompleteScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()
            OnboardingCompleteCelebration()
            OnboardingCompleteText()
            Spacer()
            OnboardingCompleteAction()
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
        .navigationBarBackButtonHidden(true)
    }
}

struct OnboardingCompleteCelebration: View {
    @State private var animate = false

    var body: some View {
        Text("🎉")
            .font(.system(size: 80))
            .scaleEffect(animate ? 1.0 : 0.3)
            .opacity(animate ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animate)
            .task { animate = true }
    }
}

struct OnboardingCompleteText: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Welcome, \(displayName)!")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var displayName: String {
        viewModel.displayName.isEmpty ? "friend" : viewModel.displayName
    }

    private var subtitle: String {
        if viewModel.selectedCity.isEmpty {
            return "You're all set to explore."
        }
        return "You're all set to explore \(viewModel.selectedCity)."
    }
}

struct OnboardingCompleteAction: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        BelongButton(
            title: "Start exploring \u{2192}",
            style: .primary,
            isFullWidth: true
        ) {
            Task {
                // Use the real registered user from Supabase auth
                if let user = viewModel.registeredUser {
                    appState.completeOnboarding(user: user)
                } else if let userId = SupabaseManager.shared.currentUserId {
                    // Fallback: fetch from database using real auth ID
                    if let rows: [DBUser] = try? await SupabaseManager.shared.client.from("users")
                        .select().eq("id", value: userId).limit(1).execute().value,
                       let row = rows.first {
                        appState.completeOnboarding(user: mapUserRow(row))
                    } else {
                        // Last resort: local user with real auth ID
                        let user = User(
                            id: userId, email: viewModel.email, username: viewModel.username,
                            displayName: viewModel.displayName.isEmpty ? viewModel.username : viewModel.displayName,
                            avatarURL: nil, defaultAvatarId: nil, bio: "",
                            city: viewModel.selectedCity, school: viewModel.selectedSchool,
                            appLanguage: viewModel.selectedLanguage,
                            privacyProfile: .publicProfile, privacyDM: .mutualOnly,
                            notificationsEnabled: true,
                            followerCount: 0, followingCount: 0, mutualCount: 0,
                            gatheringsAttended: 0, gatheringsHosted: 0, postCount: 0,
                            createdAt: Date(), lastActiveAt: Date()
                        )
                        appState.completeOnboarding(user: user)
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingCompleteScreen()
        .environment(AppState())
        .environment(OnboardingViewModel(deps: DependencyContainer()))
}
