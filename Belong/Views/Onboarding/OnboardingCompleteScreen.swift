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
        // Checkmark in a warm circle — more intentional than a bare emoji
        ZStack {
            Circle()
                .fill(BelongColor.primarySubtle)
                .frame(width: 96, height: 96)
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 1.0 : 0)

            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(BelongColor.primary)
                .scaleEffect(animate ? 1.0 : 0.3)
                .opacity(animate ? 1.0 : 0)
        }
        .animation(BelongMotion.celebration, value: animate)
        .task {
            try? await Task.sleep(for: .milliseconds(150))
            animate = true
        }
    }
}

struct OnboardingCompleteText: View {
    @Environment(OnboardingViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Welcome, \(displayName)")
                .font(BelongFont.h1())
                .foregroundStyle(BelongColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    private var displayName: String {
        viewModel.displayName.isEmpty ? "friend" : viewModel.displayName
    }

    private var subtitle: String {
        if viewModel.selectedCity.isEmpty {
            return "Your profile is ready. Time to discover gatherings and connect with your community."
        }
        return "Your profile is ready. Time to discover what's happening in \(viewModel.selectedCity)."
    }
}

struct OnboardingCompleteAction: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingViewModel.self) private var viewModel
    @State private var isLoading = false

    @Environment(DependencyContainer.self) private var deps

    var body: some View {
        BelongButton(
            title: "Start exploring",
            style: .primary,
            isFullWidth: true,
            isLoading: isLoading
        ) {
            isLoading = true
            Task {
                // Get user ID from Supabase auth session
                let userId: String
                if let id = SupabaseManager.shared.currentUserId {
                    userId = id
                } else if let session = try? await SupabaseManager.shared.client.auth.session {
                    userId = session.user.id.uuidString.lowercased()
                } else {
                    userId = ""
                }

                // Persist onboarding profile data to DB before completing
                if !userId.isEmpty {
                    // Save display name, city, school
                    let dn = viewModel.displayName.isEmpty ? viewModel.username : viewModel.displayName
                    _ = try? await deps.userService.updateProfile(
                        displayName: dn,
                        bio: nil,
                        city: viewModel.selectedCity.isEmpty ? nil : viewModel.selectedCity,
                        school: viewModel.selectedSchool.isEmpty ? nil : viewModel.selectedSchool
                    )
                    // Save language
                    if !viewModel.selectedLanguage.isEmpty {
                        try? await deps.userService.updateProfile(["app_language": viewModel.selectedLanguage])
                    }
                }

                // Fetch the freshly updated user from DB
                if !userId.isEmpty,
                   let rows: [DBUser] = try? await SupabaseManager.shared.client.from("users")
                    .select().eq("id", value: userId).limit(1).execute().value,
                   let row = rows.first {
                    appState.completeOnboarding(user: mapUserRow(row))
                } else {
                    // Last resort: construct user with whatever ID we have
                    let fallbackId = userId.isEmpty ? UUID().uuidString : userId
                    let user = User(
                        id: fallbackId, email: viewModel.email, username: viewModel.username,
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
                isLoading = false
            }
        }
    }
}

#Preview {
    OnboardingCompleteScreen()
        .environment(AppState())
        .environment(OnboardingViewModel(deps: DependencyContainer()))
}
