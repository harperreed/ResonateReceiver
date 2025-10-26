# Resonate MenuBar Receiver

A native macOS menubar application that receives synchronized audio from a Resonate server with rich metadata display and deep macOS media integration.

## Features

- Synchronized multi-room audio playback via Resonate
- Rich metadata display with album art
- Volume control with mute
- macOS media key integration
- Lock Screen / Control Center / Touch Bar support
- Auto-discovery and manual server configuration
- Super native macOS design

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
