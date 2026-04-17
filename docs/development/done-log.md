# Done Log

Use this file as a lightweight changelog of completed project work.

## Entry Template

### YYYY-MM-DD - Short Title

- owner: role or contributor name
- completed:
  - item one
  - item two
- files:
  - path/to/file
- validation:
  - what was checked
- notes:
  - assumptions, follow-ups, or risks if needed

## 2026-04-07 - iOS Kickoff Package Alignment

- owner: OpenCode
- completed:
  - rewrote root, development, architecture, and deployment docs so the repository is framed as a standalone iOS implementation package
  - removed platform-history language that would distract the next developer from the current delivery path
  - aligned backlog, handoff, and roadmap docs around building the iOS app and validating backend-backed flows
- files:
  - `README.md`
  - `roadmap.md`
  - `docs/development/*`
  - `docs/architecture/tech-stack.md`
  - `docs/architecture/system-design.md`
  - `docs/architecture/decisions.md`
  - `docs/deployment/environments.md`
  - `docs/deployment/release-process.md`
- validation:
  - searched docs for stale platform-history references
  - reviewed the main contributor-facing docs for consistency
- notes:
  - the next meaningful milestone is compiling the app scaffold on macOS and replacing preview-backed flows with real repositories

## 2026-04-10 - App Shell Repository Wiring

- owner: OpenCode
- completed:
  - added a small app dependency container and preview repository implementations so the app shell no longer pulls screen data directly from sample data in `MindscapeAppState`
  - moved auth, discovery, bookings, and profile screens onto explicit async UI state with loading, empty, and error handling
  - connected the auth screen and profile screen to sign-in, sign-up, reset-password, and sign-out preview flows so repository-backed work can continue before macOS validation
  - moved `BookingView` to repository-backed therapist availability and preview booking-draft creation instead of static booking date/time sample arrays
  - mirrored the Android repo's `AppContainer` approach by adding live Supabase repositories, unavailable fallbacks, and XcodeGen package wiring for the same auth, profile, therapist, and booking data path
- files:
  - `Sources/Mindscape/App/MindscapeApp.swift`
  - `Sources/Mindscape/App/MindscapeAppDependencies.swift`
  - `Sources/Mindscape/App/MindscapeAppState.swift`
  - `Sources/Mindscape/Data/Config/SupabaseClientFactory.swift`
  - `Sources/Mindscape/Data/Repositories/PreviewRepositories.swift`
  - `Sources/Mindscape/Data/Repositories/SupabaseRepositories.swift`
  - `Sources/Mindscape/Data/Repositories/UnavailableRepositories.swift`
  - `Sources/Mindscape/Features/Auth/AuthView.swift`
  - `Sources/Mindscape/Features/Appointments/AppointmentsView.swift`
  - `Sources/Mindscape/Features/Booking/BookingView.swift`
  - `Sources/Mindscape/Features/Home/HomeView.swift`
  - `Sources/Mindscape/Features/Profile/ProfileView.swift`
  - `Sources/Mindscape/Features/Therapists/TherapistDetailView.swift`
  - `Sources/Mindscape/PreviewContent/MindscapeSampleData.swift`
  - `project.yml`
  - `docs/development/context.md`
  - `docs/development/tasks.md`
  - `docs/development/handoff.md`
- validation:
  - reviewed product and architecture docs for the app-shell responsibility boundaries before editing
  - compared the Swift implementation against the Android repository's live Supabase repositories and fallback container behavior
  - performed a manual code pass for dependency wiring, async state transitions, and view usage because Swift/Xcode tooling is unavailable in this environment
- notes:
  - a real compile is still required on macOS to catch SwiftUI or concurrency issues that cannot be validated on Linux
  - the remaining highest-value iOS step is validating the new Supabase package integration on macOS and fixing any API mismatches from the first live compile
