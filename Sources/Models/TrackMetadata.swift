// ABOUTME: Track metadata model from Resonate server
// ABOUTME: Represents currently playing track information

import Foundation

public struct TrackMetadata: Equatable, Sendable {
    public let title: String?
    public let artist: String?
    public let album: String?
    public let duration: TimeInterval?
    public let artworkUrl: String?

    public init(title: String?, artist: String?, album: String?, duration: TimeInterval?, artworkUrl: String? = nil) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.artworkUrl = artworkUrl
    }

    public var displayTitle: String {
        title ?? "Unknown Track"
    }

    public var displayArtist: String {
        artist ?? "Unknown Artist"
    }

    public var displayAlbum: String {
        album ?? "Unknown Album"
    }
}
