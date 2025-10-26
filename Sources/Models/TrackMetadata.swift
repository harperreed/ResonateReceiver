// ABOUTME: Track metadata model from Resonate server
// ABOUTME: Represents currently playing track information

import Foundation

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
