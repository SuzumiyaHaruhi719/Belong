import SwiftUI

struct NotificationSettingsScreen: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(BelongColor.primary.opacity(0.7))
                        .frame(width: 52, height: 52)
                        .background(BelongColor.primarySubtle)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Spacing.sm)

                    Text("Notification preferences")
                        .font(BelongFont.h3())
                        .foregroundStyle(BelongColor.textPrimary)

                    Text("Granular controls for likes, comments, follows, and gathering reminders are coming soon. For now, manage notifications through your device settings.")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.textSecondary)
                        .lineSpacing(3)
                }
                .listRowBackground(Color.clear)
            }

            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label {
                        Text("Open Device Settings")
                            .font(BelongFont.body())
                            .foregroundStyle(BelongColor.primary)
                    } icon: {
                        Image(systemName: "gear")
                            .foregroundStyle(BelongColor.primary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(BelongColor.background)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsScreen()
    }
    .environment(DependencyContainer())
}
