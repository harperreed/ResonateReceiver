# Resonate MenuBar Receiver Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a macOS menubar app that receives synchronized audio from a Resonate server with rich metadata display and deep macOS media integration.

**Architecture:** Layered architecture with ResonateManager (ResonateKit client), MediaControlsManager (macOS Now Playing), SettingsManager (persistence), and SwiftUI UI layer. Super native macOS look and feel.

**Tech Stack:** Swift 6.0, SwiftUI, AppKit (NSStatusItem), MediaPlayer framework, ResonateKit (SPM)

---

## Task 1: Project Setup

**Files:**
- Create: `Package.swift`
- Create: `.gitignore`
- Create: `ResonateReceiver.entitlements`

**Step 1: Create Swift Package manifest**

Create `Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ResonateReceiver",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ResonateReceiver",
            targets: ["ResonateReceiver"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/harperreed/ResonateKit", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "ResonateReceiver",
            dependencies: ["ResonateKit"],
            path: "Sources"
        ),
        .testTarget(
            name: "ResonateReceiverTests",
            dependencies: ["ResonateReceiver"],
            path: "Tests"
        )
    ]
)
```

**Step 2: Create .gitignore**

Create `.gitignore`:

```
.DS_Store
/.build
/Packages
xcuserdata/
DerivedData/
.swiftpm/
*.xcodeproj
```

**Step 3: Create entitlements file**

Create `ResonateReceiver.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
	<key>com.apple.security.device.audio-input</key>
	<true/>
</dict>
</plist>
```

**Step 4: Verify package structure**

Run: `swift package resolve`
Expected: Package dependencies resolved successfully

**Step 5: Commit**

```bash
git add Package.swift .gitignore ResonateReceiver.entitlements
git commit -m "feat: initialize Swift package with ResonateKit dependency"
```

---

## Task 2: Create Data Models

**Files:**
- Create: `Sources/Models/ServerConfig.swift`
- Create: `Sources/Models/TrackMetadata.swift`
- Create: `Tests/Models/ServerConfigTests.swift`

**Step 1: Write ServerConfig test**

Create `Tests/Models/ServerConfigTests.swift`:

```swift
// ABOUTME: Unit tests for ServerConfig model
// ABOUTME: Tests validation, encoding/decoding, and default values

import Testing
@testable import ResonateReceiver

@Suite("ServerConfig Tests")
struct ServerConfigTests {

    @Test("ServerConfig encodes and decodes correctly")
    func testCodable() throws {
        let config = ServerConfig(
            hostname: "192.168.1.100",
            port: 8080,
            name: "Living Room"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(config)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ServerConfig.self, from: data)

        #expect(decoded.hostname == "192.168.1.100")
        #expect(decoded.port == 8080)
        #expect(decoded.name == "Living Room")
    }

    @Test("ServerConfig validates port range")
    func testPortValidation() {
        #expect(ServerConfig.isValidPort(8080) == true)
        #expect(ServerConfig.isValidPort(1) == true)
        #expect(ServerConfig.isValidPort(65535) == true)
        #expect(ServerConfig.isValidPort(0) == false)
        #expect(ServerConfig.isValidPort(65536) == false)
        #expect(ServerConfig.isValidPort(-1) == false)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL with compilation errors (ServerConfig not defined)

**Step 3: Write minimal ServerConfig implementation**

Create `Sources/Models/ServerConfig.swift`:

```swift
// ABOUTME: Server configuration model for Resonate server connection
// ABOUTME: Handles validation and persistence of server settings

import Foundation

struct ServerConfig: Codable, Equatable {
    let hostname: String
    let port: Int
    let name: String?

