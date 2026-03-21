import SwiftUI

struct SettingsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var appState
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                SettingsContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = SettingsViewModel(authService: container.authService)
                if let user = appState.currentUser {
                    vm.loadFromUser(user)
                }
                viewModel = vm
            }
        }
    }
}

// MARK: - Content

private struct SettingsContent: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            SettingsAccountSection()
            SettingsPreferencesSection()
            SettingsAboutSection()
            SettingsActionsSection(viewModel: viewModel)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .confirmationDialog("Log Out", isPresented: $viewModel.showLogoutConfirm) {
            Button("Log Out", role: .destructive) {
                Task {
                    await viewModel.logout()
                    appState.logout()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
        .confirmationDialog("Delete Account", isPresented: $viewModel.showDeleteConfirm) {
            Button("Delete Account", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                    appState.logout()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}

// MARK: - Account Section

private struct SettingsAccountSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Section("Account") {
            HStack {
                Text("Email")
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
                Spacer()
                Text(appState.currentUser?.email ?? "")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
            }

            SettingsNavigationRow(
                title: "Change Password",
                icon: "lock"
            )
        }
    }
}

// MARK: - Preferences Section

private struct SettingsPreferencesSection: View {
    var body: some View {
        Section("Preferences") {
            NavigationLink(value: ProfileRoute.notificationSettings) {
                SettingsRowLabel(title: "Notification Settings", icon: "bell")
            }

            SettingsNavigationRow(title: "Privacy Settings", icon: "hand.raised")

            SettingsNavigationRow(title: "Language", icon: "globe")
        }
    }
}

// MARK: - About Section

private struct SettingsAboutSection: View {
    var body: some View {
        Section("About") {
            NavigationLink(value: ProfileRoute.about) {
                SettingsRowLabel(title: "About", icon: "info.circle")
            }
        }
    }
}

// MARK: - Actions Section

private struct SettingsActionsSection: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        Section {
            Button {
                viewModel.showLogoutConfirm = true
            } label: {
                HStack {
                    Spacer()
                    Text("Log Out")
                        .font(BelongFont.bodySemiBold())
                        .foregroundStyle(BelongColor.primary)
                    Spacer()
                }
            }

            Button {
                viewModel.showDeleteConfirm = true
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Account")
                        .font(BelongFont.bodySemiBold())
                        .foregroundStyle(BelongColor.error)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Helper Views

private struct SettingsNavigationRow: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationLink {
            Text(title)
                .navigationTitle(title)
        } label: {
            SettingsRowLabel(title: title, icon: icon)
        }
    }
}

private struct SettingsRowLabel: View {
    let title: String
    let icon: String

    var body: some View {
        Label {
            Text(title)
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
    .environment(AppState())
    .environment(DependencyContainer())
}
