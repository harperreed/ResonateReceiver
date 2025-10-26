// ABOUTME: Server configuration model for Resonate server connection
// ABOUTME: Handles validation and persistence of server settings

import Foundation

public struct ServerConfig: Codable, Equatable {
    public let hostname: String
    public let port: Int
    public let name: String?

    public init(hostname: String, port: Int, name: String?) {
        self.hostname = hostname
        self.port = port
        self.name = name
    }

    public static func isValidPort(_ port: Int) -> Bool {
        return port >= 1 && port <= 65535
    }
}
