// ABOUTME: Manages ResonateKit client and playback state
// ABOUTME: Handles connection lifecycle and metadata updates

import Foundation
import Combine
import ResonateKit
import UserNotifications

@MainActor
public class ResonateManager: ObservableObject {
    @Published public var isConnected: Bool = false
    @Published public var currentMetadata: TrackMetadata?
    @Published public var connectionStatus: String = "Disconnected"
    @Published public var volume: Float = 1.0
    @Published public var isMuted: Bool = false

    private let mediaControls = MediaControlsManager.shared
    private var cancellables = Set<AnyCancellable>()

    private var client: ResonateClient?
    private var eventTask: Task<Void, Never>?
    private var notificationPermissionRequested = false

    public init() {
        print("🟢 ResonateManager: init")
    }

    private func showTrackNotification(metadata: TrackMetadata) {
        let center = UNUserNotificationCenter.current()

        // Request permission if not already requested
        if !notificationPermissionRequested {
            notificationPermissionRequested = true
            center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("🔴 ResonateManager: Notification permission error: \(error)")
                    return
                }
                if granted {
                    print("🟢 ResonateManager: Notification permission granted")
                    self.postNotification(metadata: metadata)
                }
            }
        } else {
            center.getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    self.postNotification(metadata: metadata)
                }
            }
        }
    }

    private func postNotification(metadata: TrackMetadata) {
        let content = UNMutableNotificationContent()
        content.title = metadata.title ?? "Unknown Track"
        if let artist = metadata.artist {
            content.body = artist
        }
        if let album = metadata.album, content.body.isEmpty {
            content.body = album
        } else if let album = metadata.album {
            content.body += " • \(album)"
        }
        content.sound = .default

        // Try to attach artwork if available
        if let artworkUrlString = metadata.artworkUrl,
           let artworkUrl = URL(string: artworkUrlString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: artworkUrl)
                    let tempDir = FileManager.default.temporaryDirectory
                    let imageFile = tempDir.appendingPathComponent(UUID().uuidString + ".jpg")
                    try data.write(to: imageFile)

                    let attachment = try UNNotificationAttachment(identifier: "artwork", url: imageFile)
                    content.attachments = [attachment]

                    let request = UNNotificationRequest(
                        identifier: UUID().uuidString,
                        content: content,
                        trigger: nil
                    )

                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("🔴 ResonateManager: Failed to show notification: \(error)")
                        }
                        // Clean up temp file
                        try? FileManager.default.removeItem(at: imageFile)
                    }
                } catch {
                    print("🔴 ResonateManager: Failed to download artwork: \(error)")
                    // Fall back to notification without artwork
                    self.sendNotificationWithoutArtwork(content: content)
                }
            }
        } else {
            sendNotificationWithoutArtwork(content: content)
        }
    }

    private func sendNotificationWithoutArtwork(content: UNMutableNotificationContent) {
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("🔴 ResonateManager: Failed to show notification: \(error)")
            }
        }
    }

    public func connect(to server: ServerConfig) {
        print("🟢 ResonateManager: connect to \(server.hostname):\(server.port)")
        connectionStatus = "Connecting to \(server.hostname):\(server.port)..."

        Task {
            do {
                // Create URL from server config
                let urlString = "ws://\(server.hostname):\(server.port)/resonate"
                guard let url = URL(string: urlString) else {
                    print("🔴 ResonateManager: Invalid URL: \(urlString)")
                    await MainActor.run {
                        connectionStatus = "Error: Invalid server URL"
                    }
                    return
                }

                // Create player configuration
                let config = PlayerConfiguration(
                    bufferCapacity: 2_097_152, // 2MB buffer
                    supportedFormats: [
                        AudioFormatSpec(codec: .pcm, channels: 2, sampleRate: 48000, bitDepth: 16)
                    ]
                )

                // Create client
                let client = ResonateClient(
                    clientId: UUID().uuidString,
                    name: server.name ?? "Resonate Receiver",
                    roles: [.player, .metadata],
                    playerConfig: config
                )
                self.client = client
                print("🟢 ResonateManager: ResonateClient created")

                // Start event monitoring
                eventTask = Task {
                    await monitorEvents(client: client)
                }

                // Connect to server
                print("🟢 ResonateManager: Connecting to \(url)...")
                try await client.connect(to: url)
                print("🟢 ResonateManager: Connected!")

                await MainActor.run {
                    isConnected = true
                    connectionStatus = "Connected to \(server.name ?? server.hostname)"
                }
            } catch {
                print("🔴 ResonateManager: Connection failed: \(error)")
                await MainActor.run {
                    isConnected = false
                    connectionStatus = "Connection failed: \(error.localizedDescription)"
                }
            }
        }
    }

    public func disconnect() {
        print("🟢 ResonateManager: disconnect")

        Task {
            await client?.disconnect()
            eventTask?.cancel()
            eventTask = nil
            client = nil

            await MainActor.run {
                isConnected = false
                connectionStatus = "Disconnected"
                currentMetadata = nil
                mediaControls.clearNowPlaying()
            }
        }
    }

    public func setVolume(_ value: Float) {
        volume = max(0.0, min(1.0, value))
        if isMuted {
            isMuted = false
        }

        Task {
            await client?.setVolume(volume)
        }
    }

    public func toggleMute() {
        isMuted.toggle()

        Task {
            await client?.setMute(isMuted)
        }
    }

    private func monitorEvents(client: ResonateClient) async {
        print("🟢 ResonateManager: Starting event monitoring")

        for await event in client.events {
            await MainActor.run {
                handleEvent(event)
            }
        }

        print("🟢 ResonateManager: Event monitoring ended")
    }

    private func handleEvent(_ event: ClientEvent) {
        switch event {
        case let .serverConnected(info):
            print("🟢 ResonateManager: Server connected: \(info.name) v\(info.version)")
            connectionStatus = "Connected to \(info.name)"
            isConnected = true

        case let .streamStarted(format):
            let formatStr = "\(format.codec.rawValue) \(format.sampleRate)Hz \(format.channels)ch \(format.bitDepth)bit"
            print("🟢 ResonateManager: Stream started: \(formatStr)")

        case .streamEnded:
            print("🟢 ResonateManager: Stream ended")

        case let .groupUpdated(info):
            print("🟢 ResonateManager: Group updated: \(info.groupName)")

        case let .metadataReceived(metadata):
            print("🟢 ResonateManager: Metadata received: \(metadata.title ?? "unknown")")
            if let artworkUrl = metadata.artworkUrl {
                print("🟢 ResonateManager: Artwork URL: \(artworkUrl)")
            }
            // Convert ResonateKit.TrackMetadata to our TrackMetadata
            let trackMetadata = TrackMetadata(
                title: metadata.title,
                artist: metadata.artist,
                album: metadata.album,
                duration: metadata.duration.map { TimeInterval($0) },
                artworkUrl: metadata.artworkUrl
            )
            currentMetadata = trackMetadata
            mediaControls.updateNowPlaying(metadata: trackMetadata, artwork: nil)

            // Show notification for track change
            showTrackNotification(metadata: trackMetadata)

        case let .artworkReceived(channel, data):
            print("🟢 ResonateManager: Artwork received on channel \(channel): \(data.count) bytes")
            // TODO: Convert artwork data to NSImage and update media controls

        case let .visualizerData(data):
            print("🟢 ResonateManager: Visualizer data: \(data.count) bytes")

        case let .error(message):
            print("🔴 ResonateManager: Error: \(message)")
            connectionStatus = "Error: \(message)"
        }
    }
}
