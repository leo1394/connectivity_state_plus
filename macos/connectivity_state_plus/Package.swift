// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "connectivity_state_plus",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "connectivity_state_plus", targets: ["connectivity_state_plus"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "connectivity_state_plus",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
