import SwiftUI

struct ChatMediaScreen: View {
    let conversationId: String
    @Environment(DependencyContainer.self) private var container
    @State private var mediaURLs: [URL] = []
    @State private var isLoading = true
    @State private var selectedImageURL: URL?
    @State private var showFullScreen = false

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if mediaURLs.isEmpty {
                EmptyStateView(
                    icon: "photo.on.rectangle.angled",
                    title: "No shared media",
                    message: "Photos shared in this conversation will appear here."
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(mediaURLs, id: \.absoluteString) { url in
                            ChatMediaGridItem(url: url) {
                                selectedImageURL = url
                                showFullScreen = true
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .background(BelongColor.background)
        .navigationTitle("Media")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showFullScreen) {
            if let url = selectedImageURL {
                ChatMediaFullScreen(url: url) {
                    showFullScreen = false
                }
            }
        }
        .task {
            await loadMedia()
        }
    }

    private func loadMedia() async {
        do {
            let messages = try await container.chatService.fetchMessages(conversationId: conversationId, page: 1)
            mediaURLs = messages.compactMap { $0.imageURL }
        } catch {}
        isLoading = false
    }
}

// MARK: - Grid Item

private struct ChatMediaGridItem: View {
    let url: URL
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    BelongColor.skeleton
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(BelongColor.textTertiary)
                        }
                default:
                    BelongColor.skeleton
                }
            }
            .frame(minHeight: 120)
            .clipped()
        }
        .accessibilityLabel("Shared image")
    }
}

// MARK: - Full Screen Viewer

private struct ChatMediaFullScreen: View {
    let url: URL
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                default:
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
            }
            .accessibilityLabel("Close image")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChatMediaScreen(conversationId: SampleData.conversationIdMaiYuki)
            .environment(DependencyContainer())
    }
}
