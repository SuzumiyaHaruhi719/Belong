import SwiftUI

// MARK: - BS03: Save Connections Sheet
// Spec: Attendee list with independent "Connect" buttons per row.
// Done button shows count of connections made.
//
// UX Decision: Each "Connect" is independent (not a bulk select-all)
// to respect that connecting is a personal choice. The button label
// changes to "Connected ✓" immediately — no waiting for server.
// This mirrors how adding friends should feel: light, immediate, reversible.

struct SaveConnectionsSheet: View {
    let gathering: Gathering
    @State var connections: [Connection]
    var onDone: (() -> Void)? = nil

    private var connectedCount: Int {
        connections.filter(\.isConnected).count
    }

    var body: some View {
        VStack(spacing: Spacing.base) {
            // Drag handle
            Capsule()
                .fill(BelongColor.border)
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.sm)

            // Header
            VStack(spacing: Spacing.xs) {
                Text("Stay connected")
                    .font(BelongFont.h1())
                    .foregroundStyle(BelongColor.textPrimary)

                Text("Save the people you'd like to see again")
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textSecondary)
            }

            // Attendee list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array($connections.enumerated()), id: \.element.id) { index, $connection in
                        HStack(spacing: Spacing.md) {
                            AvatarView(emoji: connection.avatarEmoji, size: 40)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(connection.name)
                                    .font(BelongFont.bodyMedium())
                                    .foregroundStyle(BelongColor.textPrimary)

                                if connection.mutualEvents > 0 {
                                    Text("\(connection.mutualEvents) mutual event\(connection.mutualEvents == 1 ? "" : "s")")
                                        .font(BelongFont.caption())
                                        .foregroundStyle(BelongColor.textTertiary)
                                }
                            }

                            Spacer()

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    connections[index].isConnected.toggle()
                                }
                            } label: {
                                HStack(spacing: Spacing.xs) {
                                    if connection.isConnected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    Text(connection.isConnected ? "Connected" : "Connect")
                                        .font(BelongFont.secondaryMedium())
                                }
                                .foregroundStyle(connection.isConnected ? BelongColor.success : BelongColor.primary)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(connection.isConnected ? BelongColor.successLight : BelongColor.surfaceSecondary)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .strokeBorder(connection.isConnected ? BelongColor.success.opacity(0.3) : BelongColor.primary.opacity(0.3), lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(connection.isConnected ? "Connected with \(connection.name)" : "Connect with \(connection.name)")
                        }
                        .padding(.vertical, Spacing.md)
                        .padding(.horizontal, Spacing.xs)

                        if index < connections.count - 1 {
                            Divider()
                                .foregroundStyle(BelongColor.divider)
                        }
                    }
                }
            }

            // Bottom actions
            VStack(spacing: Spacing.sm) {
                BelongButton(
                    title: connectedCount > 0 ? "Done (\(connectedCount) connected)" : "Done",
                    style: .primary
                ) {
                    onDone?()
                }

                if connectedCount == 0 {
                    BelongButton(title: "Skip", style: .tertiary) {
                        onDone?()
                    }
                }
            }
        }
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Spacing.xl)
        .background(BelongColor.background)
    }
}

#Preview {
    SaveConnectionsSheet(
        gathering: SampleData.topPick,
        connections: SampleData.connections
    )
    .presentationDetents([.large])
}
