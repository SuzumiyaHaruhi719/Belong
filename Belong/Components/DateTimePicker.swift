import SwiftUI

struct DateTimePicker: View {
    let label: String
    @Binding var selection: Date
    var displayedComponents: DatePicker<Text>.Components = [.date, .hourAndMinute]
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            DateTimePickerLabel(label: label)
            DateTimePickerRow(
                selection: selection,
                displayedComponents: displayedComponents,
                isExpanded: isExpanded,
                onTap: { withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() } }
            )
            if isExpanded {
                DateTimePickerExpanded(
                    selection: $selection,
                    displayedComponents: displayedComponents
                )
            }
        }
    }
}

struct DateTimePickerLabel: View {
    let label: String

    var body: some View {
        Text(label)
            .font(BelongFont.secondaryMedium())
            .foregroundStyle(BelongColor.textSecondary)
    }
}

struct DateTimePickerRow: View {
    let selection: Date
    let displayedComponents: DatePicker<Text>.Components
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(formattedDate)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(BelongColor.textTertiary)
                    .font(.system(size: 14))
            }
            .frame(height: Layout.inputHeight)
            .padding(.horizontal, Spacing.md)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMd)
                    .stroke(isExpanded ? BelongColor.borderFocused : BelongColor.border, lineWidth: 1)
            )
        }
        .accessibilityLabel("\(formattedDate), tap to change")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        if displayedComponents.contains(.date) && displayedComponents.contains(.hourAndMinute) {
            formatter.dateFormat = "EEE, MMM d, yyyy 'at' h:mm a"
        } else if displayedComponents.contains(.date) {
            formatter.dateStyle = .medium
        } else {
            formatter.timeStyle = .short
        }
        return formatter.string(from: selection)
    }
}

struct DateTimePickerExpanded: View {
    @Binding var selection: Date
    let displayedComponents: DatePicker<Text>.Components

    var body: some View {
        DatePicker("", selection: $selection, displayedComponents: displayedComponents)
            .datePickerStyle(.graphical)
            .tint(BelongColor.primary)
            .padding(Spacing.sm)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMd)
                    .stroke(BelongColor.border, lineWidth: 1)
            )
    }
}

#Preview {
    struct DateTimePickerPreview: View {
        @State private var date = Date()
        var body: some View {
            VStack(spacing: Spacing.lg) {
                DateTimePicker(label: "Start Date & Time", selection: $date)
                DateTimePicker(label: "End Date", selection: $date, displayedComponents: .date)
            }
            .padding()
            .background(BelongColor.background)
        }
    }
    return DateTimePickerPreview()
}
