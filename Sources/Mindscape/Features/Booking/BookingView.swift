import SwiftUI

struct BookingView: View {
    @ObservedObject var appState: MindscapeAppState
    let therapist: TherapistSummary
    @State private var selectedMode: SessionMode = .video
    @State private var selectedDayID: String?
    @State private var selectedTimeID: String?
    @State private var bookingTab: BookingTab = .private

    enum BookingTab { case `private`, group }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                // Therapist header
                HStack(spacing: MindscapeSpacing.medium) {
                    Text(therapist.initials)
                        .font(.headline.bold())
                        .frame(width: 52, height: 52)
                        .background(BrandPalette.primaryLight)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(therapist.fullName)
                            .font(.headline)
                        Text(therapist.credentials)
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.textSecondary)
                    }
                }

                // Private / Group picker
                let hasGroupSessions = !appState.bookingContextState.groupSessions.isEmpty
                if !appState.bookingContextState.isLoading && hasGroupSessions {
                    Picker("Booking type", selection: $bookingTab) {
                        Text("Private").tag(BookingTab.private)
                        Text("Group").tag(BookingTab.group)
                    }
                    .pickerStyle(.segmented)
                }

                if bookingTab == .private {
                    privateSectionView
                } else {
                    groupSectionView
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
        .navigationTitle("Book session")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: therapist.id) {
            await appState.loadBookingContext(for: therapist)
            selectFirstAvailableOptionsIfNeeded()
        }
        .onChange(of: appState.bookingContextState.availabilityDays) { _, _ in
            selectFirstAvailableOptionsIfNeeded()
        }
        .onChange(of: selectedDayID) { _, newValue in
            guard let newValue else {
                selectedTimeID = nil
                return
            }
            let firstSlotID = appState.bookingContextState.availabilityDays
                .first(where: { $0.id == newValue })?
                .slots.first?.id

            if firstSlotID != selectedTimeID {
                selectedTimeID = firstSlotID
            }
        }
    }

    // MARK: - Private session section

    @ViewBuilder
    private var privateSectionView: some View {
        // Session mode picker
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Text("Session mode")
                .font(.headline)

            ForEach(therapist.sessionModes, id: \.self) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.label)
                                .foregroundStyle(BrandPalette.textPrimary)
                            Text(mode == .video ? "Face-to-face guided support" : "Low-pressure voice only session")
                                .font(.subheadline)
                                .foregroundStyle(BrandPalette.textSecondary)
                        }
                        Spacer()
                        Image(systemName: selectedMode == mode ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedMode == mode ? BrandPalette.primary : BrandPalette.outline)
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
        }

        // Availability calendar
        availabilityContent

        // Price summary
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Text("Summary")
                .font(.headline)
            Text(therapist.priceLabel)
            Text("\(therapist.sessionDurationMinutes)-minute \(selectedMode.label.lowercased()) session")
                .foregroundStyle(BrandPalette.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))

        feedbackBanners

        // Book button
        Button {
            guard let selectedTimeID else { return }
            guard appState.isAuthenticated else {
                appState.loginPrompt = LoginPrompt(
                    title: "Sign in to book",
                    subtitle: "Create an account or sign in to reserve a session."
                )
                return
            }
            Task {
                _ = await appState.createBookingDraft(
                    therapistId: therapist.id,
                    availabilitySlotId: selectedTimeID,
                    sessionMode: selectedMode
                )
            }
        } label: {
            Group {
                if appState.bookingContextState.isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Reserve session")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedTimeID != nil ? BrandPalette.primary : BrandPalette.outline)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .disabled(selectedTimeID == nil || appState.bookingContextState.isSubmitting)
    }

    // MARK: - Group session section

    @ViewBuilder
    private var groupSectionView: some View {
        if appState.bookingContextState.isLoading {
            ProgressView("Loading group sessions...")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, MindscapeSpacing.medium)
        } else if appState.bookingContextState.groupSessions.isEmpty {
            BookingCard(title: "No group sessions", message: "This therapist has no upcoming group sessions.")
        } else {
            VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                Text("Upcoming group sessions")
                    .font(.headline)

                ForEach(appState.bookingContextState.groupSessions) { session in
                    GroupSessionCard(
                        session: session,
                        isSubmitting: appState.bookingContextState.isSubmitting
                    ) {
                        guard appState.isAuthenticated else {
                            appState.loginPrompt = LoginPrompt(
                                title: "Sign in to join",
                                subtitle: "Create an account or sign in to join a group session."
                            )
                            return
                        }
                        Task {
                            _ = await appState.createGroupBookingDraft(groupSessionId: session.id)
                        }
                    }
                }
            }

            feedbackBanners
        }
    }

    // MARK: - Availability picker

    @ViewBuilder
    private var availabilityContent: some View {
        if appState.bookingContextState.isLoading {
            ProgressView("Loading availability...")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, MindscapeSpacing.medium)
        } else if let errorMessage = appState.bookingContextState.errorMessage {
            BookingCard(
                title: "Availability unavailable",
                message: errorMessage,
                actionTitle: "Try again"
            ) {
                Task {
                    await appState.loadBookingContext(for: therapist)
                    selectFirstAvailableOptionsIfNeeded()
                }
            }
        } else if appState.bookingContextState.availabilityDays.isEmpty {
            BookingCard(title: "No open slots", message: "This therapist has no available slots right now.")
        } else {
            bookingPicker(
                title: "Pick a day",
                options: appState.bookingContextState.availabilityDays.map {
                    (id: $0.id, title: "\($0.dayLabel), \($0.dateLabel)")
                },
                selection: $selectedDayID
            )

            bookingPicker(
                title: "Pick a time",
                options: selectedDayOptions.map {
                    (id: $0.id, title: $0.timeLabel + ($0.isPopular ? " • Popular" : ""))
                },
                selection: $selectedTimeID
            )
        }
    }

    @ViewBuilder
    private var feedbackBanners: some View {
        if let statusMessage = appState.bookingContextState.submissionStatusMessage {
            MindscapeBanner(message: statusMessage, style: .success)
        }
        if let errorMessage = appState.bookingContextState.submissionErrorMessage {
            MindscapeBanner(message: errorMessage, style: .error)
        }
    }

    private var selectedDayOptions: [BookingTimeOption] {
        guard let selectedDayID else {
            return appState.bookingContextState.availabilityDays.first?.slots ?? []
        }
        return appState.bookingContextState.availabilityDays.first(where: { $0.id == selectedDayID })?.slots ?? []
    }

    private func bookingPicker(title: String, options: [(id: String, title: String)], selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Text(title).font(.headline)

            ForEach(options, id: \.id) { option in
                Button {
                    selection.wrappedValue = option.id
                } label: {
                    HStack {
                        Text(option.title).foregroundStyle(BrandPalette.textPrimary)
                        Spacer()
                        Image(systemName: selection.wrappedValue == option.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selection.wrappedValue == option.id ? BrandPalette.primary : BrandPalette.outline)
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func selectFirstAvailableOptionsIfNeeded() {
        guard !appState.bookingContextState.availabilityDays.isEmpty else {
            selectedDayID = nil
            selectedTimeID = nil
            return
        }
        if !appState.bookingContextState.availabilityDays.contains(where: { $0.id == selectedDayID }) {
            selectedDayID = appState.bookingContextState.availabilityDays.first?.id
        }
        if !selectedDayOptions.contains(where: { $0.id == selectedTimeID }) {
            selectedTimeID = selectedDayOptions.first?.id
        }
    }
}

// MARK: - Group Session Card

private struct GroupSessionCard: View {
    let session: TherapistGroupSession
    let isSubmitting: Bool
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Text(session.title)
                .font(.headline)

            Text(session.description)
                .font(.subheadline)
                .foregroundStyle(BrandPalette.textSecondary)

            HStack {
                Label("\(session.dayLabel), \(session.dateLabel) at \(session.timeLabel)", systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(BrandPalette.textSecondary)
                Spacer()
                Label("\(session.maxParticipants) max", systemImage: "person.2")
                    .font(.caption)
                    .foregroundStyle(BrandPalette.textSecondary)
            }

            Button(action: onJoin) {
                Group {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Join group session")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(BrandPalette.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(isSubmitting)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(BrandPalette.outline, lineWidth: 1))
    }
}

// MARK: - Booking Card

private struct BookingCard: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Text(title).font(.headline)
            Text(message).foregroundStyle(BrandPalette.textSecondary)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(BrandPalette.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
