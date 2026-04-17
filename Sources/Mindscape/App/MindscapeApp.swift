import SwiftUI

@main
struct MindscapeApp: App {
    @StateObject private var appState = MindscapeAppState(dependencies: .bootstrap())

    var body: some Scene {
        WindowGroup {
            MindscapeRootView(appState: appState)
        }
    }
}
