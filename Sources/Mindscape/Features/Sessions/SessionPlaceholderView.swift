import SwiftUI

struct SessionPlaceholderView: View {
    var body: some View {
        VStack(spacing: MindscapeSpacing.medium) {
            Image(systemName: "video")
                .font(.system(size: 40))
                .foregroundStyle(BrandPalette.primary)
            Text("Session flow placeholder")
                .font(.title3.bold())
            Text("Keep payment verification, Agora token issuance, and join-state gating aligned with the shared backend docs before wiring a live session experience.")
                .multilineTextAlignment(.center)
                .foregroundStyle(BrandPalette.textSecondary)
        }
        .padding(MindscapeSpacing.large)
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}
