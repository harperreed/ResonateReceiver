// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ResonateReceiver",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ResonateReceiver",
            targets: ["ResonateReceiver"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/harperreed/ResonateKit", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "ResonateReceiver",
            dependencies: ["ResonateKit"],
            path: "Sources"
        ),
        .testTarget(
            name: "ResonateReceiverTests",
            dependencies: ["ResonateReceiver"],
            path: "Tests"
        )
    ]
)
