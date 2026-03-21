import SwiftUI

// MARK: - PostVisibility SegmentOption

extension PostVisibility: SegmentOption {
    var displayTitle: String {
        switch self {
        case .publicPost: "Public"
        case .schoolOnly: "School only"
        case .followersOnly: "Followers only"
        }
    }
}

struct CreatePostScreen: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreatePostViewModel?

    var body: some View {
        NavigationStack {
            CreatePostContent(
                viewModel: resolvedViewModel,
                dismiss: dismiss
            )
            .navigationTitle("New post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(BelongColor.textSecondary)
                    }
                    .accessibilityLabel("Cancel")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await resolvedViewModel.publish()
                            if resolvedViewModel.isPublished {
                                dismiss()
                            }
                        }
                    } label: {
                        if resolvedViewModel.isPublishing {
                            ProgressView()
                                .tint(BelongColor.textOnPrimary)
                                .frame(width: 60, height: 32)
                                .background(BelongColor.primary)
                                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
                        } else {
                            Text("Post")
                                .font(BelongFont.bodySemiBold())
                                .foregroundStyle(BelongColor.textOnPrimary)
                                .frame(width: 60, height: 32)
                                .background(resolvedViewModel.canPublish ? BelongColor.primary : BelongColor.disabled)
                                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))
                        }
                    }
                    .disabled(!resolvedViewModel.canPublish || resolvedViewModel.isPublishing)
                }
            }
        }
    }

    private var resolvedViewModel: CreatePostViewModel {
        if let vm = viewModel { return vm }
        let vm = CreatePostViewModel(container: container)
        Task { @MainActor in viewModel = vm }
        return vm
    }
}

// MARK: - Content

private struct CreatePostContent: View {
    @Bindable var viewModel: CreatePostViewModel
    let dismiss: DismissAction

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // Image section
                CreatePostImageSection(viewModel: viewModel)

                // Text editor
                CreatePostTextEditor(viewModel: viewModel)

                // Tag suggestions
                if !viewModel.tagSuggestions.isEmpty {
                    CreatePostTagSuggestions(
                        suggestions: viewModel.tagSuggestions,
                        onSelect: { tag in
                            insertTag(tag)
                        }
                    )
                }

                // Visibility
                CreatePostVisibilitySection(viewModel: viewModel)

                // Link gathering
                CreatePostLinkGatheringSection(viewModel: viewModel)

                if let error = viewModel.publishError {
                    InlineErrorBanner(message: error) {
                        viewModel.publishError = nil
                    }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.top, Spacing.base)
        }
        .background(BelongColor.background)
        .onChange(of: viewModel.content) { _, newValue in
            checkForHashtag(in: newValue)
        }
    }

    private func checkForHashtag(in text: String) {
        // Find the last word being typed
        let words = text.split(separator: " ", omittingEmptySubsequences: false)
        guard let lastWord = words.last, lastWord.hasPrefix("#"), lastWord.count > 1 else {
            viewModel.tagSuggestions = []
            return
        }
        let query = String(lastWord.dropFirst())
        Task {
            await viewModel.fetchTagSuggestions(query: query)
        }
    }

    private func insertTag(_ tag: String) {
        // Replace the partial hashtag with the full tag
        let words = viewModel.content.split(separator: " ", omittingEmptySubsequences: false)
        var mutableWords = words.map(String.init)
        if let last = mutableWords.last, last.hasPrefix("#") {
            mutableWords[mutableWords.count - 1] = "#\(tag)"
        } else {
            mutableWords.append("#\(tag)")
        }
        viewModel.content = mutableWords.joined(separator: " ") + " "
        viewModel.tagSuggestions = []
    }
}

// MARK: - Image Section

