import SwiftUI

@main
struct MindscapeApp: App {
    @StateObject private var appState = MindscapeAppState()

    var body: some Scene {
        WindowGroup {
            MindscapeRootView(appState: appState)
        }
    }
}
