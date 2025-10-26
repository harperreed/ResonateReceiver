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
            name: "ResonateReceiver",
            dependencies: ["ResonateKit"],
            path: "Sources/Models"
        ),
        .executableTarget(
            name: "ResonateReceiverApp",
            dependencies: ["ResonateReceiver"],
            path: "Sources/App"
        ),
        .executableTarget(
            name: "ResonateReceiverTests",
            dependencies: ["ResonateReceiver"],
            path: "Tests/Models",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-no_application_extension"])
            ]
        )
    ]
)