    static func isValidPort(_ port: Int) -> Bool {
        return port >= 1 && port <= 65535
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: All tests pass

**Step 5: Write TrackMetadata implementation**

Create `Sources/Models/TrackMetadata.swift`:

```swift
// ABOUTME: Track metadata model from Resonate server
// ABOUTME: Represents currently playing track information

import AppKit

struct TrackMetadata: Equatable {
    let title: String?
    let artist: String?
    let album: String?
    let duration: TimeInterval?

    var displayTitle: String {
        title ?? "Unknown Track"
    }

    var displayArtist: String {
        artist ?? "Unknown Artist"
    }

    var displayAlbum: String {
        album ?? "Unknown Album"
    }
}
```

**Step 6: Commit**

```bash
git add Sources/Models/ Tests/Models/
git commit -m "feat: add ServerConfig and TrackMetadata models"
```

---

## Task 3: Implement SettingsManager

**Files:**
- Create: `Sources/Managers/SettingsManager.swift`
- Create: `Tests/Managers/SettingsManagerTests.swift`

**Step 1: Write SettingsManager test**

Create `Tests/Managers/SettingsManagerTests.swift`:

```swift
// ABOUTME: Unit tests for SettingsManager
// ABOUTME: Tests settings persistence and retrieval

import Testing
@testable import ResonateReceiver

@Suite("SettingsManager Tests")
struct SettingsManagerTests {

    @Test("SettingsManager saves and loads server config")
    func testSaveAndLoad() async {
        let manager = SettingsManager()
        let config = ServerConfig(
            hostname: "test.local",
            port: 8080,
            name: "Test Server"
        )

        await manager.saveServerConfig(config)
        let loaded = await manager.loadServerConfig()

        #expect(loaded == config)
    }

    @Test("SettingsManager clears server config")
    func testClear() async {
        let manager = SettingsManager()
        let config = ServerConfig(hostname: "test.local", port: 8080, name: nil)

        await manager.saveServerConfig(config)
        await manager.clearServerConfig()
        let loaded = await manager.loadServerConfig()

        #expect(loaded == nil)
    }

    @Test("SettingsManager persists auto-discovery setting")
    func testAutoDiscovery() async {
        let manager = SettingsManager()

        await manager.setAutoDiscovery(false)
        let enabled = await manager.enableAutoDiscovery

        #expect(enabled == false)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: FAIL (SettingsManager not defined)

**Step 3: Implement SettingsManager**

Create `Sources/Managers/SettingsManager.swift`:

```swift
// ABOUTME: Manages persistent settings for server configuration
// ABOUTME: Handles UserDefaults storage and retrieval

import Foundation

@MainActor
class SettingsManager: ObservableObject {
    @Published var serverConfig: ServerConfig?
    @Published var enableAutoDiscovery: Bool = true

    private let defaults = UserDefaults.standard
    private let serverConfigKey = "resonateServerConfig"
    private let autoDiscoveryKey = "resonateAutoDiscovery"

    init() {
        loadSettings()
    }

    private func loadSettings() {
        serverConfig = loadServerConfig()
        enableAutoDiscovery = defaults.bool(forKey: autoDiscoveryKey)
        // Default to true if never set
        if !defaults.object(forKey: autoDiscoveryKey) is Bool {
            enableAutoDiscovery = true
        }
    }

    func saveServerConfig(_ config: ServerConfig) {
        if let encoded = try? JSONEncoder().encode(config) {
            defaults.set(encoded, forKey: serverConfigKey)
            serverConfig = config
        }
    }

    func loadServerConfig() -> ServerConfig? {
        guard let data = defaults.data(forKey: serverConfigKey),
              let config = try? JSONDecoder().decode(ServerConfig.self, from: data) else {
            return nil
        }
        return config
    }

    func clearServerConfig() {
        defaults.removeObject(forKey: serverConfigKey)
        serverConfig = nil
    }

    func setAutoDiscovery(_ enabled: Bool) {
        defaults.set(enabled, forKey: autoDiscoveryKey)
        enableAutoDiscovery = enabled
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test`
Expected: All tests pass

**Step 5: Commit**

```bash
git add Sources/Managers/SettingsManager.swift Tests/Managers/SettingsManagerTests.swift
git commit -m "feat: implement SettingsManager for persistent configuration"
```

---

## Task 4: Implement MediaControlsManager

**Files:**
- Create: `Sources/Managers/MediaControlsManager.swift`

**Step 1: Implement MediaControlsManager**

Create `Sources/Managers/MediaControlsManager.swift`:

```swift
// ABOUTME: Manages macOS Now Playing integration
// ABOUTME: Handles MPNowPlayingInfoCenter and media key events

import Foundation
import MediaPlayer
import AppKit

@MainActor
class MediaControlsManager {
    static let shared = MediaControlsManager()

    private let nowPlayingCenter = MPNowPlayingInfoCenter.default()
    private let commandCenter = MPRemoteCommandCenter.shared()

    private init() {
        setupRemoteCommands()
    }

    private func setupRemoteCommands() {
        // Disable commands that Resonate doesn't support
        commandCenter.playCommand.isEnabled = false
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
    }

    func updateNowPlaying(metadata: TrackMetadata, artwork: NSImage?) {
        var nowPlayingInfo: [String: Any] = [:]

        if let title = metadata.title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }

        if let artist = metadata.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }

        if let album = metadata.album {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }

        if let duration = metadata.duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }

        if let artwork = artwork {
            let mediaArtwork = MPMediaItemArtwork(boundsSize: artwork.size) { _ in
                return artwork
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArtwork
        }

        nowPlayingCenter.nowPlayingInfo = nowPlayingInfo
    }

    func clearNowPlaying() {
        nowPlayingCenter.nowPlayingInfo = nil
    }
}
```

**Step 2: Build to verify it compiles**

Run: `swift build`
Expected: Build succeeds

**Step 3: Commit**

```bash
git add Sources/Managers/MediaControlsManager.swift
git commit -m "feat: implement MediaControlsManager for macOS Now Playing"
```

---

## Task 5: Implement ResonateManager Stub

**Files:**
- Create: `Sources/Managers/ResonateManager.swift`

**Step 1: Create ResonateManager stub**

Create `Sources/Managers/ResonateManager.swift`:

```swift
// ABOUTME: Manages ResonateKit client and playback state
// ABOUTME: Handles connection lifecycle and metadata updates

import Foundation
import Combine

@MainActor
class ResonateManager: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var currentMetadata: TrackMetadata?
    @Published var connectionStatus: String = "Disconnected"
    @Published var volume: Float = 1.0
    @Published var isMuted: Bool = false

    private let mediaControls = MediaControlsManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // TODO: Initialize ResonateKit client when ready
    }

