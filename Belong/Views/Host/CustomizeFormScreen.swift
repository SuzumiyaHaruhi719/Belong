import SwiftUI

// MARK: - CustomizeFormScreen (S20)
// Form for customizing gathering details after template selection.
// UX Decision: Sticky bottom button ensures the CTA is always visible
// even on long forms. Inline errors keep context near the problem.

struct CustomizeFormScreen: View {
    @Bindable var viewModel: HostViewModel
    @State private var navigateToPreview = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {

                    // MARK: Details Section
                    sectionHeader("DETAILS")

                    BelongTextField(
                        label: "Title",
                        text: $viewModel.title,
                        placeholder: "Give your gathering a name",
                        errorMessage: viewModel.fieldErrors["title"],
                        characterLimit: 60
                    )
                    .accessibilityLabel("Gathering title")

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Description")
                            .font(BelongFont.secondaryMedium())
                            .foregroundStyle(BelongColor.textPrimary)

                        TextField("What should people expect?", text: $viewModel.description, axis: .vertical)
                            .font(BelongFont.body())
                            .lineLimit(4...8)
                            .padding(Spacing.base)
                            .background(BelongColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                            .overlay {
                                RoundedRectangle(cornerRadius: Layout.radiusMd)
                                    .strokeBorder(
                                        viewModel.fieldErrors["description"] != nil
                                            ? BelongColor.error
                                            : BelongColor.border,
                                        lineWidth: 1
                                    )
                            }
                            .accessibilityLabel("Gathering description")

                        if let error = viewModel.fieldErrors["description"] {
                            Label(error, systemImage: "exclamationmark.circle.fill")
                                .font(BelongFont.caption())
                                .foregroundStyle(BelongColor.error)
                        }
                    }

                    // MARK: When Section
                    sectionHeader("WHEN")

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        DatePicker(
                            "Date & Time",
                            selection: $viewModel.date,
                            in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .font(BelongFont.body())
                        .tint(BelongColor.primary)
                        .accessibilityLabel("Gathering date and time")

                        if let error = viewModel.fieldErrors["date"] {
                            Label(error, systemImage: "exclamationmark.circle.fill")
                                .font(BelongFont.caption())
                                .foregroundStyle(BelongColor.error)
                        }
                    }

                    // MARK: Where Section
                    sectionHeader("WHERE")

                    BelongTextField(
                        label: "Location",
                        text: $viewModel.location,
                        placeholder: "Where will this happen?",
                        errorMessage: viewModel.fieldErrors["location"],
                        leadingIcon: "mappin"
                    )
                    .accessibilityLabel("Gathering location")

                    // MARK: Settings Section
                    sectionHeader("SETTINGS")

                    // Max attendees stepper
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Max attendees")
                            .font(BelongFont.secondaryMedium())
                            .foregroundStyle(BelongColor.textPrimary)

                        HStack {
                            Text("\(viewModel.maxAttendees)")
                                .font(BelongFont.h2())
                                .foregroundStyle(BelongColor.textPrimary)
                                .frame(width: 40)
                                .accessibilityLabel("\(viewModel.maxAttendees) attendees")

                            Stepper(
                                "Max attendees",
                                value: $viewModel.maxAttendees,
                                in: 2...50
                            )
                            .labelsHidden()
                            .accessibilityLabel("Adjust max attendees, currently \(viewModel.maxAttendees)")
                        }

                        if let error = viewModel.fieldErrors["maxAttendees"] {
                            Label(error, systemImage: "exclamationmark.circle.fill")
                                .font(BelongFont.caption())
                                .foregroundStyle(BelongColor.error)
                        }
                    }

                    // Cultural tags
                    ChipGroup(
                        title: "Cultural tags",
                        options: SampleData.culturalTagOptions.interests,
                        selected: $viewModel.culturalTags
                    )
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.bottom, Layout.buttonHeight + Spacing.xxxl)
            }

            // Sticky bottom button
            VStack(spacing: 0) {
                Divider()
                BelongButton(
                    title: "Preview",
                    style: .primary,
                    isDisabled: !viewModel.isFormValid
                ) {
                    if viewModel.validateForm() {
                        navigateToPreview = true
                    }
                }
                .padding(.horizontal, Layout.screenPadding)
                .padding(.vertical, Spacing.base)
            }
            .background(BelongColor.background)
        }
        .background(BelongColor.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Templates")
                    }
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.primary)
                }
                .accessibilityLabel("Back to templates")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Save draft action (placeholder)
                } label: {
                    Text("Save draft")
                        .font(BelongFont.secondary())
                        .foregroundStyle(BelongColor.primary)
                }
                .accessibilityLabel("Save draft")
            }
        }
        .navigationDestination(isPresented: $navigateToPreview) {
            PreviewPublishScreen(viewModel: viewModel)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(BelongFont.captionMedium())
            .foregroundStyle(BelongColor.textTertiary)
            .tracking(1)
    }
}

#Preview {
    NavigationStack {
        CustomizeFormScreen(viewModel: HostViewModel())
    }
}
