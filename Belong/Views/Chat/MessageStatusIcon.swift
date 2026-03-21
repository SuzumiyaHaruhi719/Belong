import SwiftUI

// MARK: - Message Status Icon
// Shows delivery status for the current user's messages.
// UX: Status icons are subtle (small, gray) to not distract from content.
// Failed status uses red for immediate attention.

struct MessageStatusIcon: View {
    let status: MessageStatus

    var body: some View {
        Group {
            switch status {
            case .sending:
                Image(systemName: "clock")
                    .foregroundStyle(BelongColor.textTertiary)
            case .sent:
                Image(systemName: "checkmark")
                    .foregroundStyle(BelongColor.textTertiary)
            case .delivered:
                Image(systemName: "checkmark")
                    .foregroundStyle(BelongColor.sage)
            case .read:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(BelongColor.sage)
            case .failed:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(BelongColor.error)
            }
        }
        .font(.system(size: 11))
        .accessibilityLabel("Message \(status.rawValue)")
    }
}
