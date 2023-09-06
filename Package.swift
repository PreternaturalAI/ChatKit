// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "ChatKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "ChatKit",
            targets: [
                "ChatKit"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master")
    ],
    targets: [
        .target(
            name: "ChatKit",
            dependencies: [
                "CorePersistence",
                "Swallow",
                "SwiftUIX"
            ],
            path: "Sources"
        )
    ]
)
