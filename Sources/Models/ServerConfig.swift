// ABOUTME: Server configuration model for Resonate server connection
// ABOUTME: Handles validation and persistence of server settings

import Foundation

struct ServerConfig: Codable, Equatable {
    let hostname: String
    let port: Int
    let name: String?

    static func isValidPort(_ port: Int) -> Bool {
        return port >= 1 && port <= 65535
    }
}
