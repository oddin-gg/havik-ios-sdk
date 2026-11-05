# Changelog

## 3.0.0 — 2026-11-05

The first release published as a binary Swift package, from the public
`oddin-gg/havik-ios-sdk` repository:

```swift
.package(url: "https://github.com/oddin-gg/havik-ios-sdk", from: "3.0.0")
```

Requires Xcode 26 and iOS 15 or later. The one breaking change is for
exhaustive `switch`es over `PlayerEvent` (two new cases, below).

Rides out a network loss:

- **Breaking for exhaustive `switch`es:** `PlayerEvent` has two new cases,
  `.offline` and `.online`. Handle them, or add `default:`.
- `HavikPlayer.isOffline`: the device reports no network route
  (`NWPathMonitor`; offline must hold 1 s, so a Wi-Fi/cellular handover does
  not count). Reliable in that direction only.
- When the route returns, a session that failed with `NETWORK`, or failed
  with a retryable code while offline, is retried automatically. Terminal
  codes never are; a stopped player stays stopped.
- A segment or playlist fetch that never got an answer (no internet,
  connection lost, timed out, DNS) now fails as `NETWORK`; it was `INTERNAL`.
  So does any item failure while offline.
- `HavikStatusOverlay` shows an offline card (no Retry) over loading,
  playback, buffering, waiting and failed while offline;
  `HavikStatusMessages.offline` sets its copy.
- An outage that interrupted playback reloads at the live edge when the
  route returns, instead of resuming the stale item (which played audio
  first, with video seconds behind). That covers a player still stalled at
  reconnect, or one AVFoundation stopped itself during the outage (it does
  after ~30 s offline, without failing the item). A pause the viewer or host
  made stays a pause; playback the buffer carried through is left alone.
- A live stream that fails while paused (its short window moves past the
  paused position after ~11 s; CoreMedia -12640) no longer fails the
  session: the player stays paused, sends a `.warning`, and the next play
  reloads at the live edge.
- `HavikPlayerView` resumes playback after AVKit's fullscreen is dismissed
  (AVKit pauses on the way out, by the Close button or a swipe) when it was
  playing as the dismissal began. A pause made inside fullscreen stays a
  pause.
- `HavikStatusOverlay` shows the ended card ("This stream has ended", or
  your `HavikStatusMessages.ended`) for a `GONE` failure, instead of the
  server's raw message (`match_has_ended`).
- **Privacy manifest.** The SDK now ships `PrivacyInfo.xcprivacy`, and Xcode
  merges it into your app's privacy report. It declares no tracking and no
  required-reason APIs, and these collected data types:
  - **Device ID** (the Keychain DRM device id), not linked, app functionality;
  - **User ID**, only if you set `PlayerOptions.userId`, linked, app functionality;
  - **Coarse Location**: country and network, derived by Oddin from the IP
    address of playback requests (geo restrictions, QoE by region), not
    linked, app functionality and analytics;
  - **Performance Data**, **Other Diagnostic Data** and **Product Interaction**
    (QoE beacons, off with `analyticsEnabled: false`), not linked, analytics.

  Use it for your App Store privacy labels.
- `HavikStatusOverlay` shows a spinner while the video loads or buffers and
  no card is up. It appears after 0.4 s, so a short rebuffer doesn't flash it,
  and it never takes taps from the player's controls. Before, a live match's
  ~3 s startup was a black frame: AVKit draws no indicator of its own there.
