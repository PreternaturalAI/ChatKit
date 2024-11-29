// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "ChatKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ChatKit",
            targets: [
                "ChatKitCore",
                "ChatKit"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
        .package(url: "https://github.com/SwiftUIX/SwiftUIZ.git", branch: "main"),
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master")
    ],
    targets: [
        .target(
            name: "ChatKitCore",
            dependencies: [
                "CorePersistence",
                .product(name: "MarkdownUI", package: "SwiftUIZ"),
                "Swallow",
                "SwiftUIX",
                "SwiftUIZ",
            ],
            path: "Sources/ChatKitCore"
        ),
        .target(
            name: "ChatKit",
            dependencies: [
                "ChatKitCore",
                "SwiftUIX",
            ],
            path: "Sources/ChatKit"
        )
    ]
)
