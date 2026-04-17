import SwiftUI

struct HomeView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                // Hero card
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    if let name = appState.authState.session?.fullName?.split(separator: " ").first.map(String.init) {
                        Text("Hello, \(name)")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(BrandPalette.primaryDeep)
                    }

                    Text(appState.homeSnapshot.journeyHeadline)
                        .font(.largeTitle.bold())
                        .foregroundStyle(BrandPalette.textPrimary)

                    Text(appState.homeSnapshot.journeySupport)
                        .foregroundStyle(BrandPalette.textSecondary)

                    Text("\"\(appState.homeSnapshot.quote)\"")
                        .font(.callout)
                        .italic()
                        .foregroundStyle(BrandPalette.primaryDeep)
                        .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BrandPalette.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Quick actions
                HStack(spacing: MindscapeSpacing.medium) {
                    QuickActionButton(
                        title: "Book session",
                        icon: "plus.circle.fill",
                        color: BrandPalette.primary
                    ) {
                        appState.selectedTab = .booking
                    }

                    QuickActionButton(
                        title: "Your Space",
                        icon: "heart.text.square.fill",
                        color: BrandPalette.primaryDeep
                    ) {
                        appState.selectedTab = .yourSpace
                    }
                }

                // Upcoming appointment nudge
                if appState.isAuthenticated,
                   let next = appState.bookingState.upcomingAppointments.first(where: { $0.status == .confirmed }) {
                    Button {
                        appState.selectedTab = .appointments
                        appState.navigationPath.append(.sessionDetail(bookingId: next.id))
                    } label: {
                        HStack(spacing: MindscapeSpacing.medium) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundStyle(BrandPalette.primary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Upcoming session")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BrandPalette.textPrimary)
                                Text("\(next.therapistName) · \(next.dateLabel) at \(next.timeLabel)")
                                    .font(.subheadline)
                                    .foregroundStyle(BrandPalette.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(BrandPalette.outline)
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(BrandPalette.outline, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                // Concerns
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Browse by concern")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: MindscapeSpacing.small) {
                            ForEach(appState.concerns) { concern in
                                Text(concern.label)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(BrandPalette.surface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(BrandPalette.outline, lineWidth: 1))
                            }
                        }
                    }
                }

                // Therapist list
                VStack(alignment: .leading, spacing: MindscapeSpacing.medium) {
                    Text("Find your therapist")
                        .font(.title2.bold())

                    if appState.discoveryState.isLoading {
                        ProgressView("Loading therapists...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, MindscapeSpacing.medium)
                    } else if let errorMessage = appState.discoveryState.errorMessage {
                        HomeMessageCard(
                            title: "Therapists are unavailable",
                            message: errorMessage,
                            actionTitle: "Try again"
                        ) {
                            Task { await appState.reloadDiscovery() }
                        }
                    } else if appState.discoveryState.therapists.isEmpty {
                        HomeMessageCard(
                            title: "No therapists yet",
                            message: "New therapist profiles will appear here once the catalog is ready."
                        )
                    } else {
                        ForEach(appState.discoveryState.therapists) { therapist in
                            NavigationLink {
                                TherapistDetailView(appState: appState, therapist: therapist)
                            } label: {
                                TherapistCardView(therapist: therapist)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
        .navigationTitle("Mindscape")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !appState.isAuthenticated {
                    Button("Sign in") {
                        appState.loginPrompt = LoginPrompt(
                            title: "Welcome to Mindscape",
                            subtitle: "Sign in to book sessions and track your progress."
                        )
                    }
                    .foregroundStyle(BrandPalette.primaryDeep)
                }
            }
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(BrandPalette.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(BrandPalette.outline, lineWidth: 1))
        }
    }
}

private struct TherapistCardView: View {
    let therapist: TherapistSummary

    var body: some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(therapist.fullName)
                        .font(.headline)
                        .foregroundStyle(BrandPalette.textPrimary)
                    Text(therapist.credentials)
                        .foregroundStyle(BrandPalette.textSecondary)
                }
                Spacer()
                Text(therapist.initials)
                    .font(.headline.bold())
                    .frame(width: 48, height: 48)
                    .background(BrandPalette.primaryLight)
                    .clipShape(Circle())
            }

            Text(therapist.specialization)
                .foregroundStyle(BrandPalette.textPrimary)

            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(BrandPalette.accent)
                    Text(String(format: "%.1f", therapist.rating))
                        .font(.subheadline.weight(.medium))
                }
                Text("•")
                    .foregroundStyle(BrandPalette.outline)
                Text(therapist.priceLabel)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(therapist.availabilityLabel)
                    .font(.subheadline)
                    .foregroundStyle(therapist.isAvailableNow ? BrandPalette.success : BrandPalette.textSecondary)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(BrandPalette.outline, lineWidth: 1))
    }
}

private struct HomeMessageCard: View {
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
            Text(title).font(.headline).foregroundStyle(BrandPalette.textPrimary)
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
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(BrandPalette.outline, lineWidth: 1))
    }
}
