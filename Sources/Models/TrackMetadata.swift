// ABOUTME: Track metadata model from Resonate server
// ABOUTME: Represents currently playing track information

import Foundation

public struct TrackMetadata: Equatable {
    public let title: String?
    public let artist: String?
    public let album: String?
    public let duration: TimeInterval?

    public init(title: String?, artist: String?, album: String?, duration: TimeInterval?) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
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
