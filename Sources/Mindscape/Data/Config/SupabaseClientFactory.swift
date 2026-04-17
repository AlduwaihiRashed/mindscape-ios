import Foundation
import Supabase

enum SupabaseClientFactory {
    static func makeClient(configuration: SupabaseConfiguration) -> SupabaseClient {
        SupabaseClient(
            supabaseURL: URL(string: configuration.url)!,
            supabaseKey: configuration.publicKey
        )
    }
}
