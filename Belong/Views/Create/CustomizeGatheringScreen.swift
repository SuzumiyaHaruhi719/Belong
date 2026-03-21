import SwiftUI

// MARK: - SegmentOption Conformances

extension GatheringVisibility: SegmentOption {
    var displayTitle: String {
        switch self {
        case .open: "Open"
        case .matchingTags: "Tags"
        case .inviteOnly: "Invite"
        }
    }
}

extension GatheringVibe: SegmentOption {
    var displayTitle: String {
        switch self {
        case .lowKey: "Low-key"
        case .hype: "Hype"
        case .chill: "Chill"
        case .welcoming: "Welcoming"
        }
    }
}

struct CustomizeGatheringScreen: View {
    @Bindable var viewModel: CreateGatheringViewModel
    let template: HostingTemplate
    @Binding var path: NavigationPath
    @State private var attemptedPreview = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    CustomizeGatheringDetailsSection(viewModel: viewModel, attemptedPreview: attemptedPreview)
                    CustomizeGatheringWhenSection(viewModel: viewModel, attemptedPreview: attemptedPreview)
                    CustomizeGatheringWhereSection(viewModel: viewModel, attemptedPreview: attemptedPreview)
                    CustomizeGatheringSettingsSection(viewModel: viewModel)
                    CustomizeGatheringTagsSection(viewModel: viewModel)

                    // Bottom spacing for sticky button
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.top, Spacing.base)
            }

            // Sticky bottom button
            CustomizeGatheringBottomBar {
                attemptedPreview = true
                if viewModel.validateForm() {
                    path.append(CreateRoute.previewGathering)
                }
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save draft") {
                    viewModel.saveDraft()
                }
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.primary)
            }
        }
    }
}

// MARK: - Details Section

private struct CustomizeGatheringDetailsSection: View {
    @Bindable var viewModel: CreateGatheringViewModel
    let attemptedPreview: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Details")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            BelongTextField(
                label: "Title",
                text: $viewModel.title,
                placeholder: "Give your gathering a name",
                errorMessage: attemptedPreview ? viewModel.titleError : nil,
                characterLimit: 60
            )

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Description")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textSecondary)
                TextEditor(text: $viewModel.descriptionText)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
                    .padding(Spacing.md)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.radiusMd)
                            .stroke(BelongColor.border, lineWidth: 1)
                    )
                Text("Optional")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }
        }
    }
}

// MARK: - When Section

private struct CustomizeGatheringWhenSection: View {
    @Bindable var viewModel: CreateGatheringViewModel
    let attemptedPreview: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("When")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            DateTimePicker(
                label: "Date & Time",
                selection: $viewModel.selectedDate
            )

            if attemptedPreview, let dateError = viewModel.dateError {
                Text(dateError)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.error)
            }
        }
    }
}

// MARK: - Where Section

private struct CustomizeGatheringWhereSection: View {
    @Bindable var viewModel: CreateGatheringViewModel
    let attemptedPreview: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Where")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            BelongTextField(
                label: "Location",
                text: $viewModel.locationName,
                placeholder: "e.g. Student Kitchen, Union House",
                errorMessage: attemptedPreview ? viewModel.locationError : nil,
                leadingIcon: "mappin.and.ellipse"
            )
        }
    }
}

// MARK: - Settings Section

private struct CustomizeGatheringSettingsSection: View {
    @Bindable var viewModel: CreateGatheringViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Settings")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            StepperControl(
                value: $viewModel.maxAttendees,
                range: 2...50,
                label: "Max attendees"
            )

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Visibility")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textSecondary)
                SegmentedControl(
                    options: GatheringVisibility.allCases,
                    selected: $viewModel.selectedVisibility
                )
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Vibe")
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textSecondary)
                SegmentedControl(
                    options: GatheringVibe.allCases,
                    selected: $viewModel.selectedVibe
                )
            }
        }
    }
}

// MARK: - Tags Section

private struct CustomizeGatheringTagsSection: View {
    @Bindable var viewModel: CreateGatheringViewModel

    private let availableTags = [
        "Korean", "Japanese", "Chinese", "Vietnamese", "Thai",
        "Indian", "Filipino", "Food", "Cooking", "Study",
        "Sports", "Dancing", "Faith", "Meditation", "Festivals",
        "Low-key hangout"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Tags")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            ChipGroup(
                options: availableTags,
                selected: $viewModel.selectedTags
            )
        }
    }
}

// MARK: - Bottom Bar

private struct CustomizeGatheringBottomBar: View {
    let onPreview: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            BelongButton(
                title: "Preview",
                style: .primary,
                isFullWidth: true,
                leadingIcon: "arrow.right",
                action: onPreview
            )
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.md)
        }
        .background(BelongColor.background)
    }
}

#Preview {
    struct CustomizePreview: View {
        @State private var path = NavigationPath()

        var body: some View {
            NavigationStack {
                CustomizeGatheringScreen(
                    viewModel: CreateGatheringViewModel(container: DependencyContainer()),
                    template: SampleData.hostingTemplates[0],
                    path: $path
                )
            }
        }
    }
    return CustomizePreview()
}
