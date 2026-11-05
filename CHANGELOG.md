# Changelog

## 3.1.0 — 2026-11-05

Recovery for four ways a live playback could go wrong on iOS: an outage
shown as "ended" when the playlist ended first, a match shown as ended while
still live, a playback that freezes for good, and a player stuck in
buffering while the video plays. No breaking changes: one
new option (`PlayerOptions.stuckReload`, on by default) and one new stat
(`PlaybackStats.stuckReloads`).

- A stream that ended without a reason (the playlist's `#EXT-X-ENDLIST`,
  or the staleness watchdog) now takes the server's reason when the live-state
  push brings one, and `.ended` fires again with it. Before, only an
  `interrupted` end could be refined, so an outage that the playlist ended
  first read "This stream has ended" instead of "Reconnecting" until the
  rejoin. A finished match is still never downgraded, and a server end with
  no reason after `interrupted` still reads as a real end.
- A live playlist that stops advancing (the staleness watchdog, 30 s) while
  the pushed live state still says `live`, and showed life in the last 60 s,
  now reloads at the live edge instead of ending the stream. Before, the
  viewer was left on the end card while the match played on. The player
  sends a `.warning` (`UNAVAILABLE`) and the QoE beacons record a non-fatal
  error. At most two reloads per 10 minutes; the next watchdog end ends the
  stream as before. A playlist that ends with `#EXT-X-ENDLIST`, or a push
  that says anything but `live`, still ends it.
- A live playback that freezes for good (playhead and buffer both still for
  8 s while it is trying to play) now reloads at the live edge. AVFoundation
  can wedge like this and stay in buffering forever; on iPhone Safari, the
  same engine, it happened 2.31 times per watch-hour and never recovered on
  its own. Only after the first frame, online and in the foreground. At most
  twice; 30 s of playing refunds it. The player sends a `.warning`
  (`UNAVAILABLE`), the QoE beacons record a non-fatal error, and
  `PlaybackStats.stuckReloads` counts it. Off with
  `PlayerOptions(stuckReload: false)`.
- `buffering` now tracks what the viewer sees. AVFoundation can post
  `PlaybackStalled` while playback carries on (still playing, still likely
  to keep up), and nothing would then leave `buffering`: the player booked
  phantom rebuffer time and showed the loading spinner over playing video.
  Such a stall is now ignored (it doesn't count in `stallCount`), and
  `buffering` also ends once AVPlayer reports playing and the playhead has
  moved 0.25 s from where it began.

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
