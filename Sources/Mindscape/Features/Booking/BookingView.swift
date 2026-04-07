import SwiftUI

struct BookingView: View {
    let therapist: TherapistSummary
    @State private var selectedMode: SessionMode = .video
    @State private var selectedDateID = MindscapeSampleData.bookingDates.first?.id
    @State private var selectedTimeID = MindscapeSampleData.bookingTimes.first?.id

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                Text("Book with \(therapist.fullName)")
                    .font(.title2.bold())

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

                bookingPicker(title: "Pick a day", options: MindscapeSampleData.bookingDates.map { (id: $0.id, title: "\($0.dayLabel), \($0.dateLabel)") }, selection: $selectedDateID)
                bookingPicker(title: "Pick a time", options: MindscapeSampleData.bookingTimes.map { (id: $0.id, title: $0.timeLabel + ($0.isPopular ? " • Popular" : "")) }, selection: $selectedTimeID)

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

                NavigationLink {
                    SessionPlaceholderView()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandPalette.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
        .navigationTitle("Booking")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bookingPicker(title: String, options: [(id: String, title: String)], selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Text(title)
                .font(.headline)

            ForEach(options, id: \.id) { option in
                Button {
                    selection.wrappedValue = option.id
                } label: {
                    HStack {
                        Text(option.title)
                            .foregroundStyle(BrandPalette.textPrimary)
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
}
