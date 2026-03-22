import Foundation
import UIKit

/// Mock storage service for previews and development.
/// Returns fake URLs that simulate successful uploads.
final class MockStorageService: StorageServiceProtocol {

    func uploadImage(
        _ image: UIImage,
        bucket: StorageBucket,
        path: String,
        compressionQuality: CGFloat
    ) async throws -> UploadResult {
        // Simulate network delay
        try await Task.sleep(for: .seconds(1.0))

        let fakeURL = URL(string: "https://fdpolacfrisftrtwytgo.supabase.co/storage/v1/object/public/\(bucket.rawValue)/\(path)")!
        return UploadResult(publicURL: fakeURL, path: path)
    }

    func deleteImage(bucket: StorageBucket, path: String) async throws {
        try await Task.sleep(for: .seconds(0.5))
    }

    func publicURL(bucket: StorageBucket, path: String) -> URL? {
        URL(string: "https://fdpolacfrisftrtwytgo.supabase.co/storage/v1/object/public/\(bucket.rawValue)/\(path)")
    }
}
