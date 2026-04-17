import SwiftUI

struct SessionDetailView: View {
    @ObservedObject var appState: MindscapeAppState
    let bookingId: String
    @State private var showCancelAlert = false

    var body: some View {
        Group {
            if appState.sessionState.isLoading {
                ProgressView("Loading session...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BrandPalette.background)
            } else if let errorMessage = appState.sessionState.errorMessage {
                ContentUnavailableView(
                    "Session unavailable",
                    systemImage: "exclamationmark.circle",
                    description: Text(errorMessage)
                )
                .background(BrandPalette.background)
            } else if let details = appState.sessionState.details {
                sessionContent(details: details)
            } else {
                ContentUnavailableView("Session not found", systemImage: "doc.badge.questionmark")
                    .background(BrandPalette.background)
            }
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await appState.loadSession(bookingId: bookingId)
        }
        .alert("Cancel session?", isPresented: $showCancelAlert) {
            Button("Cancel session", role: .destructive) {
                Task {
                    let success = await appState.cancelBooking(bookingId: bookingId, reason: nil)
                    if success {
                        appState.navigationPath.removeLast()
                    }
                }
            }
            Button("Keep it", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    @ViewBuilder
    private func sessionContent(details: SessionDetails) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                // Header
                HStack(spacing: MindscapeSpacing.medium) {
                    Text(details.therapistInitials)
                        .font(.title2.bold())
                        .frame(width: 64, height: 64)
                        .background(BrandPalette.primaryLight)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(details.therapistName)
                            .font(.headline)
                        if let title = details.groupSessionTitle {
                            Text(title)
                                .font(.subheadline)
                                .foregroundStyle(BrandPalette.primaryDeep)
                        }
                        Text(details.bookingStatus)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(statusColor(for: details.bookingStatusCode))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Details
                VStack(spacing: 0) {
                    sessionRow(label: "Date", value: details.dateLabel)
                    Divider().padding(.horizontal)
                    sessionRow(label: "Time", value: details.timeLabel)
                    Divider().padding(.horizontal)
                    sessionRow(label: "Mode", value: details.sessionMode.capitalized)
                    if !details.priceLabel.isEmpty {
                        Divider().padding(.horizontal)
                        sessionRow(label: "Price", value: details.priceLabel)
                    }
                    if let paymentStatus = details.paymentStatus {
                        Divider().padding(.horizontal)
                        sessionRow(label: "Payment", value: paymentStatus)
                    }
                    if let sessionStatus = details.sessionStatus {
                        Divider().padding(.horizontal)
                        sessionRow(label: "Session", value: sessionStatus)
                    }
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Join window
                if let joinFromLabel = details.joinAllowedFromLabel {
                    HStack(spacing: MindscapeSpacing.small) {
                        Image(systemName: "clock")
                            .foregroundStyle(BrandPalette.primaryDeep)
                        Text("Joinable from \(joinFromLabel)")
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.primaryDeep)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BrandPalette.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Hold expiry
                if let expiresLabel = details.holdExpiresAtLabel {
                    HStack(spacing: MindscapeSpacing.small) {
                        Image(systemName: "clock")
                            .foregroundStyle(BrandPalette.error)
                        Text(expiresLabel)
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.error)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BrandPalette.error.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Actions
                VStack(spacing: MindscapeSpacing.small) {
                    if details.canJoinNow {
                        Button {
                            Task {
                                await appState.prepareJoin(bookingId: bookingId)
                            }
                        } label: {
                            Group {
                                if appState.liveSessionState.isConnecting {
                                    ProgressView().tint(.white)
                                } else {
                                    Label("Join session now", systemImage: "video.fill")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(BrandPalette.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .disabled(appState.liveSessionState.isConnecting)
                    }

                    if details.canRetryPayment {
                        NavigationLink(value: MindscapeDestination.checkout(bookingId: bookingId)) {
                            Text("Complete payment")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(BrandPalette.primaryDeep)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }

                    if details.bookingStatusCode == "confirmed" {
                        Button(role: .destructive) {
                            showCancelAlert = true
                        } label: {
                            Text("Cancel session")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(BrandPalette.error, lineWidth: 1))
                        }
                        .foregroundStyle(BrandPalette.error)
                    }
                }

                if let error = appState.liveSessionState.errorMessage {
                    MindscapeBanner(message: error, style: .error)
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
        .refreshable {
            await appState.loadSession(bookingId: bookingId)
        }
    }

    private func sessionRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(BrandPalette.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(BrandPalette.textPrimary)
                .fontWeight(.medium)
        }
        .padding()
    }

    private func statusColor(for statusCode: String) -> Color {
        switch statusCode {
        case "confirmed": return BrandPalette.success
        case "canceled", "expired", "payment_failed": return BrandPalette.error
        case "completed": return BrandPalette.textSecondary
        default: return BrandPalette.primaryDeep
        }
    }
}
