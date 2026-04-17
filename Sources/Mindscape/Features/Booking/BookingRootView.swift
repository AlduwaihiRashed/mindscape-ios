import SwiftUI

// The Book tab root: shows a therapist picker so users can start a booking without going to Home first.

struct BookingRootView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Book a session")
                        .font(.largeTitle.bold())
                    Text("Choose a therapist to see their availability.")
                        .foregroundStyle(BrandPalette.textSecondary)
                }

                if appState.discoveryState.isLoading {
                    ProgressView("Loading therapists...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, MindscapeSpacing.medium)
                } else if let errorMessage = appState.discoveryState.errorMessage {
                    BookingInfoCard(
                        title: "Therapists unavailable",
                        message: errorMessage,
                        actionTitle: "Retry"
                    ) {
                        Task { await appState.reloadDiscovery() }
                    }
                } else {
                    ForEach(appState.discoveryState.therapists) { therapist in
                        NavigationLink {
                            BookingView(appState: appState, therapist: therapist)
                        } label: {
                            BookingTherapistCard(therapist: therapist)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
        .navigationTitle("Book")
    }
}

private struct BookingTherapistCard: View {
    let therapist: TherapistSummary

    var body: some View {
        HStack(spacing: MindscapeSpacing.medium) {
            Text(therapist.initials)
                .font(.headline.bold())
                .frame(width: 52, height: 52)
                .background(BrandPalette.primaryLight)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(therapist.fullName)
                    .font(.headline)
                    .foregroundStyle(BrandPalette.textPrimary)
                Text(therapist.credentials)
                    .font(.subheadline)
                    .foregroundStyle(BrandPalette.textSecondary)
                Text(therapist.priceLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(BrandPalette.primaryDeep)
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
}

private struct BookingInfoCard: View {
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
