// ABOUTME: Settings dialog for server configuration
// ABOUTME: Allows manual server entry and auto-discovery toggle

import SwiftUI

public struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss

    @State private var hostname: String = ""
    @State private var port: String = "8080"
    @State private var serverName: String = ""
    @State private var enableAutoDiscovery: Bool = true
    @State private var validationError: String?
    @State private var originalAutoDiscovery: Bool = true

    public init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Server Settings")
                .font(.title2)
                .fontWeight(.semibold)

            Divider()

            // Auto-discovery toggle
            Toggle("Enable auto-discovery", isOn: $enableAutoDiscovery)
                .onChange(of: enableAutoDiscovery) { _, newValue in
                    settingsManager.setAutoDiscovery(newValue)
                }

            // Manual server configuration
            GroupBox("Manual Server Configuration") {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Hostname or IP", text: $hostname)
                        .textFieldStyle(.roundedBorder)
                        .disabled(enableAutoDiscovery)

                    TextField("Port", text: $port)
                        .textFieldStyle(.roundedBorder)
                        .disabled(enableAutoDiscovery)

                    TextField("Server Name (optional)", text: $serverName)
                        .textFieldStyle(.roundedBorder)
                        .disabled(enableAutoDiscovery)

                    if let error = validationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 8)
            }
            .disabled(enableAutoDiscovery)

            Spacer()

            // Buttons
            HStack {
                Button("Cancel") {
                    // Restore original auto-discovery setting
                    settingsManager.setAutoDiscovery(originalAutoDiscovery)
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveSettings()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(enableAutoDiscovery || hostname.isEmpty || port.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 350)
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        enableAutoDiscovery = settingsManager.enableAutoDiscovery
        originalAutoDiscovery = settingsManager.enableAutoDiscovery

        if let config = settingsManager.serverConfig {
            hostname = config.hostname
            port = String(config.port)
            serverName = config.name ?? ""
        }
    }

    private func validateAndSave() -> Bool {
        validationError = nil

        guard !hostname.isEmpty else {
            validationError = "Hostname is required"
            return false
        }

        guard let portInt = Int(port), ServerConfig.isValidPort(portInt) else {
            validationError = "Port must be between 1 and 65535"
            return false
        }

        let config = ServerConfig(
            hostname: hostname,
            port: portInt,
            name: serverName.isEmpty ? nil : serverName
        )

        settingsManager.saveServerConfig(config)
        return true
    }

    private func saveSettings() {
        guard validateAndSave() else { return }
        dismiss()
    }
}
