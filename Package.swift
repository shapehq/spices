// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SHPSpices",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SHPSpices", targets: ["SHPSpices"])
    ],
    targets: [
        .target(name: "SHPSpices"),
        .testTarget(name: "SHPSpicesTests", dependencies: [
            "SHPSpices"
        ])
    ]
)
