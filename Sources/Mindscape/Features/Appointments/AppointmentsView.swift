import SwiftUI

struct AppointmentsView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        List {
            Section("Upcoming") {
                ForEach(appState.upcomingAppointments) { appointment in
                    AppointmentRow(appointment: appointment)
                }
            }

            Section("Past") {
                ForEach(appState.pastAppointments) { appointment in
                    AppointmentRow(appointment: appointment)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(BrandPalette.background)
        .navigationTitle("Appointments")
    }
}

private struct AppointmentRow: View {
    let appointment: AppointmentSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(appointment.therapistName)
                .font(.headline)
            Text(appointment.focusArea)
                .foregroundStyle(BrandPalette.textSecondary)
            Text("\(appointment.dateLabel) at \(appointment.timeLabel)")
                .font(.subheadline)
            Text("\(appointment.status.label) • \(appointment.mode.label)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(BrandPalette.primaryDeep)
        }
        .padding(.vertical, 4)
    }
}
