# Your Work

This file lists only the new iOS-specific work to build the app.

Do not redo or redefine shared backend work that already exists, including:

- Supabase project structure
- database schema and migrations
- row-level security rules
- backend-owned booking rules
- MyFatoorah backend flow
- Agora token issuance flow
- shared booking, payment, and session statuses

## Build The iOS App

1. Generate the Xcode project from `project.yml`.
2. Make the current Swift scaffold compile in Xcode.
3. Set up app-wide navigation, app state, and dependency wiring.

## Build The UI

1. Turn the current placeholder SwiftUI screens into production-ready screens.
2. Match the intended app experience and visual quality using the existing brand assets.
3. Build these flows:
- auth
- therapist discovery
- therapist detail
- availability and booking
- appointments/history
- profile
- session detail and join flow

## Connect The Backend

1. Add the iOS Supabase client integration.
2. Implement concrete repository classes for the existing contracts.
3. Connect the app to live auth, profile, therapist, booking, payment-status, and session data.
4. Use the existing backend-owned flows for booking, payment, and session access.

## iOS-Specific Platform Work

1. Configure local app settings through `Configs/Supabase.xcconfig`.
2. Handle session persistence and app relaunch state correctly on iOS.
3. Implement payment handoff and return handling on iOS.
4. Implement the Agora join experience on iOS.
5. Prepare app icons, launch behavior, and platform configuration needed for a real iOS build.

## Quality Bar

1. Add tests for critical app logic and mappings.
2. Validate the main user flow end to end in the iOS app.
3. Keep the app aligned with the documented product and architecture rules.

## Do Not Do

- do not create a separate backend model
- do not change shared payment logic from the client side
- do not add non-MVP features
- do not hardcode secrets
