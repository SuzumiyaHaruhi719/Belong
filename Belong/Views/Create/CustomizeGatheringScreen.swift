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
    let template: HostingTemplate?
    @Binding var path: NavigationPath
    @State private var attemptedPreview = false
    @State private var showDraftSavedBanner = false
    @State private var bannerDismissTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Draft saved confirmation banner
                    if showDraftSavedBanner {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(BelongColor.success)
                            Text("Draft saved")
                                .font(BelongFont.secondaryMedium())
                                .foregroundStyle(BelongColor.textPrimary)
                        }
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(BelongColor.success.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if let error = viewModel.draftError {
                        InlineErrorBanner(message: error) {
                            viewModel.draftError = nil
                        }
                    }

                    CustomizeGatheringCoverSection(viewModel: viewModel)
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
            CustomizeGatheringBottomBar(isDisabled: viewModel.isCoverUploading) {
                attemptedPreview = true
                if viewModel.isCoverUploading {
                    viewModel.draftError = "Please wait for the cover image to finish uploading"
                    return
                }
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
                Button {
                    Task {
                        await viewModel.saveDraft()
                        if viewModel.draftSaved {
                            // Cancel any previous banner dismiss to avoid race
                            bannerDismissTask?.cancel()
                            withAnimation { showDraftSavedBanner = true }
                            bannerDismissTask = Task {
                                try? await Task.sleep(for: .seconds(2.5))
                                if !Task.isCancelled {
                                    withAnimation { showDraftSavedBanner = false }
                                }
                            }
                        }
                    }
                } label: {
                    if viewModel.isSavingDraft {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Save draft")
                    }
                }
                .disabled(viewModel.isSavingDraft || viewModel.isCoverUploading)
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.primary)
            }
        }
    }
}

// MARK: - Cover Image Section
// UX: Large tappable area at the top of the form encourages adding a cover photo.
// Shows the selected image with an overlay upload state indicator.
// "Remove" button appears only after an image is selected.

private struct CustomizeGatheringCoverSection: View {
    @Bindable var viewModel: CreateGatheringViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Cover Image")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            ImagePickerButton { image in
                viewModel.selectCoverImage(image)
            } label: {
                ZStack {
                    if let coverImage = viewModel.coverImage {
                        // Show selected image
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                    } else {
                        // Placeholder
                        RoundedRectangle(cornerRadius: Layout.radiusLg)
                            .fill(BelongColor.surfaceSecondary)
                            .frame(height: 180)
                            .overlay {
                                VStack(spacing: Spacing.sm) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 32))
                                        .foregroundStyle(BelongColor.textTertiary)
                                    Text("Add cover photo")
                                        .font(BelongFont.secondary())
                                        .foregroundStyle(BelongColor.textTertiary)
                                }
                            }
                    }

                    // Upload state overlay
                    ImageUploadOverlay(state: viewModel.coverUploadState)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                }
            }
            .accessibilityLabel("Select cover image for gathering")

            // Remove button when image exists
            if viewModel.coverImage != nil {
                Button("Remove cover photo", role: .destructive) {
                    viewModel.removeCoverImage()
                }
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.error)
            }

            Text("A good cover photo helps your gathering stand out")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
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
    @State private var availableTags: [String] = []
    @State private var isLoadingTags = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.base) {
            Text("Tags")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            if isLoadingTags {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ChipGroup(
                    options: availableTags,
                    selected: $viewModel.selectedTags
                )
            }
        }
        .task {
            await loadTags()
        }
    }

    private func loadTags() async {
        isLoadingTags = true
        do {
            async let backgrounds = viewModel.container.userService.fetchTagPresets(category: .culturalBackground)
            async let interests = viewModel.container.userService.fetchTagPresets(category: .interestVibe)
            let bgResult = try await backgrounds
            let interestResult = try await interests
            availableTags = bgResult + interestResult
        } catch {
            // Fallback to hardcoded common tags so user can still create a gathering
            availableTags = [
                "Chinese", "Indian", "Vietnamese", "Korean", "Filipino", "Japanese", "Malaysian",
                "European", "Latin American", "African", "Middle Eastern",
                "Foodie", "Study buddy", "Nightlife", "Sports", "Music", "Art", "Gaming",
                "Travel", "Fitness", "Photography", "Cooking", "Reading", "Tech"
            ]
        }
        isLoadingTags = false
    }
}

// MARK: - Bottom Bar

private struct CustomizeGatheringBottomBar: View {
    var isDisabled: Bool = false
    let onPreview: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            BelongButton(
                title: isDisabled ? "Uploading image…" : "Preview",
                style: .primary,
                isFullWidth: true,
                isDisabled: isDisabled,
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
