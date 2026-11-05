// swift-tools-version: 5.10
// Generated for HavikPlayer 3.1.0 by the havik-ios release workflow. Do not
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
            url: "https://github.com/oddin-gg/havik-ios-sdk/releases/download/v3.1.0/HavikPlayer.xcframework.zip",
            checksum: "c0c94e58a6505238d76f7965d31c066b2da6310e08992a49cd47ad0fc23bfe80"
        ),
    ]
)
