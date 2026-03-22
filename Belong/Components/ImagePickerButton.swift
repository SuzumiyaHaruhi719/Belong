import SwiftUI
import PhotosUI

// MARK: - ImagePickerButton
// Reusable component for picking images from photo library.
// Used for: avatar upload, post images, gathering covers, profile backgrounds.
// UX: Uses PhotosPicker (iOS 16+) for native photo selection. Shows a loading
// spinner while processing. Calls onImageSelected with the UIImage.

struct ImagePickerButton<Label: View>: View {
    let onImageSelected: (UIImage) -> Void
    @ViewBuilder let label: () -> Label

    @State private var selectedItem: PhotosPickerItem?
    @State private var isProcessing = false

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            if isProcessing {
                ProgressView()
                    .frame(width: 24, height: 24)
            } else {
                label()
            }
        }
        .disabled(isProcessing)
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            isProcessing = true
            Task {
                defer { isProcessing = false }
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onImageSelected(image)
                }
            }
        }
    }
}

// MARK: - ImageUploadOverlay
// Shows upload progress or error state over an image area.
// Used on profile banner, gathering cover, avatar.

struct ImageUploadOverlay: View {
    enum UploadState {
        case idle
        case uploading
        case success
        case error(String)
    }

    let state: UploadState

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .uploading:
            ZStack {
                Color.black.opacity(0.4)
                ProgressView()
                    .tint(.white)
            }
        case .success:
            ZStack {
                Color.black.opacity(0.3)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
            .transition(.opacity)
        case .error(let message):
            ZStack {
                Color.black.opacity(0.4)
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(BelongColor.warning)
                    Text(message)
                        .font(BelongFont.caption())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(Spacing.sm)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ImagePickerButton { _ in } label: {
            Text("Pick Image")
                .padding()
                .background(BelongColor.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }

        ZStack {
            Rectangle().fill(BelongColor.skeleton).frame(height: 150)
            ImageUploadOverlay(state: .uploading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
