import SwiftUI

struct YourSpaceView: View {
    @ObservedObject var appState: MindscapeAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindscapeSpacing.large) {
                // Header
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Your Space")
                        .font(.largeTitle.bold())
                        .foregroundStyle(BrandPalette.textPrimary)
                    Text("A gentle corner for reflection and growth.")
                        .foregroundStyle(BrandPalette.textSecondary)
                }

                // Daily quote
                if let quote = appState.quotes.first {
                    QuoteCardView(quote: quote)
                } else if appState.quotes.isEmpty {
                    QuoteCardView(quote: MindscapeSampleData.quotes[0])
                }

                // Quotes carousel if more than one
                if appState.quotes.count > 1 {
                    VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                        Text("Reflections")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MindscapeSpacing.medium) {
                                ForEach(appState.quotes.dropFirst()) { quote in
                                    QuoteCardView(quote: quote)
                                        .frame(width: 280)
                                }
                            }
                        }
                    }
                }

                // Journey metrics
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Your journey")
                        .font(.headline)

                    VStack(spacing: MindscapeSpacing.small) {
                        ForEach(MindscapeSampleData.journeyMetrics, id: \.label) { metric in
                            JourneyMetricRow(metric: metric)
                        }
                    }
                }

                // Book a session CTA
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Keep building momentum")
                        .font(.headline)
                    Text("Your next session is an investment in yourself.")
                        .foregroundStyle(BrandPalette.textSecondary)

                    Button {
                        appState.selectedTab = .booking
                    } label: {
                        Label("Book a session", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(BrandPalette.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // Reflection prompts
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Reflection prompts")
                        .font(.headline)

                    ForEach(MindscapeSampleData.reflectionPrompts) { prompt in
                        HStack(alignment: .top, spacing: MindscapeSpacing.small) {
                            Image(systemName: "quote.bubble")
                                .foregroundStyle(BrandPalette.primary)
                                .frame(width: 24)
                            Text(prompt.prompt)
                                .foregroundStyle(BrandPalette.textPrimary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                // Session insights
                VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
                    Text("Insights")
                        .font(.headline)

                    ForEach(MindscapeSampleData.sessionInsights, id: \.title) { insight in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(insight.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BrandPalette.primaryDeep)
                            Text(insight.summary)
                                .foregroundStyle(BrandPalette.textPrimary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(MindscapeSpacing.medium)
        }
        .background(BrandPalette.background.ignoresSafeArea())
        .navigationTitle("Your Space")
    }
}

private struct QuoteCardView: View {
    let quote: QuoteCard

    var body: some View {
        VStack(alignment: .leading, spacing: MindscapeSpacing.small) {
            Image(systemName: "quote.opening")
                .font(.title)
                .foregroundStyle(BrandPalette.primary.opacity(0.4))

            Text(quote.text)
                .font(.body)
                .italic()
                .foregroundStyle(BrandPalette.textPrimary)

            if let author = quote.author {
                Text("— \(author)")
                    .font(.subheadline)
                    .foregroundStyle(BrandPalette.textSecondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandPalette.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct JourneyMetricRow: View {
    let metric: JourneyMetric

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(metric.label)
                    .font(.subheadline)
                    .foregroundStyle(BrandPalette.textSecondary)
                Text(metric.supportText)
                    .font(.caption)
                    .foregroundStyle(BrandPalette.textSecondary)
            }
            Spacer()
            Text(metric.value)
                .font(.headline.bold())
                .foregroundStyle(BrandPalette.primaryDeep)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
