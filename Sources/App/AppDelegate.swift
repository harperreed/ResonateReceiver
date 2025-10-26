// ABOUTME: Application delegate for menubar setup
// ABOUTME: Configures app as accessory (menubar-only, no dock icon)

import AppKit
import ResonateReceiverLib

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🔵 AppDelegate: applicationDidFinishLaunching called")
        fflush(stdout)

        // Create menubar controller
        menuBarController = MenuBarController()
        print("🔵 AppDelegate: MenuBarController created")
        fflush(stdout)
    }

    func applicationWillTerminate(_ notification: Notification) {
        menuBarController?.cleanup()
    }
}
