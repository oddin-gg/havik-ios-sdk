// swift-tools-version: 5.10
// Generated for HavikPlayer 3.0.0 by the havik-ios release workflow. Do not
// edit: the next release overwrites it.
import PackageDescription

let package = Package(
    name: "HavikPlayer",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "HavikPlayer", targets: ["HavikPlayer"]),
    ],
    targets: [
        .binaryTarget(
            name: "HavikPlayer",
            url: "https://github.com/oddin-gg/havik-ios-sdk/releases/download/v3.0.0/HavikPlayer.xcframework.zip",
            checksum: "ed32bd87fe0c5f50a1e5ecd419f3fe567d0d69281e46d8c656854d9cd2f68777"
        ),
    ]
)
