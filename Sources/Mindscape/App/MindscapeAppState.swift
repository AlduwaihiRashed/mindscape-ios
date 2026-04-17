import Combine
import Foundation

@MainActor
final class MindscapeAppState: ObservableObject {
    @Published var selectedTab: MindscapeTab = .home
    @Published var navigationPath: [MindscapeDestination] = []
    @Published private(set) var authState = AuthUIState()
    @Published private(set) var discoveryState = DiscoveryUIState()
    @Published private(set) var bookingState = BookingUIState()
    @Published private(set) var bookingContextState = BookingContextUIState()
    @Published private(set) var checkoutState = CheckoutUIState()
    @Published private(set) var sessionState = SessionUIState()
    @Published private(set) var liveSessionState = LiveSessionUIState()
    @Published private(set) var profileState = ProfileUIState()
    @Published private(set) var quotes: [QuoteCard] = []
    @Published private(set) var concerns: [Concern]
    @Published private(set) var homeSnapshot: HomeUISnapshot
    @Published var loginPrompt: LoginPrompt?
    @Published var notificationsEnabled: Bool {
        didSet {
            profileState.notificationsEnabled = notificationsEnabled
        }
    }

    private let dependencies: MindscapeAppDependencies
    let supabaseConfiguration = SupabaseConfiguration.fromEnvironment()

    init(dependencies: MindscapeAppDependencies) {
        self.dependencies = dependencies
        concerns = dependencies.concerns
        homeSnapshot = dependencies.homeSnapshot
        notificationsEnabled = true

        Task {
            await refreshAll()
        }
    }

    var drawerProfileSummary: DrawerProfileSummary {
        if let session = authState.session {
            let displayName = session.fullName ?? session.email.split(separator: "@").first.map(String.init) ?? "Mindscape"
            let initials = displayName
                .split(separator: " ")
                .prefix(2)
                .compactMap { $0.first.map(String.init) }
                .joined()
                .uppercased()

            return DrawerProfileSummary(
                title: displayName,
                subtitle: session.email,
                initials: initials.isEmpty ? "M" : initials
            )
        }

        return DrawerProfileSummary(
            title: "Browsing as guest",
            subtitle: "Explore therapists freely. Sign in when you want to book or save progress.",
            initials: "G"
        )
    }

    var isAuthenticated: Bool {
        authState.session != nil
    }

    // MARK: - Refresh

    func refreshAll() async {
        let sessionResult = await loadCurrentSession()
        apply(sessionResult: sessionResult)

        async let discoveryResult = loadDiscovery()
        async let quotesResult = loadQuotes()

        apply(discoveryResult: await discoveryResult)
        apply(quotesResult: await quotesResult)

        if isAuthenticated {
            await refreshPersonalData()
        } else {
            bookingState = BookingUIState(isLoading: false)
            profileState = ProfileUIState(notificationsEnabled: notificationsEnabled, isLoading: false)
        }
    }

    func reloadDiscovery() async {
        apply(discoveryResult: await loadDiscovery())
    }

    func reloadBookings() async {
        apply(bookingResult: await loadBookings())
    }

    func reloadProfile() async {
        apply(profileResult: await loadProfile())
    }

    // MARK: - Booking Context

    func loadBookingContext(for therapist: TherapistSummary?) async {
        guard let therapist else {
            bookingContextState = BookingContextUIState(
                therapist: nil,
                availabilityDays: [],
                groupSessions: [],
                isLoading: false,
                errorMessage: nil,
                requiresTherapistSelection: true,
                isSubmitting: false,
                submissionErrorMessage: nil,
                submissionStatusMessage: nil
            )
            return
        }

        bookingContextState = BookingContextUIState(
            therapist: therapist,
            availabilityDays: [],
            groupSessions: [],
            isLoading: true,
            errorMessage: nil,
            requiresTherapistSelection: false,
            isSubmitting: false,
            submissionErrorMessage: nil,
            submissionStatusMessage: nil
        )

        do {
            async let slotsResult = dependencies.therapistRepository.listAvailabilitySlots(therapistId: therapist.id)
            async let groupsResult = dependencies.therapistRepository.listGroupSessions(therapistId: therapist.id)

            let slots = try await slotsResult
            let groups = try await groupsResult

            bookingContextState.therapist = therapist
            bookingContextState.availabilityDays = groupedAvailabilityDays(from: slots)
            bookingContextState.groupSessions = groups
            bookingContextState.isLoading = false
        } catch {
            bookingContextState.therapist = therapist
            bookingContextState.availabilityDays = []
            bookingContextState.groupSessions = []
            bookingContextState.errorMessage = userMessage(for: error, fallback: "We could not load availability right now.")
            bookingContextState.isLoading = false
        }
    }

