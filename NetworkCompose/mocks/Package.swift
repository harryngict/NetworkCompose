// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "NetworkComposeMock",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "NetworkComposeMock",
      targets: ["NetworkComposeMock"]),
  ],
  dependencies: [
    .package(name: "NetworkCompose", path: "../interfaces"),
  ],
  targets: [
    .target(
      name: "NetworkComposeMock",
      dependencies: ["NetworkCompose"],
      path: "src"),
  ],
  swiftLanguageVersions: [.v5])
