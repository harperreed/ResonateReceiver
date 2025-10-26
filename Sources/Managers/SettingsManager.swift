// ABOUTME: Manages persistent settings for server configuration
// ABOUTME: Handles UserDefaults storage and retrieval

import Foundation

@MainActor
public class SettingsManager: ObservableObject {
    @Published public var serverConfig: ServerConfig?
    @Published public var enableAutoDiscovery: Bool = false

    private let defaults = UserDefaults.standard
    private let serverConfigKey = "resonateServerConfig"
    private let autoDiscoveryKey = "resonateAutoDiscovery"

    public init() {
        loadSettings()
    }

    private func loadSettings() {
        serverConfig = loadServerConfig()

        // Check if the key exists first
        if defaults.object(forKey: autoDiscoveryKey) != nil {
            enableAutoDiscovery = defaults.bool(forKey: autoDiscoveryKey)
        } else {
            // Default to false (manual mode) until auto-discovery is fully integrated
            enableAutoDiscovery = false
        }
    }

    public func saveServerConfig(_ config: ServerConfig) {
        if let encoded = try? JSONEncoder().encode(config) {
            defaults.set(encoded, forKey: serverConfigKey)
            serverConfig = config
        }
    }

    public func loadServerConfig() -> ServerConfig? {
        guard let data = defaults.data(forKey: serverConfigKey),
              let config = try? JSONDecoder().decode(ServerConfig.self, from: data) else {
            return nil
        }
        return config
    }

    public func clearServerConfig() {
        defaults.removeObject(forKey: serverConfigKey)
        serverConfig = nil
    }

    public func setAutoDiscovery(_ enabled: Bool) {
        defaults.set(enabled, forKey: autoDiscoveryKey)
        enableAutoDiscovery = enabled
    }
}