    func createBookingDraft(therapistId: String, availabilitySlotId: String, sessionMode: SessionMode) async -> Bool {
        bookingContextState.isSubmitting = true
        bookingContextState.submissionErrorMessage = nil
        bookingContextState.submissionStatusMessage = nil

        do {
            let appointment = try await dependencies.bookingRepository.createDraft(
                therapistId: therapistId,
                availabilitySlotId: availabilitySlotId,
                sessionMode: sessionMode
            )

            await reloadBookings()
            bookingContextState.isSubmitting = false
            selectedTab = .appointments
            navigationPath.append(.checkout(bookingId: appointment.id))
            return true
        } catch {
            bookingContextState.submissionErrorMessage = userMessage(for: error, fallback: "We could not create your booking draft.")
            bookingContextState.isSubmitting = false
            return false
        }
    }

    func createGroupBookingDraft(groupSessionId: String) async -> Bool {
        bookingContextState.isSubmitting = true
        bookingContextState.submissionErrorMessage = nil
        bookingContextState.submissionStatusMessage = nil

        do {
            let appointment = try await dependencies.bookingRepository.createGroupDraft(groupSessionId: groupSessionId)

            await reloadBookings()
            bookingContextState.isSubmitting = false
            selectedTab = .appointments
            navigationPath.append(.checkout(bookingId: appointment.id))
            return true
        } catch {
            bookingContextState.submissionErrorMessage = userMessage(for: error, fallback: "We could not create your booking draft.")
            bookingContextState.isSubmitting = false
            return false
        }
    }

    // MARK: - Checkout

    func loadCheckout(bookingId: String) async {
        checkoutState = CheckoutUIState(isLoading: true)

        do {
            let appointment = try await dependencies.bookingRepository.getById(bookingId)
            checkoutState.appointment = appointment
            checkoutState.isLoading = false
        } catch {
            checkoutState.errorMessage = userMessage(for: error, fallback: "We could not load the booking details.")
            checkoutState.isLoading = false
        }
    }

    func startPayment(bookingId: String) async {
        checkoutState.isStartingPayment = true
        checkoutState.errorMessage = nil

        do {
            let launch = try await dependencies.bookingRepository.startPayment(bookingId: bookingId)
            checkoutState.isStartingPayment = false
            checkoutState.pendingPaymentLaunch = launch
        } catch {
            checkoutState.errorMessage = userMessage(for: error, fallback: "We could not start the payment flow.")
            checkoutState.isStartingPayment = false
        }
    }

    func verifyPayment(bookingId: String, paymentId: String) async {
        checkoutState.isVerifyingPayment = true
        checkoutState.errorMessage = nil

        do {
            let updated = try await dependencies.bookingRepository.verifyPayment(bookingId: bookingId, paymentId: paymentId)
            checkoutState.appointment = updated
            checkoutState.statusMessage = "Payment confirmed. Your session is booked."
            checkoutState.isVerifyingPayment = false
            await reloadBookings()
        } catch {
            checkoutState.errorMessage = userMessage(for: error, fallback: "We could not verify your payment.")
            checkoutState.isVerifyingPayment = false
        }
    }

    // MARK: - Session

    func loadSession(bookingId: String) async {
        sessionState = SessionUIState(isLoading: true)

        do {
            let details = try await dependencies.sessionRepository.getForBooking(bookingId)
            sessionState.details = details
            sessionState.isLoading = false
        } catch {
            sessionState.errorMessage = userMessage(for: error, fallback: "We could not load session details.")
            sessionState.isLoading = false
        }
    }

    func prepareJoin(bookingId: String) async {
        guard let details = sessionState.details else { return }

        liveSessionState = LiveSessionUIState(details: details, isLoading: false, isConnecting: true)

        do {
            let credentials = try await dependencies.sessionRepository.issueAgoraToken(bookingId: bookingId)
            liveSessionState.credentials = credentials
            liveSessionState.isConnecting = false
            navigationPath.append(.liveSession(bookingId: bookingId))
        } catch {
            liveSessionState.errorMessage = userMessage(for: error, fallback: "We could not connect to the session.")
            liveSessionState.isConnecting = false
        }
    }

    // MARK: - Cancel Booking

