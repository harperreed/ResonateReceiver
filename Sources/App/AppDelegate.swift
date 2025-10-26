// ABOUTME: Application delegate for menubar setup
// ABOUTME: Configures app as accessory (menubar-only, no dock icon)

import AppKit
import ResonateReceiver

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - menubar only
        NSApp.setActivationPolicy(.accessory)

        // Create menubar controller
        menuBarController = MenuBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        menuBarController?.cleanup()
    }
}
