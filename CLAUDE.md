# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Example iOS app (UIKit, Swift, Storyboard-based) demonstrating the VideoSDK RTC iOS SDK — video/audio meetings with chat, screen sharing, recording, livestream/HLS, and realtime store features.

## Build

There are no tests or lint configs in this project. Dependencies are managed via Swift Package Manager (the README's `pod install` step and the CI workflow's Podfile/xcworkspace references are outdated — the project has no Podfile).

```sh
# Build for simulator (single target, shared scheme "VideoSDK-Example")
xcodebuild -project VideoSDK.xcodeproj -scheme VideoSDK-Example \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

The app requires camera/microphone, so meaningful runs need a physical device; the simulator is fine for compile checks.

### Auth setup (required to run)

`VideoSDK/API/Constants.swift` must provide either `AUTH_TOKEN` (a JWT from the VideoSDK dashboard) or `AUTH_URL` (a token-vending auth server). `StartViewController` prefers `AUTH_TOKEN` and falls back to fetching a token from `AUTH_URL`. CI (`.github/workflows/publish_to_testflight.yaml`) rewrites this file from a secret on pushes to `main`, so avoid committing real tokens here.

## Dependencies (SPM, pinned in project.pbxproj)

- `videosdk-rtc-ios-spm` → product `VideoSDKRTCSwift`, imported as `VideoSDKRTC` (exact version pin; there is also a stale branch=main package reference in the pbxproj)
- `firebase-ios-sdk` (Crashlytics)
- `MessageKit` + `InputBarAccessoryView` (chat UI)

## Architecture

Screen flow: `StartViewController` → `MeetingViewController`, passing a `MeetingData` struct (token, name, meetingId, mic/camera state, meeting `Mode`).

- **`VideoSDK/API/`** — `Constants.swift` (auth config) and `APIService.swift`, a small enum-based REST client for `api.videosdk.live` (`/v2/rooms` create, `/v2/rooms/validate/:id`, `get-token`).
- **`VideoSDK/Screens/StartViewController.swift`** — pre-join screen: name/meeting-id entry, create-vs-join, local camera preview via raw `AVCaptureSession` (before the SDK takes over), mic/camera toggles, and meeting mode selection (`SEND_AND_RECV` / `RECV_ONLY` / `SIGNALLING_ONLY`).
- **`VideoSDK/Screens/MeetingViewController.swift`** (~1250 lines) — the core of the example. Configures the SDK (`VideoSDK.config(token:)`), initializes the `Meeting`, and implements all SDK callbacks as extensions: `MeetingEventListener`, `ParticipantEventListener`, `PubSubMessageListener`, and `RealtimeStoreEventListener`. Participants render in a `UICollectionView` of `ParticipantViewCell`s (tracked via an `indexPaths` dictionary keyed by participant id); screen share renders in `ScreenSharingView`. Most meeting features (recording, livestream, HLS, quality, pin, mode change, realtime store) are driven from a `MenuOption` enum presented as alert sheets.
- **Chat & raise-hand** use the SDK's pub/sub with topics `CHAT` and `RAISE_HAND`; `ChatViewController` is built on MessageKit.
- **`VideoSDK/Views/ButtonControlsView`** — the in-meeting control bar, loaded from its XIB by `MeetingViewController`.

UI layout lives in `VideoSDK/Base.lproj/Main.storyboard` plus XIBs; screens are wired via storyboard segues (e.g. the "Add Livestream Outputs" segue).
