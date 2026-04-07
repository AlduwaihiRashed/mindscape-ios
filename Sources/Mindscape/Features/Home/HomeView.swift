import SwiftUI

struct HomeView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text(appState.homeSnapshot.journeyHeadline)
                        .font(.largeTitle.bold())
                        .foregroundStyle(BrandPalette.textPrimary)

                    Text(appState.homeSnapshot.journeySupport)
                        .foregroundStyle(BrandPalette.textSecondary)

                    Text("\"\(appState.homeSnapshot.quote)\"")
                        .font(.callout)
                        .foregroundStyle(BrandPalette.primaryDeep)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BrandPalette.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Popular concerns")
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

                VStack(alignment: .leading, spacing: MindscapeSpacing.medium) {
                    Text("Find your therapist")
                        .font(.title2.bold())

                    ForEach(appState.therapists) { therapist in
                        NavigationLink {
                            TherapistDetailView(therapist: therapist)
                        } label: {
                            TherapistCardView(therapist: therapist)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
        .navigationTitle("Mindscape")
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
                Text(therapist.priceLabel)
                Spacer()
                Text(therapist.availabilityLabel)
                    .foregroundStyle(therapist.isAvailableNow ? BrandPalette.success : BrandPalette.textSecondary)
            }
            .font(.subheadline.weight(.medium))
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(BrandPalette.outline, lineWidth: 1))
    }
}
