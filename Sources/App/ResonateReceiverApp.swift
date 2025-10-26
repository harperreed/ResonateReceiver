// ABOUTME: Main application entry point
// ABOUTME: Bootstraps AppKit application with menubar-only mode

import AppKit

@main
struct ResonateReceiverApp {
    static func main() {
        print("⭐️ main() started")
        fflush(stdout)

        let app = NSApplication.shared
        print("⭐️ NSApplication.shared acquired")
        fflush(stdout)

        // Set activation policy BEFORE assigning delegate
        app.setActivationPolicy(.accessory)
        print("⭐️ Activation policy set to accessory")
        fflush(stdout)

        let delegate = AppDelegate()
        print("⭐️ AppDelegate created")
        fflush(stdout)

        app.delegate = delegate
        print("⭐️ Delegate assigned, about to call app.run()")
        fflush(stdout)

        app.run()
    }
}