    func connect(to server: ServerConfig) {
        // TODO: Implement ResonateKit connection
        connectionStatus = "Connecting to \(server.hostname):\(server.port)..."
    }

    func disconnect() {
        // TODO: Implement ResonateKit disconnection
        isConnected = false
        connectionStatus = "Disconnected"
        currentMetadata = nil
        mediaControls.clearNowPlaying()
    }

    func setVolume(_ value: Float) {
        volume = max(0.0, min(1.0, value))
        if isMuted {
            isMuted = false
        }
        // TODO: Apply to audio output
    }

    func toggleMute() {
        isMuted.toggle()
        // TODO: Apply to audio output
    }

    private func updateMetadata(_ metadata: TrackMetadata) {
        currentMetadata = metadata
        mediaControls.updateNowPlaying(metadata: metadata, artwork: nil)
    }
}
```

**Step 2: Build to verify it compiles**

Run: `swift build`
Expected: Build succeeds

**Step 3: Commit**

```bash
git add Sources/Managers/ResonateManager.swift
git commit -m "feat: add ResonateManager stub (ResonateKit integration pending)"
```

---

## Task 6: Implement App Entry Point

**Files:**
- Create: `Sources/App/ResonateReceiverApp.swift`
- Create: `Sources/App/AppDelegate.swift`

**Step 1: Create app entry point**

Create `Sources/App/ResonateReceiverApp.swift`:

```swift
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
```

**Step 2: Create AppDelegate**

Create `Sources/App/AppDelegate.swift`:

```swift
// ABOUTME: Application delegate for menubar setup
// ABOUTME: Configures app as accessory (menubar-only, no dock icon)

import AppKit

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
```

**Step 3: Build to verify it compiles**

Run: `swift build`
Expected: FAIL (MenuBarController not defined)

**Note:** This is expected. We'll implement MenuBarController next.

**Step 4: Commit**

```bash
git add Sources/App/
git commit -m "feat: add app entry point and delegate"
```

---

## Task 7: Implement MenuBarController

**Files:**
- Create: `Sources/UI/MenuBarController.swift`

**Step 1: Implement MenuBarController**

Create `Sources/UI/MenuBarController.swift`:

```swift
// ABOUTME: Manages menubar icon and popover interaction
// ABOUTME: Creates NSStatusItem and hosts SwiftUI ContentView

import AppKit
import SwiftUI

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
        popover.behavior = .transitory

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
```

**Step 2: Build to verify it compiles**

Run: `swift build`
Expected: FAIL (ContentView not defined)

**Note:** Expected. We'll implement ContentView next.

**Step 3: Commit**

```bash
git add Sources/UI/MenuBarController.swift
git commit -m "feat: implement MenuBarController for menubar interaction"
```

---

## Task 8: Implement ContentView

**Files:**
- Create: `Sources/UI/ContentView.swift`

**Step 1: Implement ContentView**

Create `Sources/UI/ContentView.swift`:

```swift
// ABOUTME: Main popover UI showing connection status and playback info
// ABOUTME: Displays album art, metadata, controls, and settings access

import SwiftUI

struct ContentView: View {
    @ObservedObject var resonateManager: ResonateManager
    @ObservedObject var settingsManager: SettingsManager
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            Divider()

            // Album art and metadata
            if resonateManager.isConnected {
                playbackSection
            } else {
                disconnectedSection
            }

            Divider()

            // Controls
            controlsSection

