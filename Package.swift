// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StreamBuilder",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StreamBuilder",
            targets: ["StreamBuilder"]),
    ],
    targets: [
        .target(name: "StreamBuilder",
            swiftSettings: [
                .enableExperimentalFeature("PackIteration"),
            ]
        ),
        .testTarget(name: "StreamBuilderTests",
            dependencies: ["StreamBuilder"],
            swiftSettings: [
                .enableExperimentalFeature("PackIteration"),
            ]
        )
    ]
)

