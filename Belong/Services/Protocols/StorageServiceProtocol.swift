import Foundation
import UIKit

/// Storage bucket types matching Supabase storage buckets.
enum StorageBucket: String {
    case avatars = "avatars"
    case postImages = "post-images"
    case gatheringImages = "gathering-images"
    case profileBackgrounds = "profile-backgrounds"
}

/// Result of an image upload, containing the public URL.
struct UploadResult: Sendable {
    let publicURL: URL
    let path: String  // e.g. "avatars/{userId}/avatar.jpg"
}

/// Protocol for image upload/delete operations against Supabase Storage.
/// Path convention: {bucket}/{userId}/{filename}
protocol StorageServiceProtocol: Sendable {
    /// Upload an image to a bucket. Returns the public URL.
    /// - Parameters:
    ///   - image: UIImage to upload (will be JPEG compressed)
    ///   - bucket: Target storage bucket
    ///   - path: Path within bucket, e.g. "{userId}/avatar.jpg"
    ///   - compressionQuality: JPEG quality 0.0-1.0 (default 0.8)
    func uploadImage(
        _ image: UIImage,
        bucket: StorageBucket,
        path: String,
        compressionQuality: CGFloat
    ) async throws -> UploadResult

    /// Delete an image from a bucket.
    func deleteImage(bucket: StorageBucket, path: String) async throws

    /// Get the public URL for an existing file.
    func publicURL(bucket: StorageBucket, path: String) -> URL?
}

extension StorageServiceProtocol {
    func uploadImage(
        _ image: UIImage,
        bucket: StorageBucket,
        path: String,
        compressionQuality: CGFloat = 0.8
    ) async throws -> UploadResult {
        try await uploadImage(image, bucket: bucket, path: path, compressionQuality: compressionQuality)
    }
}
