// ABOUTME: Manages persistent settings for server configuration
// ABOUTME: Handles UserDefaults storage and retrieval

import Foundation

class SettingsManager: ObservableObject {
    @Published var serverConfig: ServerConfig?
    @Published var enableAutoDiscovery: Bool = true

    private let defaults = UserDefaults.standard
    private let serverConfigKey = "resonateServerConfig"
    private let autoDiscoveryKey = "resonateAutoDiscovery"

    init() {
        loadSettings()
    }

    private func loadSettings() {
        serverConfig = loadServerConfig()

        // Check if the key exists first
        if defaults.object(forKey: autoDiscoveryKey) != nil {
            enableAutoDiscovery = defaults.bool(forKey: autoDiscoveryKey)
        } else {
            // Default to true if never set
            enableAutoDiscovery = true
        }
    }

    func saveServerConfig(_ config: ServerConfig) {
        if let encoded = try? JSONEncoder().encode(config) {
            defaults.set(encoded, forKey: serverConfigKey)
            serverConfig = config
        }
    }

    func loadServerConfig() -> ServerConfig? {
        guard let data = defaults.data(forKey: serverConfigKey),
              let config = try? JSONDecoder().decode(ServerConfig.self, from: data) else {
            return nil
        }
        return config
    }

    func clearServerConfig() {
        defaults.removeObject(forKey: serverConfigKey)
        serverConfig = nil
    }

    func setAutoDiscovery(_ enabled: Bool) {
        defaults.set(enabled, forKey: autoDiscoveryKey)
        enableAutoDiscovery = enabled
    }
}
