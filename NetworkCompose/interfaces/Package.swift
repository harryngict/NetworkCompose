// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "NetworkCompose",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "NetworkCompose",
      targets: ["NetworkCompose"]),
  ],
  targets: [
    .target(
      name: "NetworkCompose",
      path: "src"),
  ],
  swiftLanguageVersions: [.v5])
