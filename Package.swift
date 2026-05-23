// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlipClockKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "FlipClockKit",
            targets: ["FlipClockKit"]
        ),
    ],
    targets: [
        .target(
            name: "FlipClockKit",
            path: "Sources/FlipClockKit"
        ),
        .testTarget(
            name: "FlipClockKitTests",
            dependencies: ["FlipClockKit"],
            path: "Tests/FlipClockKitTests"
        ),
    ]
)
