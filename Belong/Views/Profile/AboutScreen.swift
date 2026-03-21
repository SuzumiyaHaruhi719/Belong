import SwiftUI

struct AboutScreen: View {
    var body: some View {
        List {
            Section {
                AboutAppHeader()
            }
            .listRowBackground(Color.clear)

            Section {
                AboutLinkRow(title: "Terms of Service", icon: "doc.text", urlString: "https://belong.app/terms")
                AboutLinkRow(title: "Privacy Policy", icon: "hand.raised", urlString: "https://belong.app/privacy")
            }

            Section {
                AboutVersionRow()
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(BelongColor.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - App Header

private struct AboutAppHeader: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundStyle(BelongColor.primary)

            Text("Belong")
                .font(BelongFont.display())
                .foregroundStyle(BelongColor.textPrimary)

            Text("Cultural belonging starts here.")
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
}

// MARK: - Link Row

private struct AboutLinkRow: View {
    let title: String
    let icon: String
    let urlString: String

    var body: some View {
        if let url = URL(string: urlString) {
            Link(destination: url) {
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
    }
}

// MARK: - Version Row

private struct AboutVersionRow: View {
    var body: some View {
        HStack {
            Text("Version")
                .font(BelongFont.body())
                .foregroundStyle(BelongColor.textPrimary)
            Spacer()
            Text("1.0.0 (1)")
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        AboutScreen()
    }
}