private struct CreatePostImageSection: View {
    @Bindable var viewModel: CreatePostViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Photos")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(viewModel.selectedImageURLs.enumerated()), id: \.offset) { index, url in
                        CreatePostImageThumbnail(url: url) {
                            viewModel.removeImage(at: index)
                        }
                    }

                    if viewModel.canAddMoreImages {
                        CreatePostAddImageButton {
                            // In production: open photo picker
                            // For mock: add a sample image
                            let sampleURL = URL(string: "https://picsum.photos/seed/post-\(viewModel.imageCount)/400/400")!
                            viewModel.addImage(url: sampleURL)
                        }
                    }
                }
            }

            Text("\(viewModel.imageCount)/9 photos")
                .font(BelongFont.caption())
                .foregroundStyle(BelongColor.textTertiary)
        }
    }
}

private struct CreatePostImageThumbnail: View {
    let url: URL
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    BelongColor.skeleton
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
            .offset(x: 4, y: -4)
            .accessibilityLabel("Remove image")
        }
    }
}

private struct CreatePostAddImageButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(BelongColor.primary)
                Text("Add")
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
            }
            .frame(width: 100, height: 100)
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMd)
                    .stroke(BelongColor.border, style: StrokeStyle(lineWidth: 1, dash: [6]))
            )
        }
        .accessibilityLabel("Add photo")
    }
}

// MARK: - Text Editor

private struct CreatePostTextEditor: View {
    @Bindable var viewModel: CreatePostViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Caption")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            ZStack(alignment: .topLeading) {
                if viewModel.content.isEmpty {
                    Text("Share your experience... Use # for tags")
                        .font(BelongFont.body())
                        .foregroundStyle(BelongColor.textTertiary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.md + 4)
                }
                TextEditor(text: $viewModel.content)
                    .font(BelongFont.body())
                    .foregroundStyle(BelongColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(Spacing.sm)
            }
            .background(BelongColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMd)
                    .stroke(BelongColor.border, lineWidth: 1)
            )

            if !viewModel.extractedTags.isEmpty {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "tag")
                        .font(.system(size: 12))
                        .foregroundStyle(BelongColor.textTertiary)
                    Text(viewModel.extractedTags.map { "#\($0)" }.joined(separator: " "))
                        .font(BelongFont.caption())
                        .foregroundStyle(BelongColor.primary)
                }
            }
        }
    }
}

// MARK: - Tag Suggestions

private struct CreatePostTagSuggestions: View {
    let suggestions: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Suggested tags")
                .font(BelongFont.captionMedium())
                .foregroundStyle(BelongColor.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(suggestions, id: \.self) { tag in
                        Button {
                            onSelect(tag)
                        } label: {
                            Text("#\(tag)")
                                .font(BelongFont.secondaryMedium())
                                .foregroundStyle(BelongColor.primary)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(BelongColor.surfaceSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Visibility Section

private struct CreatePostVisibilitySection: View {
    @Bindable var viewModel: CreatePostViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Visibility")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            SegmentedControl(
                options: PostVisibility.allCases,
                selected: $viewModel.visibility
            )
        }
    }
}

// MARK: - Link Gathering Section

private struct CreatePostLinkGatheringSection: View {
    @Bindable var viewModel: CreatePostViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Link a gathering")
                .font(BelongFont.secondaryMedium())
                .foregroundStyle(BelongColor.textSecondary)

            Button {
                // In production: show gathering picker
                // For mock: toggle linked gathering
                if viewModel.linkedGatheringId != nil {
                    viewModel.linkedGatheringId = nil
                } else {
                    viewModel.linkedGatheringId = SampleData.gatheringIdPho
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: viewModel.linkedGatheringId != nil ? "link.circle.fill" : "link.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(BelongColor.primary)

                    if viewModel.linkedGatheringId != nil {
                        Text("Gathering linked")
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textPrimary)
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(BelongColor.textTertiary)
                    } else {
                        Text("Link to a gathering (optional)")
                            .font(BelongFont.secondary())
                            .foregroundStyle(BelongColor.textTertiary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(BelongColor.textTertiary)
                    }
                }
                .padding(Spacing.md)
                .background(BelongColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusMd)
                        .stroke(BelongColor.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    CreatePostScreen()
        .environment(DependencyContainer())
}
