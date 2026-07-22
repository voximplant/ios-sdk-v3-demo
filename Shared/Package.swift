// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "CommonUI",
            targets: ["CommonUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/voximplant/ios-sdk-releases.git", .upToNextMinor(from: "3.3.0")),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.63.2"),
    ],
    targets: [
        .target(
            name: "CommonUI",
            dependencies: [
                .product(name: "VoximplantCore", package: "ios-sdk-releases"),
            ],
            resources: [.process("Resources/Assets.xcassets")],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
