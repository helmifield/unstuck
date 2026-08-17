import SwiftUI

/// Minimal app shell. No product UI, onboarding, or screens beyond a placeholder
/// that confirms the app boots and shows the configured environment.
@main
struct UnstuckApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
