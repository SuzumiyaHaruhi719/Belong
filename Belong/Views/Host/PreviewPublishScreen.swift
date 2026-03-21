import SwiftUI

// MARK: - PreviewPublishScreen (S21)
// Shows how the gathering will appear to others before publishing.
// UX Decision: The info banner sets expectations that this is a preview,
// reducing anxiety about "did I publish accidentally?"

struct PreviewPublishScreen: View {
    @Bindable var viewModel: HostViewModel
    @State private var navigateToConfirmation = false
    @Environment(\.dismiss) private var dismiss

    private var previewGathering: Gathering {
        Gathering(
            id: "preview",
            title: viewModel.title,
            description: viewModel.description,
            imageURL: nil,
            hostName: SampleData.currentUser.displayName,
            hostAvatarEmoji: SampleData.currentUser.avatarEmoji,
            hostRating: 0,
            date: viewModel.date,
            location: viewModel.location,
            attendeeCount: 1,
            maxAttendees: viewModel.maxAttendees,
            attendeeAvatars: [SampleData.currentUser.avatarEmoji],
            culturalTags: viewModel.culturalTags,
            isBookmarked: false,
            status: .upcoming
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Info banner
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(BelongColor.primary)
                        Text("This is how your gathering will appear to others.")
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textPrimary)
                    }
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BelongColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))

                    // Gathering card preview
                    GatheringCard(gathering: previewGathering)
                        .disabled(true)
                        .accessibilityLabel("Gathering preview card")

                    // Details summary
                    VStack(alignment: .leading, spacing: Spacing.base) {
                        Text("Details")
                            .font(BelongFont.h2())
                            .foregroundStyle(BelongColor.textPrimary)

                        DetailRow(
                            icon: "calendar",
                            label: "Date & Time",
                            value: viewModel.date.formatted(
                                .dateTime.weekday(.wide).month(.abbreviated).day().hour().minute()
                            )
                        )

                        DetailRow(
                            icon: "mappin",
                            label: "Location",
                            value: viewModel.location
                        )

                        DetailRow(
                            icon: "person.2",
                            label: "Max attendees",
                            value: "\(viewModel.maxAttendees) people"
                        )

                        if !viewModel.culturalTags.isEmpty {
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                Image(systemName: "tag")
                                    .font(.system(size: 14))
                                    .foregroundStyle(BelongColor.textTertiary)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text("Cultural tags")
                                        .font(BelongFont.caption())
                                        .foregroundStyle(BelongColor.textTertiary)

                                    FlowLayout(spacing: Spacing.xs) {
                                        ForEach(viewModel.culturalTags, id: \.self) { tag in
                                            Text(tag)
                                                .font(BelongFont.captionMedium())
                                                .foregroundStyle(BelongColor.primary)
                                                .padding(.horizontal, Spacing.sm)
                                                .padding(.vertical, Spacing.xs)
                                                .background(BelongColor.accent)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.base)
                    .background(BelongColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Layout.buttonHeight * 2 + Spacing.xxxxl)
            }

            // Bottom buttons
            VStack(spacing: Spacing.sm) {
                Divider()

                BelongButton(
                    title: "Publish gathering",
                    style: .primary,
                    isLoading: viewModel.isPublishing
                ) {
                    Task {
                        await viewModel.publish()
                        if viewModel.isPublished {
                            navigateToConfirmation = true
                        }
                    }
                }
                .accessibilityLabel("Publish gathering")

                BelongButton(
                    title: "Edit",
                    style: .secondary
                ) {
                    dismiss()
                }
                .accessibilityLabel("Go back to edit")
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.bottom, Spacing.base)
            .background(BelongColor.background)
        }
        .background(BelongColor.background)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Edit")
                    }
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.primary)
                }
                .accessibilityLabel("Back to edit")
            }
        }
        .navigationDestination(isPresented: $navigateToConfirmation) {
            PublishedConfirmScreen(viewModel: viewModel)
        }
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(BelongColor.textTertiary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
                Text(value)
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textPrimary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview {
    NavigationStack {
        PreviewPublishScreen(viewModel: {
            let vm = HostViewModel()
            vm.title = "Vietnamese Pho Night"
            vm.description = "Learn to make authentic pho from scratch!"
            vm.location = "UniMelb Community Kitchen"
            vm.maxAttendees = 12
            vm.culturalTags = ["Vietnamese", "Cooking"]
            return vm
        }())
    }
}
