// ABOUTME: Unit tests for SettingsManager
// ABOUTME: Tests settings persistence and retrieval

import Foundation
@testable import ResonateReceiver

// NOTE: Custom test runner approach used due to CommandLineTools SDK limitations
// XCTest is not available in the CommandLineTools SDK, so we use simple assert-based
// tests with a manual runner. Tests are executed during build and fail the build on errors.

func testSaveAndLoad() {
    let manager = SettingsManager()
    let config = ServerConfig(
        hostname: "test.local",
        port: 8080,
        name: "Test Server"
    )

    manager.saveServerConfig(config)
    let loaded = manager.loadServerConfig()

    assert(loaded == config, "Loaded config should match saved config")
    print("✓ testSaveAndLoad passed")
}

func testClear() {
    let manager = SettingsManager()
    let config = ServerConfig(hostname: "test.local", port: 8080, name: nil)

    manager.saveServerConfig(config)
    manager.clearServerConfig()
    let loaded = manager.loadServerConfig()

    assert(loaded == nil, "Config should be nil after clearing")
    print("✓ testClear passed")
}

func testAutoDiscovery() {
    let manager = SettingsManager()

    manager.setAutoDiscovery(false)
    let enabled = manager.enableAutoDiscovery

    assert(enabled == false, "Auto-discovery should be disabled")
    print("✓ testAutoDiscovery passed")
}

func runSettingsManagerTests() {
    testSaveAndLoad()
    testClear()
    testAutoDiscovery()
    print("✅ All SettingsManager tests passed!")
}
