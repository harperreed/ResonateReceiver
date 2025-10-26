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
            targets: ["ResonateReceiverApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/harperreed/ResonateKit", branch: "main")
    ],
    targets: [
        .target(
            name: "ResonateReceiverLib",
            dependencies: ["ResonateKit"],
            path: "Sources",
            exclude: ["App"]
        ),
        .executableTarget(
            name: "ResonateReceiverApp",
            dependencies: ["ResonateReceiverLib"],
            path: "Sources/App"
        ),
        .executableTarget(
            name: "ResonateReceiverTests",
            dependencies: ["ResonateReceiverLib"],
            path: "Tests"
        )
    ]
)
