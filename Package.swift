// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "Grain",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "GrainDescriptor",
      type: .dynamic,
      targets: ["GrainDescriptor"]
    ),
    .executable(name: "grain", targets: ["Grain", "GrainDescriptor"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
    .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.2.7"),
  ],
  targets: [
    .target(
      name: "GrainDescriptor",
      dependencies: [],
      swiftSettings: [
        .unsafeFlags(["-enable-library-evolution"])
      ]
    ),
    .executableTarget(
      name: "Grain",
      dependencies: [
        "GrainDescriptor",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
      ]
    ),
    .testTarget(
      name: "GrainDescriptorTests",
      dependencies: ["GrainDescriptor"]
    ),
  ]
)
