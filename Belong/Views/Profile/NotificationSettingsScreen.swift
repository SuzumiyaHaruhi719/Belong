import SwiftUI

struct NotificationSettingsScreen: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: SettingsViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                NotificationSettingsContent(viewModel: vm)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = SettingsViewModel(authService: container.authService)
            }
        }
    }
}

// MARK: - Content

private struct NotificationSettingsContent: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Social") {
                NotificationToggleRow(title: "Likes", icon: "heart", isOn: $viewModel.notifyLikes)
                NotificationToggleRow(title: "Comments", icon: "bubble.left", isOn: $viewModel.notifyComments)
                NotificationToggleRow(title: "Follows", icon: "person.badge.plus", isOn: $viewModel.notifyFollows)
                NotificationToggleRow(title: "Mentions", icon: "at", isOn: $viewModel.notifyMentions)
            }

            Section("Gatherings") {
                NotificationToggleRow(title: "Gathering Reminders", icon: "bell", isOn: $viewModel.notifyGatheringReminders)
            }

            Section("Content") {
                NotificationToggleRow(title: "New Posts", icon: "square.grid.2x2", isOn: $viewModel.notifyNewPosts)
            }

            Section("Messages") {
                NotificationToggleRow(title: "Direct Messages", icon: "bubble.left.and.bubble.right", isOn: $viewModel.notifyDMs)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Toggle Row

private struct NotificationToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(title)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(BelongColor.textSecondary)
            }
        }
        .tint(BelongColor.primary)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsScreen()
    }
    .environment(DependencyContainer())
}
