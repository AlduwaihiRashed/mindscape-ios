import SwiftUI

struct CheckoutView: View {
    @ObservedObject var appState: MindscapeAppState
    let bookingId: String

    var body: some View {
        Group {
            if appState.checkoutState.isLoading {
                ProgressView("Loading booking...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BrandPalette.background)
            } else if let errorMessage = appState.checkoutState.errorMessage {
                ContentUnavailableView(
                    "Unable to load booking",
                    systemImage: "exclamationmark.circle",
                    description: Text(errorMessage)
                )
                .background(BrandPalette.background)
            } else if let appointment = appState.checkoutState.appointment {
                checkoutContent(appointment: appointment)
            } else {
                ContentUnavailableView("Booking not found", systemImage: "doc.badge.questionmark")
                    .background(BrandPalette.background)
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await appState.loadCheckout(bookingId: bookingId)
        }
        .sheet(item: Binding(
            get: { appState.checkoutState.pendingPaymentLaunch },
            set: { _ in }
        )) { launch in
            PaymentWebView(
                appState: appState,
                launch: launch,
                bookingId: bookingId
            )
        }
    }

    @ViewBuilder
    private func checkoutContent(appointment: AppointmentSummary) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                // Therapist header
                HStack(spacing: MindscapeSpacing.medium) {
                    Text(appointment.therapistInitials)
                        .font(.title2.bold())
                        .frame(width: 64, height: 64)
                        .background(BrandPalette.primaryLight)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.therapistName)
                            .font(.headline)
                        if let title = appointment.groupSessionTitle {
                            Text(title)
                                .font(.subheadline)
                                .foregroundStyle(BrandPalette.primaryDeep)
                        } else {
                            Text(appointment.focusArea)
                                .font(.subheadline)
                                .foregroundStyle(BrandPalette.textSecondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Session details
                VStack(spacing: 0) {
                    checkoutRow(label: "Date", value: appointment.dateLabel)
                    Divider().padding(.horizontal)
                    checkoutRow(label: "Time", value: appointment.timeLabel)
                    Divider().padding(.horizontal)
                    checkoutRow(label: "Mode", value: appointment.mode.label)
                    if !appointment.priceLabel.isEmpty {
                        Divider().padding(.horizontal)
                        checkoutRow(label: "Price", value: appointment.priceLabel)
                    }
                    if appointment.isGroupSession {
                        Divider().padding(.horizontal)
                        checkoutRow(label: "Type", value: "Group session")
                    }
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Hold expiry warning
                if let expiresLabel = appointment.holdExpiresAtLabel {
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

                // Status banners
                if let statusMessage = appState.checkoutState.statusMessage {
                    MindscapeBanner(message: statusMessage, style: .success)
                }

                if let errorMessage = appState.checkoutState.errorMessage {
                    MindscapeBanner(message: errorMessage, style: .error)
                }

                // Actions
                if appointment.status == .confirmed {
                    VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title)
                            .foregroundStyle(BrandPalette.success)
                        Text("Payment confirmed")
                            .font(.headline)
                        Text("Your session is booked and confirmed.")
                            .foregroundStyle(BrandPalette.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BrandPalette.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Button {
                        appState.navigationPath.removeLast()
                        appState.navigationPath.append(.sessionDetail(bookingId: bookingId))
                    } label: {
                        Text("View session details")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(BrandPalette.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                } else if appointment.status == .pendingPayment || appointment.status == .paymentFailed {
                    Button {
                        Task {
                            await appState.startPayment(bookingId: bookingId)
                        }
                    } label: {
                        Group {
                            if appState.checkoutState.isStartingPayment {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Pay \(appointment.priceLabel.isEmpty ? "now" : appointment.priceLabel)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandPalette.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(appState.checkoutState.isStartingPayment || appState.checkoutState.isVerifyingPayment)
                } else {
                    Text("Status: \(appointment.status.label)")
                        .foregroundStyle(BrandPalette.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                // Refresh button
                Button {
                    Task {
                        await appState.loadCheckout(bookingId: bookingId)
                    }
                } label: {
                    Text("Refresh status")
                        .font(.subheadline)
                        .foregroundStyle(BrandPalette.primaryDeep)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
    }

    private func checkoutRow(label: String, value: String) -> some View {
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
}

// MARK: - Payment Web View placeholder

struct PaymentWebView: View {
    @ObservedObject var appState: MindscapeAppState
    let launch: PaymentLaunch
    let bookingId: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: MindscapeSpacing.large) {
                Image(systemName: "creditcard")
                    .font(.system(size: 56))
                    .foregroundStyle(BrandPalette.primary)

                Text("Payment")
                    .font(.title2.bold())

                Text("Opening \(launch.provider.capitalized) payment page...")
                    .foregroundStyle(BrandPalette.textSecondary)
                    .multilineTextAlignment(.center)

                if appState.checkoutState.isVerifyingPayment {
                    ProgressView("Verifying payment...")
                } else {
                    Button {
                        // In production: open launch.redirectUrl in ASWebAuthenticationSession or SFSafariViewController
                        // For now, simulate payment verification
                        Task {
                            await appState.verifyPayment(bookingId: bookingId, paymentId: launch.paymentId)
                            if appState.checkoutState.statusMessage != nil {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Simulate payment success")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(BrandPalette.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal)
                }

                if let error = appState.checkoutState.errorMessage {
                    MindscapeBanner(message: error, style: .error)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

extension PaymentLaunch: Identifiable {
    public var id: String { paymentId }
}
