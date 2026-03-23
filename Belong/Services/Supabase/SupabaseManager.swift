import Foundation
import Supabase

@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://fdpolacfrisftrtwytgo.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkcG9sYWNmcmlzZnRydHd5dGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxNTM3NDEsImV4cCI6MjA4OTcyOTc0MX0._Hb34tKa8Jo4F4eAMxlPnQT2twj3Tc9CfPHF-dV_ZvI",
            options: SupabaseClientOptions(
                db: .init(schema: "public"),
                auth: .init(flowType: .pkce)
            )
        )
    }

    var currentUserId: String? {
        client.auth.currentUser?.id.uuidString.lowercased()
    }

    func requireUserId() throws -> String {
        guard let id = currentUserId else {
            throw SupabaseServiceError.notAuthenticated
        }
        return id
    }
}

enum SupabaseServiceError: LocalizedError {
    case notAuthenticated
    case notFound
    case serverError(String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "You must be logged in."
        case .notFound: return "The requested item was not found."
        case .serverError(let msg): return msg
        case .invalidData(let msg): return "Invalid data: \(msg)"
        }
    }
}
