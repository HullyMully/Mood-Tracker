// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MoodTracker",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MoodTracker",
            targets: ["MoodTracker"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "MoodTracker",
            dependencies: ["Core"],
            path: "Sources/App"
        ),
        .target(
            name: "Core",
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        )
    ]
) 