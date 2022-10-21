// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SerialDSL",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "SerialDSL",
      type: .dynamic,
      targets: ["SerialDSL"]
    ),
    .executable(name: "Serial", targets: ["Serial"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
//    .package(url: "https://github.com/apple/swift-package-manager", branch: "main"),
    .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.2.7"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "SerialDSL",
      dependencies: []
    ),
    .executableTarget(
      name: "Serial",
      dependencies: [
        "SerialDSL",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
      ]
    ),
    .testTarget(
      name: "SerialDSLTests",
      dependencies: ["SerialDSL"]
    ),
  ]
)
