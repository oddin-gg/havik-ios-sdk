# HavikPlayer for iOS

The iOS player SDK for Oddin live streams: Low-Latency HLS with FairPlay DRM,
on AVPlayer. This repository distributes the SDK as a binary package for Swift
Package Manager.

## Install

In Xcode, **File > Add Package Dependencies…**, enter
`https://github.com/oddin-gg/havik-ios-sdk`, then add the **HavikPlayer**
library to your app target. Or, in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/oddin-gg/havik-ios-sdk", from: "3.0.0"),
]
```

Requires iOS 15 or later and Xcode 26 or later. This package is version 3.0.0.

## Documentation

- Guide: https://player.oddin-video.gg/guide/ios
- API reference: https://player.oddin-video.gg/api/ios
- Changes: [CHANGELOG.md](CHANGELOG.md)

The SDK ships a privacy manifest (`PrivacyInfo.xcprivacy`). Xcode includes it
in your app's privacy report.

## License

ISC, see [LICENSE](LICENSE).
