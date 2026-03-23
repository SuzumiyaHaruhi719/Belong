import Foundation
import UIKit
import Supabase

@MainActor
final class SupabaseStorageService: StorageServiceProtocol {
    private let manager = SupabaseManager.shared

    func uploadImage(_ image: UIImage, bucket: StorageBucket, path: String, compressionQuality: CGFloat) async throws -> UploadResult {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw SupabaseServiceError.invalidData("Could not compress image")
        }

        let bucketName = bucket.rawValue
        try await manager.client.storage.from(bucketName)
            .upload(path, data: data, options: .init(contentType: "image/jpeg", upsert: true))

        let publicURL = try manager.client.storage.from(bucketName).getPublicURL(path: path)
        return UploadResult(publicURL: publicURL, path: path)
    }

    func deleteImage(bucket: StorageBucket, path: String) async throws {
        try await manager.client.storage.from(bucket.rawValue)
            .remove(paths: [path])
    }

    func publicURL(bucket: StorageBucket, path: String) -> URL? {
        try? manager.client.storage.from(bucket.rawValue).getPublicURL(path: path)
    }
}
