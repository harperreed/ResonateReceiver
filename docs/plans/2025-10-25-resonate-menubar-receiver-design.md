# Resonate MenuBar Receiver - Design Document

**Date:** 2025-10-25
**Purpose:** Personal listening station + polished ResonateKit showcase application
**Architecture:** Layered architecture with clear separation of concerns

## Overview

A macOS menubar application that receives synchronized audio from a Resonate server, displays rich metadata with album art, and provides deep macOS media integration. The app serves dual purposes: a functional multi-room audio receiver for personal use and a reference implementation demonstrating ResonateKit best practices.

## Requirements

### Core Functionality
- Receive and play synchronized audio from Resonate server
- Display rich metadata (track title, artist, album, album art)
- Volume control with mute capability
- macOS Now Playing integration (media keys, Lock Screen, Control Center, Touch Bar)
- Server configuration (auto-discovery + manual entry)

### User Experience
- **Menubar**: Minimal icon only (waveform/speaker symbol)
- **Popover**: Rich UI with album art, metadata, controls (300-350px width)
- **Settings**: Lightweight dialog for server configuration
- **Design**: Super native macOS look and feel

### Technical Requirements
- macOS 14.0+ deployment target
- Swift 6.0
- ResonateKit dependency via Swift Package Manager
- Menubar-only app (no dock icon)

## Architecture

### Layered Design

The application uses a three-layer architecture:

1. **Manager Layer** - Business logic and external service integration
2. **UI Layer** - SwiftUI views with minimal AppKit glue
3. **Model Layer** - Data structures and configuration

### Component Diagram

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                           │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────┐  │
│  │ MenuBar      │  │ ContentView │  │ SettingsView │  │
│  │ Controller   │  │             │  │              │  │
│  └──────┬───────┘  └──────┬──────┘  └──────┬───────┘  │
└─────────┼─────────────────┼─────────────────┼──────────┘
          │                 │                 │
┌─────────┼─────────────────┼─────────────────┼──────────┐
│         │         Manager Layer             │          │
│  ┌──────▼─────────┐  ┌───▼──────────┐  ┌───▼─────────┐│
│  │   Resonate     │  │    Media     │  │  Settings   ││
│  │   Manager      │──│   Controls   │  │   Manager   ││
│  │                │  │   Manager    │  │             ││
│  └────────┬───────┘  └──────────────┘  └─────────────┘│
└───────────┼──────────────────────────────────────────┬─┘
            │                                          │
┌───────────▼──────────────────────────────────────────▼─┐
│                 External Services                      │
│        ┌──────────────┐      ┌──────────────┐         │
│        │ ResonateKit  │      │ UserDefaults │         │
│        │   Client     │      │              │         │
│        └──────────────┘      └──────────────┘         │
│        ┌──────────────┐                                │
│        │MPNowPlaying  │                                │
│        │InfoCenter    │                                │
│        └──────────────┘                                │
└────────────────────────────────────────────────────────┘
```

## Manager Layer Implementation

### ResonateManager

**Responsibilities:**
- Own and manage ResonateKit client lifecycle
- Handle connection/disconnection to Resonate server
- Process incoming metadata and audio streams
- Manage playback state and volume control
- Notify other managers and UI of state changes

**Public Interface:**
```swift
@MainActor
class ResonateManager: ObservableObject {
    @Published var isConnected: Bool
    @Published var currentMetadata: TrackMetadata?
    @Published var connectionStatus: String
    @Published var volume: Float
    @Published var isMuted: Bool

    func connect(to server: ServerConfig)
    func disconnect()
    func setVolume(_ value: Float)
    func toggleMute()
}
```

**ResonateKit Integration:**
- Creates ResonateClient with player role
- Configures callbacks: `onConnected`, `onDisconnected`, `onMetadata`, `onError`, `onAudioData`
- Updates published properties on main thread
- Notifies MediaControlsManager when metadata changes

### MediaControlsManager

**Responsibilities:**
- Bridge to macOS Now Playing system (MPNowPlayingInfoCenter)
- Handle media key events (play/pause/next/previous)
- Update Lock Screen, Control Center, Touch Bar displays

**Public Interface:**
```swift
@MainActor
class MediaControlsManager {
    static let shared = MediaControlsManager()

    func updateNowPlaying(metadata: TrackMetadata, artwork: NSImage?)
    func clearNowPlaying()
}
```

**Implementation Details:**
- Wraps MPNowPlayingInfoCenter.default()
- Updates nowPlayingInfo dictionary with:
  - MPMediaItemPropertyTitle
  - MPMediaItemPropertyArtist
  - MPMediaItemPropertyAlbumTitle
  - MPMediaItemPropertyArtwork
  - MPMediaItemPropertyPlaybackDuration
- Sets up MPRemoteCommandCenter for media key handling

### SettingsManager

**Responsibilities:**
- Manage server configuration (auto-discovery + manual)
- Persist settings across app launches
- Provide observable settings state
- Validate user input

**Public Interface:**
```swift
@MainActor
class SettingsManager: ObservableObject {
    @Published var serverConfig: ServerConfig?
    @Published var enableAutoDiscovery: Bool

