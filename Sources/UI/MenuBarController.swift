// ABOUTME: Manages menubar icon and popover interaction
// ABOUTME: Creates NSStatusItem and hosts SwiftUI ContentView

import AppKit
import SwiftUI

@MainActor
class MenuBarController: NSObject {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let resonateManager: ResonateManager
    private let settingsManager: SettingsManager

    override init() {
        // Create managers
        resonateManager = ResonateManager()
        settingsManager = SettingsManager()

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 500)
        popover.behavior = .semitransient

        super.init()

        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else { return }

        button.image = NSImage(
            systemSymbolName: "waveform.circle",
            accessibilityDescription: "Resonate Receiver"
        )
        button.action = #selector(togglePopover)
        button.target = self
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

    func cleanup() {
        resonateManager.disconnect()
    }
}
