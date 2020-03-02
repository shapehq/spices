// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SHPSpices",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "SHPSpices", targets: ["SHPSpices"])
    ],
    targets: [
        .target(
            name: "SHPSpices",
            path: "SHPSpices",
            sources: ["Source"])
    ]
)
