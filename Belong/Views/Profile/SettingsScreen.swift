import SwiftUI

// MARK: - SettingsScreen (S26)
// Account settings, preferences, and destructive actions.
// UX Decision: Destructive actions use confirmationDialogs (not alerts)
// to give clear context and require deliberate confirmation.

struct SettingsScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false

    private let userEmail = SampleData.currentUser.email
    private let userCity = SampleData.currentUser.city
    private let userLanguage = SampleData.currentUser.language

    var body: some View {
        Form {
            // MARK: Account
            Section {
                HStack {
                    Text("Email")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                    Spacer()
                    Text(userEmail)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                }
                .accessibilityLabel("Email: \(userEmail)")

                NavigationLink {
                    // Placeholder for change password screen
                    Text("Change Password")
                        .font(BelongFont.h2())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(BelongColor.background)
                } label: {
                    Text("Change password")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .accessibilityLabel("Change password")

                Toggle(isOn: $notificationsEnabled) {
                    Text("Notifications")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .tint(BelongColor.primary)
                .accessibilityLabel("Notifications")
                .accessibilityValue(notificationsEnabled ? "On" : "Off")
            } header: {
                Text("ACCOUNT")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textTertiary)
            }

            // MARK: Preferences
            Section {
                NavigationLink {
                    // Placeholder for language selection
                    Text("App Language")
                        .font(BelongFont.h2())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(BelongColor.background)
                } label: {
                    HStack {
                        Text("App language")
                            .font(BelongFont.body())
                            .foregroundStyle(BelongColor.textPrimary)
                        Spacer()
                        Text(userLanguage)
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                }
                .accessibilityLabel("App language, currently \(userLanguage)")

                HStack {
                    Text("City")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                    Spacer()
                    Text(userCity)
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                }
                .accessibilityLabel("City: \(userCity)")
            } header: {
                Text("PREFERENCES")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textTertiary)
            }

            // MARK: About
            Section {
                NavigationLink {
                    Text("Terms of Service")
                        .font(BelongFont.h2())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(BelongColor.background)
                } label: {
                    Text("Terms of Service")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .accessibilityLabel("Terms of Service")

                NavigationLink {
                    Text("Privacy Policy")
                        .font(BelongFont.h2())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(BelongColor.background)
                } label: {
                    Text("Privacy Policy")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textPrimary)
                }
                .accessibilityLabel("Privacy Policy")

                Text("Version 1.0.0")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            } header: {
                Text("ABOUT")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textTertiary)
            }

            // MARK: Account Actions
            Section {
                Button {
                    showLogoutConfirmation = true
                } label: {
                    Text("Log out")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .accessibilityLabel("Log out")

                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete account")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.error)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .accessibilityLabel("Delete account")
            } header: {
                Text("ACCOUNT ACTIONS")
                    .font(BelongFont.captionMedium())
                    .foregroundStyle(BelongColor.textTertiary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(BelongColor.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Log out",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Log out", role: .destructive) {
                appState.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
        .confirmationDialog(
            "Delete account",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete account", role: .destructive) {
                // In production, call server to delete then logout
                appState.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
            .environment(AppState())
    }
}
