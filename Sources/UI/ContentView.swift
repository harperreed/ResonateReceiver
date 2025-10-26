// ABOUTME: Main popover UI showing connection status and playback info
// ABOUTME: Displays album art, metadata, controls, and settings access

import SwiftUI

public struct ContentView: View {
    @ObservedObject var resonateManager: ResonateManager
    @ObservedObject var settingsManager: SettingsManager
    @State private var showingSettings = false

    public init(resonateManager: ResonateManager, settingsManager: SettingsManager) {
        self.resonateManager = resonateManager
        self.settingsManager = settingsManager
    }

    public var body: some View {
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
            if let artworkUrl = resonateManager.currentMetadata?.artworkUrl,
               let url = URL(string: artworkUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 300, height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                            .cornerRadius(8)
                    case .failure:
                        placeholderArtwork
                    @unknown default:
                        placeholderArtwork
                    }
                }
            } else {
                placeholderArtwork
            }

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

    private var placeholderArtwork: some View {
        Image(systemName: "music.note")
            .font(.system(size: 120))
            .foregroundColor(.secondary)
            .frame(width: 300, height: 300)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
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

            // Show connect button based on configuration mode
            if settingsManager.enableAutoDiscovery {
                // Auto-discovery mode - no manual connect button yet
                // TODO: Show discovered servers list when ResonateKit integration is complete
                Text("Auto-discovery enabled\nConfigure manually in Settings if needed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            } else if let serverConfig = settingsManager.serverConfig {
                // Manual mode with server configured
                Button("Connect to \(serverConfig.name ?? serverConfig.hostname)") {
                    resonateManager.connect(to: serverConfig)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            } else {
                // Manual mode but no server configured
                Text("Configure a server in Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 8)
            }
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
                .opacity(resonateManager.isMuted ? 0.5 : 1.0)

                Text(resonateManager.isMuted ? "Muted" : "\(Int(resonateManager.volume * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }

            // Settings and disconnect buttons
            HStack {
                Button("Settings") {
                    showingSettings = true
                }
                .buttonStyle(.bordered)

                if resonateManager.isConnected {
                    Button("Disconnect") {
                        resonateManager.disconnect()
                    }
                    .buttonStyle(.bordered)
                }
            }
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
