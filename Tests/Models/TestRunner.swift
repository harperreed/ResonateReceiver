// ABOUTME: Main test runner for all model tests
// ABOUTME: Executes all test suites and reports results

import Foundation
@testable import ResonateReceiverLib

// NOTE: Custom test runner approach used due to CommandLineTools SDK limitations
// XCTest is not available in the CommandLineTools SDK, so we use simple assert-based
// tests with a manual runner. Tests are executed during build and fail the build on errors.

@main
struct TestRunner {
    @MainActor
    static func main() {
        print("Running all tests...\n")

        do {
            try runServerConfigTests()
            runTrackMetadataTests()
            runSettingsManagerTests()
            print("\n✅ All tests passed!")
        } catch {
            print("\n❌ Test failed with error: \(error)")
            exit(1)
        }
    }
}
