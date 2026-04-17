import Foundation

struct MindscapeAppDependencies {
    let authRepository: AuthRepository
    let profileRepository: ProfileRepository
    let therapistRepository: TherapistRepository
    let bookingRepository: BookingRepository
    let sessionRepository: SessionRepository
    let quoteRepository: QuoteRepository
    let concerns: [Concern]
    let homeSnapshot: HomeUISnapshot

    static func bootstrap(configuration: SupabaseConfiguration = .fromEnvironment()) -> MindscapeAppDependencies {
        if configuration.isConfigured {
            let client = SupabaseClientFactory.makeClient(configuration: configuration)

            return MindscapeAppDependencies(
                authRepository: SupabaseAuthRepository(supabase: client),
                profileRepository: SupabaseProfileRepository(supabase: client),
                therapistRepository: SupabaseTherapistRepository(supabase: client),
                bookingRepository: SupabaseBookingRepository(
                    supabase: client,
                    supabaseURL: configuration.url,
                    publishableKey: configuration.publicKey
                ),
                sessionRepository: SupabaseSessionRepository(
                    supabase: client,
                    supabaseURL: configuration.url,
                    publishableKey: configuration.publicKey
                ),
                quoteRepository: SupabaseQuoteRepository(supabase: client),
                concerns: MindscapeSampleData.concerns,
                homeSnapshot: MindscapeSampleData.homeSnapshot
            )
        }

        let unavailableMessage = configuration.missingConfigurationMessage()

        return MindscapeAppDependencies(
            authRepository: UnavailableAuthRepository(message: unavailableMessage),
            profileRepository: UnavailableProfileRepository(message: unavailableMessage),
            therapistRepository: UnavailableTherapistRepository(message: unavailableMessage),
            bookingRepository: UnavailableBookingRepository(message: unavailableMessage),
            sessionRepository: UnavailableSessionRepository(message: unavailableMessage),
            quoteRepository: UnavailableQuoteRepository(message: unavailableMessage),
            concerns: MindscapeSampleData.concerns,
            homeSnapshot: MindscapeSampleData.homeSnapshot
        )
    }

    static let preview: MindscapeAppDependencies = {
        let store = PreviewRepositoryStore()

        return MindscapeAppDependencies(
            authRepository: PreviewAuthRepository(store: store),
            profileRepository: PreviewProfileRepository(store: store),
            therapistRepository: PreviewTherapistRepository(store: store),
            bookingRepository: PreviewBookingRepository(store: store),
            sessionRepository: PreviewSessionRepository(store: store),
            quoteRepository: PreviewQuoteRepository(),
            concerns: store.concerns,
            homeSnapshot: store.homeSnapshot
        )
    }()
}
