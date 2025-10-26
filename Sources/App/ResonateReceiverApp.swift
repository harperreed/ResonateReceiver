// ABOUTME: Main application entry point
// ABOUTME: Sets up SwiftUI app lifecycle and menubar mode

import SwiftUI

@main
struct ResonateReceiverApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