    func cancelBooking(bookingId: String, reason: String?) async -> Bool {
        do {
            _ = try await dependencies.bookingRepository.cancelBooking(bookingId: bookingId, reason: reason)
            await reloadBookings()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Profile

    func updateProfile(fullName: String, phone: String?) async {
        profileState.isSaving = true
        profileState.errorMessage = nil
        profileState.statusMessage = nil

        do {
            let updated = try await dependencies.profileRepository.updateProfile(fullName: fullName, phone: phone)
            profileState.profile = updated
            profileState.statusMessage = "Profile updated."
            profileState.isSaving = false
        } catch {
            profileState.errorMessage = userMessage(for: error, fallback: "We could not update your profile.")
            profileState.isSaving = false
        }
    }

    func updateLocale(_ locale: String) async {
        do {
            let updated = try await dependencies.profileRepository.updateLocale(locale)
            profileState.profile = updated
        } catch {
            profileState.errorMessage = userMessage(for: error, fallback: "We could not update your language preference.")
        }
    }

    // MARK: - Auth

    func signIn(email: String, password: String) async {
        if let validationMessage = validateEmail(email) {
            authState.errorMessage = validationMessage
            authState.statusMessage = nil
            authState.isLoading = false
            return
        }

        guard !password.isEmpty else {
            authState.errorMessage = "Password is required."
            authState.statusMessage = nil
            authState.isLoading = false
            return
        }

        authState.isLoading = true
        authState.errorMessage = nil
        authState.statusMessage = nil

        do {
            let session = try await dependencies.authRepository.signIn(email: email, password: password)
            authState.session = session
            authState.statusMessage = "You are signed in."
            loginPrompt = nil
            await refreshPersonalData()
        } catch {
            authState.errorMessage = userMessage(for: error, fallback: "We could not sign you in.")
        }

        authState.isLoading = false
    }

    func signUp(email: String, password: String, fullName: String?) async {
        if let validationMessage = validateEmail(email) {
            authState.errorMessage = validationMessage
            authState.statusMessage = nil
            authState.isLoading = false
            return
        }

        guard password.count >= 8 else {
            authState.errorMessage = "Password must be at least 8 characters."
            authState.statusMessage = nil
            authState.isLoading = false
            return
        }

        authState.isLoading = true
        authState.errorMessage = nil
        authState.statusMessage = nil

        do {
            authState.statusMessage = try await dependencies.authRepository.signUp(email: email, password: password, fullName: fullName)
        } catch {
            authState.errorMessage = userMessage(for: error, fallback: "We could not create your account.")
        }

        authState.isLoading = false
    }

    func resetPassword(email: String) async {
        if let validationMessage = validateEmail(email) {
            authState.errorMessage = validationMessage
            authState.statusMessage = nil
            authState.isLoading = false
            return
        }

        authState.isLoading = true
        authState.errorMessage = nil
        authState.statusMessage = nil

        do {
            authState.statusMessage = try await dependencies.authRepository.resetPassword(email: email)
        } catch {
            authState.errorMessage = userMessage(for: error, fallback: "We could not start the reset flow.")
        }

        authState.isLoading = false
    }

    func signOut() async {
        authState.isLoading = true
        authState.errorMessage = nil

        do {
            try await dependencies.authRepository.signOut()
            authState.session = nil
            authState.statusMessage = "You are signed out."
            profileState.profile = nil
            profileState.errorMessage = nil
            profileState.notificationsEnabled = notificationsEnabled
            profileState.isLoading = false
            bookingState.upcomingAppointments = []
            bookingState.pastAppointments = []
            bookingState.errorMessage = nil
            bookingState.isLoading = false
            navigationPath = []
        } catch {
            authState.errorMessage = userMessage(for: error, fallback: "We could not sign you out.")
        }

        authState.isLoading = false
    }

    // MARK: - Auth Gating

    func requireAuth(prompt: LoginPrompt, action: @escaping () async -> Void) async {
        guard isAuthenticated else {
            loginPrompt = prompt
            return
        }
        await action()
    }

    func dismissLoginPrompt() {
        loginPrompt = nil
        authState.errorMessage = nil
        authState.statusMessage = nil
    }

    func clearProfileMessages() {
        profileState.statusMessage = nil
        profileState.errorMessage = nil
    }

    // MARK: - Private Helpers

    private func refreshPersonalData() async {
        async let bookingResult = loadBookings()
        async let profileResult = loadProfile()

        apply(bookingResult: await bookingResult)
        apply(profileResult: await profileResult)
    }

    private func loadCurrentSession() async -> Result<UserSession?, Error> {
        authState.isLoading = true

        do {
            let session = try await dependencies.authRepository.currentSession()
            return .success(session)
        } catch {
            return .failure(error)
        }
    }

    private func loadDiscovery() async -> Result<[TherapistSummary], Error> {
        discoveryState.isLoading = true

        do {
            return .success(try await dependencies.therapistRepository.listTherapists())
        } catch {
            return .failure(error)
        }
    }

    private func loadBookings() async -> Result<[AppointmentSummary], Error> {
        bookingState.isLoading = true

        do {
            return .success(try await dependencies.bookingRepository.listMine())
        } catch {
            return .failure(error)
        }
    }

    private func loadProfile() async -> Result<UserProfile?, Error> {
        profileState.isLoading = true

        do {
            return .success(try await dependencies.profileRepository.getMe())
        } catch {
            return .failure(error)
        }
    }

    private func loadQuotes() async -> Result<[QuoteCard], Error> {
        do {
            return .success(try await dependencies.quoteRepository.listQuotes())
        } catch {
            return .failure(error)
        }
    }

    private func apply(sessionResult: Result<UserSession?, Error>) {
        switch sessionResult {
        case let .success(session):
            authState.session = session
            authState.errorMessage = nil
        case let .failure(error):
            authState.session = nil
            authState.errorMessage = userMessage(for: error, fallback: "We could not load your account state.")
        }

        authState.isLoading = false
    }

    private func apply(discoveryResult: Result<[TherapistSummary], Error>) {
        switch discoveryResult {
        case let .success(therapists):
            discoveryState.therapists = therapists
            discoveryState.errorMessage = nil
        case let .failure(error):
            discoveryState.therapists = []
            discoveryState.errorMessage = userMessage(for: error, fallback: "We could not load therapists right now.")
        }

        discoveryState.isLoading = false
    }

    private func apply(bookingResult: Result<[AppointmentSummary], Error>) {
        switch bookingResult {
        case let .success(bookings):
            bookingState.upcomingAppointments = bookings.filter {
                $0.status != .completed && $0.status != .canceled && $0.status != .expired && $0.status != .paymentFailed
            }
            bookingState.pastAppointments = bookings.filter {
                $0.status == .completed || $0.status == .canceled || $0.status == .expired || $0.status == .paymentFailed
            }
            bookingState.errorMessage = nil
        case let .failure(error):
            bookingState.upcomingAppointments = []
            bookingState.pastAppointments = []
            bookingState.errorMessage = userMessage(for: error, fallback: "We could not load appointments right now.")
        }

        bookingState.isLoading = false
    }

    private func apply(profileResult: Result<UserProfile?, Error>) {
        switch profileResult {
        case let .success(profile):
            profileState.profile = profile
            profileState.errorMessage = nil
        case let .failure(error):
            profileState.profile = nil
            profileState.errorMessage = userMessage(for: error, fallback: "We could not load your profile right now.")
        }

        profileState.notificationsEnabled = notificationsEnabled
        profileState.isLoading = false
    }

    private func apply(quotesResult: Result<[QuoteCard], Error>) {
        switch quotesResult {
        case let .success(cards):
            quotes = cards
        case .failure:
            // Keep existing quotes if we have them; fail silently
            if quotes.isEmpty {
                quotes = MindscapeSampleData.quotes
            }
        }
    }

    private func userMessage(for error: Error, fallback: String) -> String {
        (error as? LocalizedError)?.errorDescription ?? fallback
    }

    private func validateEmail(_ email: String) -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            return "Email is required."
        }

        let regex = /.+@.+\..+/
        return trimmedEmail.wholeMatch(of: regex) == nil ? "Enter a valid email address." : nil
    }

    private func groupedAvailabilityDays(from slots: [TherapistAvailabilitySlot]) -> [BookingAvailabilityDay] {
        let groupedSlots = Dictionary(grouping: slots, by: \.dayKey)

        return groupedSlots.keys.sorted().compactMap { dayKey in
            guard let daySlots = groupedSlots[dayKey], let firstSlot = daySlots.first else {
                return nil
            }

            return BookingAvailabilityDay(
                id: dayKey,
                dayLabel: firstSlot.dayLabel,
                dateLabel: firstSlot.dateLabel,
                slots: daySlots.map {
                    BookingTimeOption(id: $0.id, timeLabel: $0.timeLabel, startsAt: $0.startsAt)
                }
            )
        }
    }
}
