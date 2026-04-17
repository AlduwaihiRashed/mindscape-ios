import SwiftUI

struct TherapistDetailView: View {
    @ObservedObject var appState: MindscapeAppState
    let therapist: TherapistSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                // Header card
                VStack(alignment: .leading, spacing: MindscapeSpacing.medium) {
                    HStack(alignment: .top, spacing: MindscapeSpacing.medium) {
                        Text(therapist.initials)
                            .font(.title.bold())
                            .frame(width: 80, height: 80)
                            .background(BrandPalette.primaryLight)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 6) {
                            Text(therapist.fullName)
                                .font(.title2.bold())
                                .foregroundStyle(BrandPalette.textPrimary)
                            Text(therapist.credentials)
                                .font(.subheadline)
                                .foregroundStyle(BrandPalette.textSecondary)

                            HStack(spacing: MindscapeSpacing.medium) {
                                ratingView
                                Text("•")
                                    .foregroundStyle(BrandPalette.outline)
                                Text("\(therapist.sessionsCompleted) sessions")
                                    .font(.subheadline)
                                    .foregroundStyle(BrandPalette.textSecondary)
                            }

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(therapist.isAvailableNow ? BrandPalette.success : BrandPalette.outline)
                                    .frame(width: 8, height: 8)
                                Text(therapist.availabilityLabel)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(therapist.isAvailableNow ? BrandPalette.success : BrandPalette.textSecondary)
                            }
                        }
                    }

                    Text(therapist.bio)
                        .foregroundStyle(BrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Tags
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Focus areas")
                        .font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], alignment: .leading, spacing: 8) {
                        ForEach(therapist.specializationTags, id: \.self) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(BrandPalette.surface)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(BrandPalette.outline, lineWidth: 1))
                        }
                    }
                }

                detailSection(title: "Languages", values: therapist.languages)
                detailSection(title: "Session modes", values: therapist.sessionModes.map(\.label))

                // Price
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(therapist.priceLabel)
                            .font(.headline)
                            .foregroundStyle(BrandPalette.primaryDeep)
                        Text("\(therapist.sessionDurationMinutes)-minute session")
                            .font(.subheadline)
                            .foregroundStyle(BrandPalette.textSecondary)
                    }
                    Spacer()
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                NavigationLink {
                    BookingView(appState: appState, therapist: therapist)
                } label: {
                    Text("Book now")
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
        .navigationTitle("Therapist")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var ratingView: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .foregroundStyle(BrandPalette.accent)
                .font(.caption)
            Text(String(format: "%.1f", therapist.rating))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BrandPalette.textPrimary)
        }
    }

    private func detailSection(title: String, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Text(title)
                .font(.headline)
            Text(values.joined(separator: " • "))
                .foregroundStyle(BrandPalette.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
