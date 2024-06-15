// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "NetworkComposeImp",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "NetworkComposeImp",
      targets: ["NetworkComposeImp"]),
  ],
  dependencies: [
    .package(name: "NetworkCompose", path: "../interfaces"),
    .package(name: "NetworkComposeMock", path: "../mocks"),
  ],
  targets: [
    .target(
      name: "NetworkComposeImp",
      dependencies: [
        "NetworkCompose",
      ],
      path: "src"),
    .testTarget(
      name: "NetworkComposeImpTests",
      dependencies: [
        "NetworkComposeImp",
        "NetworkComposeMock",
      ],
      path: "Tests"),
  ],
  swiftLanguageVersions: [.v5])
