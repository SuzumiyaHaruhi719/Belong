import SwiftUI

struct GatheringPreviewScreen: View {
    let viewModel: CreateGatheringViewModel
    @Binding var path: NavigationPath

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    GatheringPreviewBanner()

                    GatheringCard(gathering: viewModel.previewGathering)
                        .padding(.horizontal, Layout.screenPadding)

                    GatheringPreviewDetails(gathering: viewModel.previewGathering)
                        .padding(.horizontal, Layout.screenPadding)

                    if let error = viewModel.publishError {
                        InlineErrorBanner(message: error) {
                            viewModel.publishError = nil
                        }
                        .padding(.horizontal, Layout.screenPadding)
                    }

                    // Bottom spacing for sticky buttons
                    Spacer().frame(height: 120)
                }
                .padding(.top, Spacing.base)
            }

            GatheringPreviewBottomBar(
                isPublishing: viewModel.isPublishing,
                onPublish: {
                    Task {
                        await viewModel.publish()
                        if let gatheringId = viewModel.publishedGatheringId {
                            path.append(CreateRoute.publishedGathering(gatheringId))
                        }
                    }
                },
                onEdit: {
                    path.removeLast()
                }
            )
        }
        .background(BelongColor.background)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Info Banner

private struct GatheringPreviewBanner: View {
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "eye.fill")
                .foregroundStyle(BelongColor.info)
            Text("This is how your gathering will appear")
                .font(BelongFont.secondary())
                .foregroundStyle(BelongColor.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BelongColor.info.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .padding(.horizontal, Layout.screenPadding)
    }
}

// MARK: - Details Summary

private struct GatheringPreviewDetails: View {
    let gathering: Gathering

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: gathering.startsAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Details")
                .font(BelongFont.h3())
                .foregroundStyle(BelongColor.textPrimary)

            GatheringPreviewDetailRow(
                icon: "calendar",
                label: "Date",
                value: formattedDate
            )
            GatheringPreviewDetailRow(
                icon: "mappin.and.ellipse",
                label: "Location",
                value: gathering.locationName
            )
            GatheringPreviewDetailRow(
                icon: "person.2",
                label: "Capacity",
                value: "\(gathering.maxAttendees) people"
            )
            GatheringPreviewDetailRow(
                icon: "eye",
                label: "Visibility",
                value: gathering.visibility.displayTitle
            )

            if !gathering.tags.isEmpty {
                HStack(alignment: .top, spacing: Spacing.sm) {
                    Image(systemName: "tag")
                        .font(.system(size: 14))
                        .foregroundStyle(BelongColor.textTertiary)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Tags")
                            .font(BelongFont.caption())
                            .foregroundStyle(BelongColor.textTertiary)
                        Text(gathering.tags.joined(separator: ", "))
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textPrimary)
                    }
                }
            }
        }
        .padding(Spacing.base)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusLg))
    }
}

private struct GatheringPreviewDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(BelongColor.textTertiary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
                Text(value)
                    .font(BelongFont.secondary())
                    .foregroundStyle(BelongColor.textPrimary)
            }
        }
    }
}

// MARK: - Bottom Bar

private struct GatheringPreviewBottomBar: View {
    let isPublishing: Bool
    let onPublish: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: Spacing.sm) {
                BelongButton(
                    title: "Publish gathering",
                    style: .primary,
                    isFullWidth: true,
                    isLoading: isPublishing,
                    action: onPublish
                )
                BelongButton(
                    title: "Edit",
                    style: .secondary,
                    isFullWidth: true,
                    isDisabled: isPublishing,
                    action: onEdit
                )
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.md)
        }
        .background(BelongColor.background)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var path = NavigationPath()

        var body: some View {
            NavigationStack {
                GatheringPreviewScreen(
                    viewModel: {
                        let vm = CreateGatheringViewModel(container: DependencyContainer())
                        vm.selectTemplate(SampleData.hostingTemplates[0])
                        vm.title = "Vietnamese Pho Night"
                        vm.locationName = "Student Kitchen, Union House"
                        return vm
                    }(),
                    path: $path
                )
            }
        }
    }
    return PreviewWrapper()
}