    func saveServerConfig(_ config: ServerConfig)
    func loadServerConfig() -> ServerConfig?
    func clearServerConfig()
}
```

**Implementation Details:**
- Uses UserDefaults or @AppStorage for persistence
- Validates hostname/IP format and port range (1-65535)
- Provides default values and configuration

## UI Layer Implementation

### ResonateReceiverApp

**Entry point** using SwiftUI App lifecycle:
```swift
@main
struct ResonateReceiverApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}
```

**AppDelegate** sets up menubar-only mode:
```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // Create MenuBarController
    }
}
```

### MenuBarController

**Responsibilities:**
- Create and manage NSStatusItem
- Show/hide popover on click
- Hold references to managers

**Implementation:**
- Creates NSStatusItem with SF Symbol icon ("waveform.circle")
- NSPopover with SwiftUI ContentView
- Passes managers to ContentView via initializer

### ContentView (Popover)

**Layout** (300-350px width):
1. **Header**: App icon + connection status (green dot indicator)
2. **Album Art Section**: Large album art (300x300), placeholder when not playing
3. **Metadata Section**: Track title, artist, album, duration/progress
4. **Controls Section**:
   - Volume slider with mute button
   - Connection status text
   - Settings button (shows sheet)
5. **Footer**: Quit button

**Design Principles:**
- Super native macOS appearance
- System fonts (SF Pro), proper text hierarchy
- Native controls and spacing
- Vibrancy effects for translucent backgrounds
- Automatic dark mode support via system colors
- macOS 14+ design language

### SettingsView (Sheet)

**Layout:**
- Toggle: "Enable auto-discovery"
- Manual server section (disabled when auto-discovery enabled):
  - TextField: "Server hostname/IP"
  - TextField: "Port" (default from protocol spec)
  - TextField: "Server name" (optional, display only)
- Save and Cancel buttons
- Current connection status display

**Validation:**
- Hostname/IP format checking
- Port range validation (1-65535)
- Inline error messages for invalid input

## Data Models

### ServerConfig
```swift
struct ServerConfig: Codable {
    let hostname: String
    let port: Int
    let name: String?
}
```

### TrackMetadata
```swift
struct TrackMetadata {
    let title: String?
    let artist: String?
    let album: String?
    let artwork: NSImage?
    let duration: TimeInterval?
}
```

## Error Handling & Edge Cases

### Connection Failures
- Display friendly error messages in ContentView status area
- Auto-retry with exponential backoff (ResonateManager)
- Manual "Retry" button in UI

### No Servers Found (Auto-Discovery)
- Show "Searching for servers..." with activity indicator
- After 10s timeout: "No servers found" message
- "Check Settings" button for manual configuration fallback

### Server Disconnects Mid-Playback
- Update UI to "Disconnected" status
- Stop updating Now Playing info
- Attempt automatic reconnection

### Missing Metadata/Album Art
- Placeholder image (SF Symbol "music.note")
- Default text: "Unknown Artist" / "Unknown Track"
- Graceful degradation - show available fields only

### Audio Playback Issues
- ResonateKit handles buffering/scheduling internally
- Log errors to console
- Display error status in UI

### Settings Validation
- Validate before saving
- Show inline error messages
- Prevent saving invalid configurations

## Project Structure

```
ResonateReceiver/
├── Sources/
│   ├── App/
│   │   ├── ResonateReceiverApp.swift      (@main entry)
│   │   └── AppDelegate.swift
│   ├── UI/
│   │   ├── MenuBarController.swift
│   │   ├── ContentView.swift
│   │   └── SettingsView.swift
│   ├── Managers/
│   │   ├── ResonateManager.swift
│   │   ├── MediaControlsManager.swift
│   │   └── SettingsManager.swift
│   └── Models/
│       ├── ServerConfig.swift
│       └── TrackMetadata.swift
├── Assets.xcassets/
│   └── (App icons, placeholders)
├── ResonateReceiver.entitlements
└── ResonateReceiver.xcodeproj or Package.swift
```

## Dependencies

### External
- **ResonateKit** - Swift Package from https://github.com/harperreed/ResonateKit
  - Provides ResonateClient, discovery, protocol implementation
  - Handles audio streaming and synchronization

### System Frameworks
- **AppKit** - NSStatusItem, NSPopover, menubar integration
- **SwiftUI** - UI layer implementation
- **MediaPlayer** - MPNowPlayingInfoCenter, MPRemoteCommandCenter
- **AVFoundation** - Audio playback (via ResonateKit)

## Testing Strategy

### Unit Tests
- **SettingsManager**: Persistence, validation, default values
- **ResonateManager**: State management, mock ResonateKit client
- **ServerConfig**: Validation logic, encoding/decoding

### Integration Tests
- Connection flow with mocked server
- Metadata flow through managers to UI
- Settings changes triggering reconnection

### Manual Testing
- Connect to real Resonate server
- Verify playback and synchronization
- Test metadata display with various track info
- Verify media controls (Lock Screen, media keys)
- Test settings persistence across launches
- Validate error handling scenarios

## Build Configuration

- **Deployment Target**: macOS 14.0+
- **Xcode**: 15+
- **Swift Version**: 6.0
- **Bundle Identifier**: com.harperreed.ResonateReceiver
- **Entitlements**:
  - Network client (for Resonate server connection)
  - Audio input/output
  - App sandbox

## Success Criteria

1. **Functional**: Successfully receives and plays audio from Resonate server
2. **User Experience**: Native macOS look and feel, smooth interactions
3. **Integration**: Media keys, Lock Screen, Control Center all working
4. **Reliability**: Handles connection issues gracefully
5. **Showcase**: Clean, well-organized code demonstrating ResonateKit best practices
6. **Personal Use**: Stable enough for daily multi-room audio use

## Future Enhancements (Out of Scope)

- Multiple server support
- Room/group management
- Playback controls (if Resonate protocol adds support)
- Audio output device selection
- Equalizer or audio effects
- Playlist management
- Cross-fade or gapless playback options
