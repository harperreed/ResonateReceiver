// ABOUTME: Manages menubar icon and popover interaction
// ABOUTME: Creates NSStatusItem and hosts SwiftUI ContentView

import AppKit
import SwiftUI

@MainActor
public class MenuBarController: NSObject {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let resonateManager: ResonateManager
    private let settingsManager: SettingsManager

    public override init() {
        print("🟢 MenuBarController: init started")

        // Create managers
        resonateManager = ResonateManager()
        settingsManager = SettingsManager()
        print("🟢 MenuBarController: Managers created")

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        print("🟢 MenuBarController: StatusItem created: \(statusItem)")

        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 500)
        popover.behavior = .semitransient
        print("🟢 MenuBarController: Popover created")

        super.init()

        setupStatusItem()
        setupPopover()
        print("🟢 MenuBarController: init complete")
    }

    private func setupStatusItem() {
        print("🟢 MenuBarController: setupStatusItem called")
        guard let button = statusItem.button else {
            print("🔴 MenuBarController: ERROR - statusItem.button is nil!")
            return
        }
        print("🟢 MenuBarController: StatusItem button exists")

        button.image = NSImage(
            systemSymbolName: "waveform.circle",
            accessibilityDescription: "Resonate Receiver"
        )
        print("🟢 MenuBarController: Button image set")

        button.action = #selector(togglePopover)
        button.target = self
        print("🟢 MenuBarController: Button action and target set")
    }

    private func setupPopover() {
        let contentView = ContentView(
            resonateManager: resonateManager,
            settingsManager: settingsManager
        )
        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Activate app so popover gets focus
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    public func cleanup() {
        resonateManager.disconnect()
    }
}
