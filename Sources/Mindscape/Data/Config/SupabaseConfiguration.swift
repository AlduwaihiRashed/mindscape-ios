import Foundation

struct SupabaseConfiguration: Hashable {
    let url: String
    let anonKey: String
    let publishableKey: String

    var publicKey: String {
        publishableKey.isEmpty ? anonKey : publishableKey
    }

    var isConfigured: Bool {
        !url.isEmpty && !publicKey.isEmpty
    }

    func missingConfigurationMessage() -> String {
        guard !isConfigured else { return "" }

        var missingFields: [String] = []
        if url.isEmpty {
            missingFields.append("SUPABASE_URL")
        }
        if anonKey.isEmpty && publishableKey.isEmpty {
            missingFields.append("SUPABASE_ANON_KEY or SUPABASE_PUBLISHABLE_KEY")
        }

        return "Supabase is not configured. Add \(missingFields.joined(separator: " and ")) to Configs/Supabase.xcconfig."
    }

    static func fromEnvironment(environment: [String: String] = ProcessInfo.processInfo.environment) -> SupabaseConfiguration {
        SupabaseConfiguration(
            url: environment["SUPABASE_URL", default: ""],
            anonKey: environment["SUPABASE_ANON_KEY", default: ""],
            publishableKey: environment["SUPABASE_PUBLISHABLE_KEY", default: ""]
        )
    }
}
