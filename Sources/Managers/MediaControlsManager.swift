// ABOUTME: Manages macOS Now Playing integration
// ABOUTME: Handles MPNowPlayingInfoCenter and media key events

import Foundation
import MediaPlayer
import AppKit

@MainActor
public class MediaControlsManager {
    public static let shared = MediaControlsManager()

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

    public func updateNowPlaying(metadata: TrackMetadata, artwork: NSImage?) {
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

    public func clearNowPlaying() {
        nowPlayingCenter.nowPlayingInfo = nil
    }
}
