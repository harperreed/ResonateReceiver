// ABOUTME: Manages ResonateKit client and playback state
// ABOUTME: Handles connection lifecycle and metadata updates

import Foundation
import Combine

@MainActor
public class ResonateManager: ObservableObject {
    @Published public var isConnected: Bool = false
    @Published public var currentMetadata: TrackMetadata?
    @Published public var connectionStatus: String = "Disconnected"
    @Published public var volume: Float = 1.0
    @Published public var isMuted: Bool = false

    private let mediaControls = MediaControlsManager.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        // TODO: Initialize ResonateKit client when ready
    }

    public func connect(to server: ServerConfig) {
        // TODO: Implement ResonateKit connection
        connectionStatus = "Connecting to \(server.hostname):\(server.port)..."
    }

    public func disconnect() {
        // TODO: Implement ResonateKit disconnection
        isConnected = false
        connectionStatus = "Disconnected"
        currentMetadata = nil
        mediaControls.clearNowPlaying()
    }

    public func setVolume(_ value: Float) {
        volume = max(0.0, min(1.0, value))
        if isMuted {
            isMuted = false
        }
        // TODO: Apply to audio output
    }

    public func toggleMute() {
        isMuted.toggle()
        // TODO: Apply to audio output
    }

    // TODO: Call this method when ResonateKit provides metadata updates
    private func updateMetadata(_ metadata: TrackMetadata) {
        currentMetadata = metadata
        mediaControls.updateNowPlaying(metadata: metadata, artwork: nil)
    }
}
