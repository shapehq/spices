// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spices",
    platforms: [.iOS(.v15), .visionOS(.v1)],
    products: [
        .library(name: "Spices", targets: ["Spices"])
    ],
    targets: [
        .target(name: "Spices"),
        .testTarget(name: "SpicesTests", dependencies: [
            "Spices"
        ])
    ]
)
