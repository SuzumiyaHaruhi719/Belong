import SwiftUI

// MARK: - ProfileScreen (S23) — Enhanced
// User profile hub with segmented sections: Overview, Activity, Hosted.
//
// UX Decisions:
// - Segmented control keeps the profile scannable while providing depth.
// - Overview shows identity + stats + tags + connections (the "who I am" view).
// - Activity shows browsing history + join history (the "what I've done" view).
// - Hosted shows host history with ratings (the "what I've created" view).
// - Stats row creates a sense of community investment and personal growth.
// - Horizontal scroll for connections keeps Overview scannable.
// - Browsing history includes a "Clear" option for privacy comfort.
// - Unrated past events surface gently — no forced modals.

struct ProfileScreen: View {
    @State private var viewModel = ProfileViewModel()
    @State private var navigateToEditTags = false
    @State private var navigateToSaved = false
    @State private var navigateToSettings = false

    // NOTE: No NavigationStack here — ProfileNavigationStack in MainTabView provides it.
    // Double-wrapping NavigationStack causes broken push transitions.

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                ProfileIdentityHeader(user: viewModel.user)

                ProfileStatsRow(stats: viewModel.user.stats)

                // Segmented section picker
                Picker("Section", selection: $viewModel.selectedSection) {
                    ForEach(ProfileViewModel.ProfileSection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Layout.screenPadding)

                // Section content
                switch viewModel.selectedSection {
                case .overview:
                    ProfileOverviewSection(
                        viewModel: viewModel,
                        onEditTags: {
                            viewModel.beginEditingTags()
                            navigateToEditTags = true
                        },
                        onSaved: { navigateToSaved = true }
                    )
                case .activity:
                    ProfileActivitySection(viewModel: viewModel)
                case .hosted:
                    ProfileHostedSection(viewModel: viewModel)
                }
            }
            .padding(.bottom, Spacing.xxxl)
        }
        .background(BelongColor.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gearshape") {
                    navigateToSettings = true
                }
                .font(.system(size: 18))
                .foregroundStyle(BelongColor.textPrimary)
                .frame(width: Layout.touchTargetMin, height: Layout.touchTargetMin)
            }
        }
        .navigationDestination(isPresented: $navigateToEditTags) {
            EditCulturalTagsScreen(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $navigateToSaved) {
            SavedGatheringsScreen(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsScreen()
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
    .environment(AppState())
}
