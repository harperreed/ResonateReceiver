// ABOUTME: Unit tests for TrackMetadata model
// ABOUTME: Tests display properties with nil/actual values and Equatable conformance

import Foundation
@testable import ResonateReceiverLib

// NOTE: Custom test runner approach used due to CommandLineTools SDK limitations
// XCTest is not available in the CommandLineTools SDK, so we use simple assert-based
// tests with a manual runner. Tests are executed during build and fail the build on errors.

func testDisplayPropertiesWithNilValues() {
    let metadata = TrackMetadata(
        title: nil,
        artist: nil,
        album: nil,
        duration: nil
    )

    assert(metadata.displayTitle == "Unknown Track", "displayTitle should return 'Unknown Track' when title is nil")
    assert(metadata.displayArtist == "Unknown Artist", "displayArtist should return 'Unknown Artist' when artist is nil")
    assert(metadata.displayAlbum == "Unknown Album", "displayAlbum should return 'Unknown Album' when album is nil")
    print("✓ testDisplayPropertiesWithNilValues passed")
}

func testDisplayPropertiesWithActualValues() {
    let metadata = TrackMetadata(
        title: "Song Title",
        artist: "Artist Name",
        album: "Album Name",
        duration: 180.0
    )

    assert(metadata.displayTitle == "Song Title", "displayTitle should return actual title")
    assert(metadata.displayArtist == "Artist Name", "displayArtist should return actual artist")
    assert(metadata.displayAlbum == "Album Name", "displayAlbum should return actual album")
    print("✓ testDisplayPropertiesWithActualValues passed")
}

func testEquatableConformance() {
    let metadata1 = TrackMetadata(
        title: "Song Title",
        artist: "Artist Name",
        album: "Album Name",
        duration: 180.0
    )

    let metadata2 = TrackMetadata(
        title: "Song Title",
        artist: "Artist Name",
        album: "Album Name",
        duration: 180.0
    )

    let metadata3 = TrackMetadata(
        title: "Different Song",
        artist: "Artist Name",
        album: "Album Name",
        duration: 180.0
    )

    assert(metadata1 == metadata2, "Identical metadata should be equal")
    assert(metadata1 != metadata3, "Different metadata should not be equal")
    print("✓ testEquatableConformance passed")
}

func runTrackMetadataTests() {
    testDisplayPropertiesWithNilValues()
    testDisplayPropertiesWithActualValues()
    testEquatableConformance()
    print("✅ All TrackMetadata tests passed!")
}
