# Mindscape iOS — Completion Checklist

Everything the Swift project needs before shipping. Work top to bottom.

---

## Step 1 — Generate & open the project

```bash
cd mindscape-swift
xcodegen generate
open Mindscape.xcodeproj
```

Fix any Swift errors the compiler surfaces (naming drift from last-minute edits). There should be none, but resolve before moving on.

---

## Step 2 — Supabase credentials (~10 min)

Create `Configs/Supabase.xcconfig` (git-ignored):

```
SUPABASE_URL = https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

`SUPABASE_ANON_KEY` is the public anon key from Supabase → Settings → API.

**Verify:** Run on simulator. Home screen should load therapists from the real database. Profile tab should show "Supabase: Configured".

---

## Step 3 — MyFatoorah payment browser (~2–3 hrs)

### What's done
- `SupabaseBookingRepository.startPayment` calls the `start-myfatoorah` edge function and returns a `PaymentLaunch` with `redirectUrl`
- `SupabaseBookingRepository.verifyPayment` calls `verify-myfatoorah`
- `CheckoutView` shows the payment sheet and calls both methods

### What to replace
`CheckoutView.swift` — `PaymentWebView` struct. Replace the "Simulate payment success" button with a real browser:

```swift
import SafariServices

struct PaymentWebView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
```

Then in `CheckoutView`, open it with the redirect URL:
```swift
// Replace the current PaymentWebView sheet content with:
SFSafariViewController presenting launch.redirectUrl
```

### Handle the return URL

MyFatoorah redirects to your app via a URL scheme after payment. Wire it up:

**1. Register URL scheme** — Xcode → Target → Info → URL Types:
- Identifier: `com.mindscape.app.ios`
- URL Schemes: `mindscape` (must match whatever you configured in the MyFatoorah dashboard as the return URL, e.g. `mindscape://payment/return`)

**2. Handle it in `MindscapeApp.swift`:**
```swift
@main
struct MindscapeApp: App {
    @StateObject private var appState = MindscapeAppState(dependencies: .bootstrap())

    var body: some Scene {
        WindowGroup {
            MindscapeRootView(appState: appState)
                .onOpenURL { url in
                    // URL shape: mindscape://payment/return?paymentId=xxx&bookingId=yyy
                    guard url.host == "payment",
                          let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let paymentId = components.queryItems?.first(where: { $0.name == "paymentId" })?.value,
                          let bookingId = components.queryItems?.first(where: { $0.name == "bookingId" })?.value
                    else { return }

                    Task {
                        await appState.verifyPayment(bookingId: bookingId, paymentId: paymentId)
                    }
                }
        }
    }
}
```

**Note:** Confirm the exact return URL shape with your backend team / MyFatoorah dashboard config. The `bookingId` may come from state rather than the URL depending on how the edge function is configured.

---

## Step 4 — Agora RTC live sessions (~3–4 hrs)

### Add the SDK

`project.yml` — under `packages`:
```yaml
AgoraRtcKit:
  url: https://github.com/AgoraIO/AgoraRtcEngine_iOS.git
  from: "4.3.0"
```

Re-run `xcodegen generate` after editing.

### Wire up `LiveSessionView.swift`

The view already has the full UI (mute, camera toggle, end call, preview placeholder). Replace the `// TODO:` stubs.

**Engine setup** — add to the view or a helper class:
```swift
import AgoraRtcKit

private let agoraEngine = AgoraRtcEngineKit.sharedEngine(
    withAppId: credentials.appId,
    delegate: nil          // implement AgoraRtcEngineDelegate for remote user events
)
```

**On appear:**
```swift
.onAppear {
    guard let creds = credentials, !isPreview else { return }
    agoraEngine.enableVideo()
    agoraEngine.startPreview()
    let option = AgoraRtcChannelMediaOptions()
    option.clientRoleType = .broadcaster
    agoraEngine.joinChannel(
        byToken: creds.token,
        channelId: creds.channelName,
        uid: 0,
        mediaOptions: option
    )
}
.onDisappear {
    agoraEngine.stopPreview()
    agoraEngine.leaveChannel()
    AgoraRtcEngineKit.destroy()
}
```

**Remote video canvas** — replace the `// TODO: insert AgoraVideoCanvas` comment:
```swift
AgoraVideoCanvasView(engine: agoraEngine, uid: remoteUid)   // remoteUid from delegate
    .frame(maxWidth: .infinity, maxHeight: .infinity)
```

**Local preview (picture-in-picture):**
```swift
AgoraVideoCanvasView(engine: agoraEngine, uid: 0)
    .frame(width: 100, height: 140)
    .clipShape(RoundedRectangle(cornerRadius: 12))
```

**Mute / camera toggle** — replace the `// TODO:` comments in the control buttons:
```swift
agoraEngine.muteLocalAudioStream(isMuted)
agoraEngine.muteLocalVideoStream(isCameraOff)
```

**Audio-only sessions** — check `details?.sessionMode == "audio"` and skip `enableVideo()` / the video canvas. The UI already hides the camera button for audio mode.

**Credentials** (`appId`, `channelName`, `token`) are already fetched via `appState.prepareJoin(bookingId:)` and stored in `appState.liveSessionState.credentials` before `LiveSessionView` appears. No additional network calls needed.

---

## Step 5 — Push notifications (optional, post-launch)

Use Supabase Edge Functions + APNs or a third-party service (OneSignal, etc.) to notify users when:
- A session is starting soon (15-min reminder)
- A booking is confirmed after payment

The iOS side requires:
- `UNUserNotificationCenter` permission request (add to `MindscapeApp.swift` on first launch)
- Register device token with your backend

---

## Step 6 — Arabic localisation (optional)

The backend stores `locale` as `en-KW` or `ar-KW`. The locale toggle in Profile is already wired to `updateLocale`. To actually display Arabic:

- Add `ar` to project localisations in Xcode
- Add `Localizable.strings` files for both languages
- Apply `.environment(\.layoutDirection, locale == "ar-KW" ? .rightToLeft : .leftToRight)` at the root view

---

## Quick smoke-test checklist before shipping

- [ ] Home loads therapists from Supabase
- [ ] Sign up → sign in → sign out flow works
- [ ] Book a private session → checkout screen appears → payment redirect opens
- [ ] Payment return URL triggers `verifyPayment` → booking status updates to `confirmed`
- [ ] Appointments tab shows confirmed booking → tap → Session detail → Join opens LiveSessionView
- [ ] Agora session connects (at least two devices)
- [ ] Cancel booking from Session detail works
- [ ] Profile edit (name + phone) saves to Supabase
- [ ] Locale toggle persists across launches
- [ ] Group session booking end-to-end
- [ ] Your Space loads quotes from Supabase

---

## Files to touch for each step

| Task | File |
|------|------|
| Supabase credentials | `Configs/Supabase.xcconfig` (create) |
| Payment browser | `Features/Checkout/CheckoutView.swift` → `PaymentWebView` struct |
| Deep link handler | `App/MindscapeApp.swift` → `.onOpenURL` |
| URL scheme | Xcode target Info tab → URL Types |
| Agora SDK | `project.yml` → packages; re-run xcodegen |
| Agora engine | `Features/Sessions/LiveSessionView.swift` → replace `// TODO:` blocks |
