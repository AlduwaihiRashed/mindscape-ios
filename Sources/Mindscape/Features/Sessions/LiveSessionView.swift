import SwiftUI

// NOTE: Agora RTC SDK is not yet linked. This view stubs the live session experience.
// When the SDK is added to project.yml, replace the preview content with real AgoraRtcEngineKit calls.

struct LiveSessionView: View {
    @ObservedObject var appState: MindscapeAppState
    let bookingId: String
    @State private var isMuted = false
    @State private var isCameraOff = false
    @State private var showEndAlert = false
    @Environment(\.dismiss) private var dismiss

    private var credentials: AgoraJoinCredentials? { appState.liveSessionState.credentials }
    private var details: SessionDetails? { appState.liveSessionState.details }
    private var isPreview: Bool { credentials?.appId == "mock-app-id" }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if appState.liveSessionState.isLoading {
                ProgressView("Connecting...")
                    .tint(.white)
                    .foregroundStyle(.white)
            } else if let errorMessage = appState.liveSessionState.errorMessage {
                VStack(spacing: MindscapeSpacing.medium) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                    Text("Connection failed")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(errorMessage)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    Button("Go back") { dismiss() }
                        .foregroundStyle(.white)
                        .padding()
                }
                .padding()
            } else {
                sessionContent
            }
        }
        .navigationBarHidden(true)
        .alert("End session?", isPresented: $showEndAlert) {
            Button("End session", role: .destructive) {
                appState.navigationPath.removeLast()
            }
            Button("Keep going", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave the session?")
        }
    }

    @ViewBuilder
    private var sessionContent: some View {
        VStack {
            // Remote video area
            ZStack {
                if isPreview {
                    previewPlaceholder
                } else {
                    // TODO: insert AgoraVideoCanvas here when SDK is linked
                    Color(white: 0.15)
                }

                // Session info overlay
                VStack {
                    HStack {
                        if let details {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(details.therapistName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(details.sessionMode.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        Spacer()
                        Text(sessionDurationLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.4))
                            .clipShape(Capsule())
                    }
                    .padding()
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity)

            // Controls
            HStack(spacing: MindscapeSpacing.large) {
                Spacer()

                controlButton(
                    icon: isMuted ? "mic.slash.fill" : "mic.fill",
                    label: isMuted ? "Unmute" : "Mute",
                    tint: isMuted ? .red : .white
                ) {
                    isMuted.toggle()
                    // TODO: appId == "mock-app-id" → no-op; else: agoraEngine.muteLocalAudioStream(isMuted)
                }

                if details?.sessionMode == "video" {
                    controlButton(
                        icon: isCameraOff ? "video.slash.fill" : "video.fill",
                        label: isCameraOff ? "Camera off" : "Camera on",
                        tint: isCameraOff ? .red : .white
                    ) {
                        isCameraOff.toggle()
                        // TODO: agoraEngine.muteLocalVideoStream(isCameraOff)
                    }
                }

                controlButton(icon: "phone.down.fill", label: "End", tint: .red) {
                    showEndAlert = true
                }

                Spacer()
            }
            .padding()
            .background(Color(white: 0.1))
        }
    }

    private var previewPlaceholder: some View {
        VStack(spacing: MindscapeSpacing.medium) {
            Text(details?.therapistInitials ?? "T")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(BrandPalette.primaryDeep)
                .frame(width: 120, height: 120)
                .background(BrandPalette.primaryLight)
                .clipShape(Circle())

            Text(details?.therapistName ?? "Therapist")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Preview mode — Agora SDK not linked")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.12))
    }

    private func controlButton(icon: String, label: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(tint)
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private var sessionDurationLabel: String {
        // TODO: track actual elapsed time with a Timer
        "Live"
    }
}
