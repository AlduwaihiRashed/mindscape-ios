import SwiftUI

struct TherapistDetailView: View {
    let therapist: TherapistSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text(therapist.fullName)
                        .font(.largeTitle.bold())
                    Text(therapist.credentials)
                        .foregroundStyle(BrandPalette.textSecondary)
                    Text(therapist.bio)
                        .foregroundStyle(BrandPalette.textPrimary)
                }

                detailSection(title: "Specialization", values: therapist.specializationTags)
                detailSection(title: "Languages", values: therapist.languages)
                detailSection(title: "Session modes", values: therapist.sessionModes.map(\.label))

                NavigationLink {
                    BookingView(therapist: therapist)
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
