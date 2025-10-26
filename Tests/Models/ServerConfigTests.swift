// ABOUTME: Unit tests for ServerConfig model
// ABOUTME: Tests validation, encoding/decoding, and default values

import Foundation
@testable import ResonateReceiver

// Simple test runner since XCTest is not available in CommandLineTools SDK
func testCodable() throws {
    let config = ServerConfig(
        hostname: "192.168.1.100",
        port: 8080,
        name: "Living Room"
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(config)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ServerConfig.self, from: data)

    assert(decoded.hostname == "192.168.1.100", "Hostname should match")
    assert(decoded.port == 8080, "Port should match")
    assert(decoded.name == "Living Room", "Name should match")
    print("✓ testCodable passed")
}

func testPortValidation() {
    assert(ServerConfig.isValidPort(8080) == true, "8080 should be valid")
    assert(ServerConfig.isValidPort(1) == true, "1 should be valid")
    assert(ServerConfig.isValidPort(65535) == true, "65535 should be valid")
    assert(ServerConfig.isValidPort(0) == false, "0 should be invalid")
    assert(ServerConfig.isValidPort(65536) == false, "65536 should be invalid")
    assert(ServerConfig.isValidPort(-1) == false, "-1 should be invalid")
    print("✓ testPortValidation passed")
}

// Run tests
do {
    try testCodable()
    testPortValidation()
    print("\n✅ All ServerConfig tests passed!")
} catch {
    print("\n❌ Test failed with error: \(error)")
    exit(1)
}