            Divider()

            // Footer
            footerSection
        }
        .frame(width: 350, height: 500)
        .sheet(isPresented: $showingSettings) {
            SettingsView(settingsManager: settingsManager)
        }
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "waveform.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)
            Text("Resonate Receiver")
                .font(.headline)
            Spacer()
            Circle()
                .fill(resonateManager.isConnected ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding()
    }

    private var playbackSection: some View {
        VStack(spacing: 16) {
            // Album art
            Image(systemName: "music.note")
                .font(.system(size: 120))
                .foregroundColor(.secondary)
                .frame(width: 300, height: 300)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)

            // Metadata
            VStack(spacing: 4) {
                Text(resonateManager.currentMetadata?.displayTitle ?? "Not Playing")
                    .font(.headline)
                    .lineLimit(2)

                Text(resonateManager.currentMetadata?.displayArtist ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(resonateManager.currentMetadata?.displayAlbum ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private var disconnectedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(resonateManager.connectionStatus)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }

    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Volume control
            HStack {
                Image(systemName: resonateManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                    .onTapGesture {
                        resonateManager.toggleMute()
                    }

                Slider(
                    value: Binding(
                        get: { resonateManager.volume },
                        set: { resonateManager.setVolume($0) }
                    ),
                    in: 0...1
                )
                .disabled(resonateManager.isMuted)

                Text("\(Int(resonateManager.volume * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }

            // Settings button
            Button("Settings") {
                showingSettings = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var footerSection: some View {
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .buttonStyle(.plain)
        .foregroundColor(.red)
        .padding()
    }
}

#Preview {
    ContentView(
        resonateManager: ResonateManager(),
        settingsManager: SettingsManager()
    )
}
```

**Step 2: Build to verify it compiles**

Run: `swift build`
Expected: FAIL (SettingsView not defined)

**Note:** Expected. We'll implement SettingsView next.

**Step 3: Commit**

```bash
git add Sources/UI/ContentView.swift
git commit -m "feat: implement ContentView with playback UI"
```

---

## Task 9: Implement SettingsView

**Files:**
- Create: `Sources/UI/SettingsView.swift`

**Step 1: Implement SettingsView**

Create `Sources/UI/SettingsView.swift`:

```swift
// ABOUTME: Settings dialog for server configuration
// ABOUTME: Allows manual server entry and auto-discovery toggle

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss

    @State private var hostname: String = ""
    @State private var port: String = "8080"
    @State private var serverName: String = ""
    @State private var enableAutoDiscovery: Bool = true
    @State private var validationError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Server Settings")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            // Auto-discovery toggle
            Toggle("Enable auto-discovery", isOn: $enableAutoDiscovery)
                .onChange(of: enableAutoDiscovery) { _, newValue in
                    settingsManager.setAutoDiscovery(newValue)
                }

            // Manual server configuration
            GroupBox("Manual Server Configuration") {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Hostname or IP", text: $hostname)
                        .textFieldStyle(.roundedBorder)
                        .disabled(enableAutoDiscovery)

                    TextField("Port", text: $port)
                        .textFieldStyle(.roundedBorder)
                        .disabled(enableAutoDiscovery)

                    TextField("Server Name (optional)", text: $serverName)
                        .textFieldStyle(.roundedBorder)
                        .disabled(enableAutoDiscovery)

                    if let error = validationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 8)
            }
            .disabled(enableAutoDiscovery)

            Spacer()

            // Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveSettings()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(enableAutoDiscovery || !isValid())
            }
        }
        .padding()
        .frame(width: 400, height: 350)
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        enableAutoDiscovery = settingsManager.enableAutoDiscovery

        if let config = settingsManager.serverConfig {
            hostname = config.hostname
            port = String(config.port)
            serverName = config.name ?? ""
        }
    }

    private func isValid() -> Bool {
        validationError = nil

        guard !hostname.isEmpty else {
            validationError = "Hostname is required"
            return false
        }

        guard let portInt = Int(port), ServerConfig.isValidPort(portInt) else {
            validationError = "Port must be between 1 and 65535"
            return false
        }

        return true
    }

    private func saveSettings() {
        guard isValid(), let portInt = Int(port) else { return }

        let config = ServerConfig(
            hostname: hostname,
            port: portInt,
            name: serverName.isEmpty ? nil : serverName
        )

        settingsManager.saveServerConfig(config)
        dismiss()
    }
}

