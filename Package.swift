// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "Grain",
  platforms: [
    .macOS(.v12),
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
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.2"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1")
  ],
  targets: [
    .target(
      name: "GrainDescriptor",
      dependencies: [
        "Yams",
        "Alamofire",
        .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
      ],
      swiftSettings: [
//        .unsafeFlags(["-enable-library-evolution"])
      ]
    ),
    .executableTarget(
      name: "Grain",
      dependencies: [
        "GrainDescriptor",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
      ]
    ),
    .testTarget(
      name: "GrainDescriptorTests",
      dependencies: ["GrainDescriptor"]
    ),
  ]
)
