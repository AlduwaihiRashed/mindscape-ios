import SwiftUI

struct AppointmentsView: View {
    @ObservedObject var appState: MindscapeAppState
    @State private var cancelTarget: AppointmentSummary?

    var body: some View {
        Group {
            if appState.bookingState.isLoading {
                ProgressView("Loading appointments...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(BrandPalette.background)
            } else if !appState.isAuthenticated {
                ContentUnavailableView(
                    "Sign in to view appointments",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Booking history and upcoming sessions appear here after you sign in.")
                )
                .background(BrandPalette.background)
                .safeAreaInset(edge: .bottom) {
                    Button {
                        appState.loginPrompt = LoginPrompt(
                            title: "Sign in to Mindscape",
                            subtitle: "View your bookings and upcoming sessions."
                        )
                    } label: {
                        Text("Sign in")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(BrandPalette.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding()
                }
            } else if let errorMessage = appState.bookingState.errorMessage {
                ContentUnavailableView(
                    "Appointments unavailable",
                    systemImage: "exclamationmark.circle",
                    description: Text(errorMessage)
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Retry") {
                            Task { await appState.reloadBookings() }
                        }
                    }
                }
                .background(BrandPalette.background)
            } else {
                appointmentsList
            }
        }
        .navigationTitle("Appointments")
        .refreshable {
            await appState.reloadBookings()
        }
        .alert("Cancel appointment?", isPresented: Binding(
            get: { cancelTarget != nil },
            set: { if !$0 { cancelTarget = nil } }
        )) {
            if let target = cancelTarget {
                Button("Cancel appointment", role: .destructive) {
                    Task {
                        _ = await appState.cancelBooking(bookingId: target.id, reason: nil)
                        cancelTarget = nil
                    }
                }
            }
            Button("Keep it", role: .cancel) { cancelTarget = nil }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var appointmentsList: some View {
        List {
            Section("Upcoming") {
                if appState.bookingState.upcomingAppointments.isEmpty {
                    Text("No upcoming appointments yet.")
                        .foregroundStyle(BrandPalette.textSecondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(appState.bookingState.upcomingAppointments) { appointment in
                        appointmentRow(appointment)
                    }
                }
            }

            Section("Past") {
                if appState.bookingState.pastAppointments.isEmpty {
                    Text("No past appointments yet.")
                        .foregroundStyle(BrandPalette.textSecondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(appState.bookingState.pastAppointments) { appointment in
                        appointmentRow(appointment)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(BrandPalette.background)
    }

    @ViewBuilder
    private func appointmentRow(_ appointment: AppointmentSummary) -> some View {
        Button {
            navigateToAppointment(appointment)
        } label: {
            AppointmentRow(appointment: appointment) {
                cancelTarget = appointment
            }
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func navigateToAppointment(_ appointment: AppointmentSummary) {
        switch appointment.status {
        case .pendingPayment, .paymentFailed:
            appState.navigationPath.append(.checkout(bookingId: appointment.id))
        case .confirmed:
            appState.navigationPath.append(.sessionDetail(bookingId: appointment.id))
        case .completed, .canceled, .expired:
            // Rebook: switch to book tab
            appState.selectedTab = .booking
        }
    }
}

private struct AppointmentRow: View {
    let appointment: AppointmentSummary
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            HStack {
                Text(appointment.therapistInitials)
                    .font(.subheadline.bold())
                    .frame(width: 44, height: 44)
                    .background(BrandPalette.primaryLight)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(appointment.therapistName)
                        .font(.headline)
                        .foregroundStyle(BrandPalette.textPrimary)

                    if let groupTitle = appointment.groupSessionTitle {
                        Text(groupTitle)
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.primaryDeep)
                    } else {
                        Text(appointment.focusArea)
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(BrandPalette.outline)
            }

            HStack {
                Label("\(appointment.dateLabel) at \(appointment.timeLabel)", systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(BrandPalette.textSecondary)
                Spacer()
            }

            HStack(spacing: MindscapeSpacing.small) {
                statusBadge(for: appointment.status)

                if !appointment.priceLabel.isEmpty {
                    Text(appointment.priceLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BrandPalette.textSecondary)
                }

                if appointment.isGroupSession {
                    Text("Group")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(BrandPalette.accent)
                        .foregroundStyle(BrandPalette.accentDeep)
                        .clipShape(Capsule())
                }

                Spacer()

                if appointment.canCancel {
                    Button("Cancel", role: .destructive, action: onCancel)
                        .font(.caption)
                        .buttonStyle(.plain)
                        .foregroundStyle(BrandPalette.error)
                }
            }

            if let expiresLabel = appointment.holdExpiresAtLabel {
                Label(expiresLabel, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(BrandPalette.error)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(BrandPalette.outline, lineWidth: 1))
    }

    private func statusBadge(for status: BookingStatus) -> some View {
        Text(status.label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusBackground(for: status))
            .foregroundStyle(statusForeground(for: status))
            .clipShape(Capsule())
    }

    private func statusBackground(for status: BookingStatus) -> Color {
        switch status {
        case .confirmed: return BrandPalette.primaryLight
        case .pendingPayment: return BrandPalette.accent.opacity(0.4)
        case .completed: return Color.gray.opacity(0.15)
        case .canceled, .expired, .paymentFailed: return BrandPalette.error.opacity(0.1)
        }
    }

    private func statusForeground(for status: BookingStatus) -> Color {
        switch status {
        case .confirmed: return BrandPalette.primaryDeep
        case .pendingPayment: return BrandPalette.accentDeep
        case .completed: return BrandPalette.textSecondary
        case .canceled, .expired, .paymentFailed: return BrandPalette.error
        }
    }
}
