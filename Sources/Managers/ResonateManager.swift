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