#Preview {
    SettingsView(settingsManager: SettingsManager())
}
```

**Step 2: Build to verify it compiles**

Run: `swift build`
Expected: Build succeeds

**Step 3: Test the app manually**

Run: `swift run`
Expected: Menubar icon appears, clicking shows popover with UI

**Step 4: Commit**

```bash
git add Sources/UI/SettingsView.swift
git commit -m "feat: implement SettingsView for server configuration"
```

---

## Task 10: Create Tests Directory Structure

**Files:**
- Create: `Tests/Models/.gitkeep`
- Create: `Tests/Managers/.gitkeep`

**Step 1: Create test directories**

Run:
```bash
mkdir -p Tests/Models Tests/Managers
touch Tests/Models/.gitkeep Tests/Managers/.gitkeep
```

Expected: Directories created

**Step 2: Run all tests**

Run: `swift test`
Expected: All existing tests pass

**Step 3: Commit**

```bash
git add Tests/
git commit -m "test: add test directory structure"
```

---

## Task 11: Add README and Documentation

**Files:**
- Create: `README.md`

**Step 1: Create README**

Create `README.md`:

```markdown
# Resonate MenuBar Receiver

A native macOS menubar application that receives synchronized audio from a Resonate server with rich metadata display and deep macOS media integration.

## Features

- 🎵 Synchronized multi-room audio playback via Resonate
- 🖼️ Rich metadata display with album art
- 🔊 Volume control with mute
- ⌨️ macOS media key integration
- 🔒 Lock Screen / Control Center / Touch Bar support
- ⚙️ Auto-discovery and manual server configuration
- 🎨 Super native macOS design

## Requirements

- macOS 14.0+
- Xcode 15+
- Swift 6.0
- Running Resonate server

## Installation

### Build from source

```bash
git clone <repo-url>
cd resonate-menu-item
swift build -c release
```

### Run

```bash
swift run
```

The app will appear in your menubar. Click the icon to show controls and settings.

## Configuration

### Auto-discovery

By default, the app will automatically discover Resonate servers on your local network via mDNS/Bonjour.

### Manual configuration

1. Click the menubar icon
2. Click "Settings"
3. Disable "Enable auto-discovery"
4. Enter your server hostname/IP and port
5. Click "Save"

## Architecture

The app uses a layered architecture:

- **Manager Layer**: ResonateManager, MediaControlsManager, SettingsManager
- **UI Layer**: SwiftUI views with minimal AppKit glue
- **Model Layer**: ServerConfig, TrackMetadata

See `docs/plans/2025-10-25-resonate-menubar-receiver-design.md` for detailed design documentation.

## Development

### Running tests

```bash
swift test
```

### Building for release

```bash
swift build -c release
```

## Dependencies

- [ResonateKit](https://github.com/harperreed/ResonateKit) - Swift client for Resonate Protocol

## License

[Add license here]

## Credits

Built with [ResonateKit](https://github.com/harperreed/ResonateKit)
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with setup and usage instructions"
```

---

## Task 12: ResonateKit Integration (TODO)

**Note:** This task requires ResonateKit API documentation or source code inspection. The following is a template based on expected API patterns.

**Files:**
- Modify: `Sources/Managers/ResonateManager.swift`

**TODO Steps:**

1. Import ResonateKit
2. Create ResonateClient instance with player role
3. Set up discovery callbacks
4. Implement connection logic
5. Handle metadata callbacks
6. Handle audio data callbacks
7. Implement volume control
8. Test with real Resonate server

**Reference:** See ResonateKit documentation at https://github.com/harperreed/ResonateKit

---

## Completion Checklist

- [ ] Task 1: Project setup complete
- [ ] Task 2: Data models implemented and tested
- [ ] Task 3: SettingsManager implemented and tested
- [ ] Task 4: MediaControlsManager implemented
- [ ] Task 5: ResonateManager stub created
- [ ] Task 6: App entry point created
- [ ] Task 7: MenuBarController implemented
- [ ] Task 8: ContentView implemented
- [ ] Task 9: SettingsView implemented
- [ ] Task 10: Test structure created
- [ ] Task 11: Documentation added
- [ ] Task 12: ResonateKit integration (requires API investigation)

## Next Steps

1. **Investigate ResonateKit API** - Read source or docs to understand client API
2. **Complete ResonateManager integration** - Wire up ResonateClient
3. **Test with real server** - Verify playback and metadata
4. **Add album art support** - Fetch and display artwork
5. **Polish UI** - Add animations, loading states, better error messages
6. **Package for distribution** - Create .app bundle, code signing

## Notes

- All managers use `@MainActor` for thread safety
- Settings persist via UserDefaults
- Media controls integrate with macOS Now Playing
- UI follows native macOS design patterns
- Code includes ABOUTME comments for discoverability
