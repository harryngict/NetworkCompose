// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "NetworkCompose",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "NetworkCompose",
            targets: ["NetworkCompose"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkCompose",
            path: "Sources/NetworkCompose"
        ),
        .testTarget(
            name: "NetworkComposeTests",
            dependencies: ["NetworkCompose"],
            path: "Tests/NetworkComposeTests"
        ),
    ]
)
