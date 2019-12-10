// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "BAFluidView",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "BAFluidView",
            targets: ["BAFluidView"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BAFluidView",
            dependencies: []
        )
    ]
)
