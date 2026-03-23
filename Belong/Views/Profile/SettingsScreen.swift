import SwiftUI
import Supabase
import Auth

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
                    let success = await viewModel.logout()
                    if success {
                        await appState.logout()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
        .confirmationDialog("Delete Account", isPresented: $viewModel.showDeleteConfirm) {
            Button("Delete Account", role: .destructive) {
                Task {
                    let success = await viewModel.deleteAccount()
                    if success {
                        await appState.logout()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "Please try again.")
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

            NavigationLink {
                PrivacySettingsScreen()
            } label: {
                SettingsRowLabel(title: "Privacy Settings", icon: "hand.raised")
            }

            NavigationLink {
                LanguageSettingsScreen()
            } label: {
                SettingsRowLabel(title: "Language", icon: "globe")
            }
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
            ChangePasswordScreen()
        } label: {
            SettingsRowLabel(title: title, icon: icon)
        }
    }
}

// MARK: - Change Password Screen

private struct ChangePasswordScreen: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isUpdating = false
    @State private var message: String?
    @State private var isSuccess = false

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    private var isPasswordStrong: Bool {
        newPassword.count >= 8
    }

    private var canSubmit: Bool {
        !currentPassword.isEmpty && passwordsMatch && isPasswordStrong && !isUpdating
    }

    var body: some View {
        Form {
            Section {
                SecureField("Current password", text: $currentPassword)
            } footer: {
                Text("Enter your current password to verify your identity")
                    .font(BelongFont.caption())
            }

            Section {
                SecureField("New password", text: $newPassword)
                SecureField("Confirm new password", text: $confirmPassword)
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    if !newPassword.isEmpty && !isPasswordStrong {
                        Text("Password must be at least 8 characters")
                            .foregroundStyle(BelongColor.error)
                    }
                    if !confirmPassword.isEmpty && !passwordsMatch {
                        Text("Passwords don't match")
                            .foregroundStyle(BelongColor.error)
                    }
                }
            }

            Section {
                Button {
                    Task { await updatePassword() }
                } label: {
                    HStack {
                        Text("Update Password")
                        Spacer()
                        if isUpdating { ProgressView() }
                    }
                }
                .disabled(!canSubmit)
            }

            if let message {
                Section {
                    Text(message)
                        .foregroundStyle(isSuccess ? BelongColor.success : BelongColor.error)
                        .font(BelongFont.secondary())
                }
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func updatePassword() async {
        isUpdating = true
        message = nil
        do {
            // Re-authenticate with current password first
            let email = try await SupabaseManager.shared.client.auth.session.user.email ?? ""
            _ = try await SupabaseManager.shared.client.auth.signIn(email: email, password: currentPassword)
            // Then update to new password
            try await SupabaseManager.shared.client.auth.update(user: .init(password: newPassword))
            isSuccess = true
            message = "Password updated successfully"
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        } catch {
            isSuccess = false
            let msg = error.localizedDescription
            if msg.contains("Invalid") || msg.contains("credentials") {
                message = "Current password is incorrect"
            } else {
                message = msg
            }
        }
        isUpdating = false
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

// MARK: - Privacy Settings Screen

struct PrivacySettingsScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @State private var privacyProfile: PrivacyLevel = .publicProfile
    @State private var privacyDM: DMPrivacy = .everyone
    @State private var isSaving = false
    @State private var saveError: String?

    var body: some View {
        Form {
            Section("Profile Visibility") {
                Picker("Who can see your profile", selection: $privacyProfile) {
                    Text("Public").tag(PrivacyLevel.publicProfile)
                    Text("School Only").tag(PrivacyLevel.schoolOnly)
                    Text("Followers Only").tag(PrivacyLevel.followersOnly)
                }
                .pickerStyle(.inline)
                .labelsHidden()
                .disabled(isSaving)
            }

            Section("Direct Messages") {
                Picker("Who can message you", selection: $privacyDM) {
                    Text("Mutuals Only").tag(DMPrivacy.mutualOnly)
                    Text("Everyone").tag(DMPrivacy.everyone)
                }
                .pickerStyle(.inline)
                .labelsHidden()
                .disabled(isSaving)
            }

            if let error = saveError {
                Section {
                    Text(error)
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.error)
                }
            }
        }
        .navigationTitle("Privacy Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let user = appState.currentUser {
                privacyProfile = user.privacyProfile
                privacyDM = user.privacyDM
            }
        }
        .onChange(of: privacyProfile) { _, newValue in
            savePrivacy(profile: newValue, dm: privacyDM)
        }
        .onChange(of: privacyDM) { _, newValue in
            savePrivacy(profile: privacyProfile, dm: newValue)
        }
    }

    private func savePrivacy(profile: PrivacyLevel, dm: DMPrivacy) {
        isSaving = true
        saveError = nil
        Task {
            do {
                try await container.userService.updateProfile([
                    "privacy_profile": profile.rawValue,
                    "privacy_dm": dm.rawValue
                ])
                appState.currentUser?.privacyProfile = profile
                appState.currentUser?.privacyDM = dm
            } catch {
                saveError = error.localizedDescription
            }
            isSaving = false
        }
    }
}

// MARK: - Language Settings Screen

struct LanguageSettingsScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @State private var selectedLanguage: String = "en"
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var savedSuccessfully = false

    private let languages: [(code: String, label: String)] = [
        ("en", "English"),
        ("zh", "中文"),
        ("ko", "한국어")
    ]

    var body: some View {
        Form {
            Section("App Language") {
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.code) { lang in
                        Text(lang.label).tag(lang.code)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section {
                if isSaving {
                    HStack {
                        ProgressView()
                        Text("Saving...")
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                } else if savedSuccessfully {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(BelongColor.success)
                        Text("Language preference saved")
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.success)
                    }
                }
            }

            Section {
                Text("Language preference affects content recommendations and gathering discovery. Full UI translation is coming in a future update.")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }

            if let error = saveError {
                Section {
                    Text(error)
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.error)
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let user = appState.currentUser {
                selectedLanguage = user.appLanguage
            }
        }
        .onChange(of: selectedLanguage) { _, newValue in
            isSaving = true
            saveError = nil
            Task {
                do {
                    try await container.userService.updateProfile(["app_language": newValue])
                    appState.currentUser?.appLanguage = newValue
                    savedSuccessfully = true
                    try? await Task.sleep(for: .seconds(2))
                    savedSuccessfully = false
                } catch {
                    saveError = error.localizedDescription
                }
                isSaving = false
            }
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
