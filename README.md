# Video SDK for iOS

[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.videosdk.live/react-native/guide/video-and-audio-calling-api-sdk/getting-started)
[![Firebase](https://img.shields.io/badge/Download%20Android-Firebase-green)](https://appdistribution.firebase.dev/i/a4c63049415c4356)
[![TestFlight](https://img.shields.io/badge/Download%20iOS-TestFlight-blue)](https://testflight.apple.com/join/LYj3QJPx)
[![Discord](https://img.shields.io/discord/876774498798551130?label=Join%20on%20Discord)](https://discord.gg/bGZtAbwvab)
[![Register](https://img.shields.io/badge/Contact-Know%20More-blue)](https://app.videosdk.live/signup)

At Video SDK, we’re building tools to help companies create world-class collaborative products with capabilities of live audio/videos, compose cloud recordings/rtmp/hls and interaction APIs

## Demo App

Check out demo [here](https://videosdk.live/prebuilt/)

📲 Download the Sample iOS app here: https://testflight.apple.com/join/LYj3QJPx

📱 Download the Sample Android app here: https://appdistribution.firebase.dev/i/a4c63049415c4356

<br/>

## Meeting Features

- [x] Real-time video and audio conferencing
- [x] Enable/disable camera
- [x] Mute/unmute mic
- [x] Chat
- [x] Raise hand
- [x] Recording

<br/>

## Setup Guide

- Sign up on [VideoSDK](https://app.videosdk.live/) and visit [API Keys](https://app.videosdk.live/api-keys) section to get your API key and Secret key.

- Get familiarized with [API key and Secret key](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/signup-and-create-api)

- Get familiarized with [Token](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/server-setup)

<br/>

### Prerequisites

- iOS 12.0+
- Xcode 13.0+
- Swift 5.0+
- Valid [Video SDK Account](https://app.videosdk.live/signup)

## Run the Sample App

### Step 1. There are two options:
   1. Option 1: Get Auth Token from [VideoSDK Dashboard](https://app.videosdk.live/dashboard)
   2. Option 2: Setting up Auth Server [Instructions](https://github.com/videosdk-live/videosdk-rtc-nodejs-sdk-example)

### Step 2. Clone the repo

   ```sh
   $ git clone https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example.git
   ```

### Step 3. run `pod install` in terminal from the Example project directory.

### Step 4. Either update `AUTH_TOKEN` or `AUTH_URL` in the `Constants.swift` file.

   ```
   public let AUTH_TOKEN = "#YOUR_GENERATED_TOKEN"
   ```

   OR

   ```
   public let AUTH_URL = "#YOUR_AUTH_SERVER_URL"
   ```
   
### Step 5. Run the project.

<br/>

## Key Concepts

- `Meeting` - A Meeting represents Real time audio and video communication.

  **`Note : Don't confuse with Room and Meeting keyword, both are same thing 😃`**

- `Sessions` - A particular duration you spend in a given meeting is a referred as session, you can have multiple session of a particular meetingId.
- `Participant` - Participant represents someone who is attending the meeting's session, `local partcipant` represents self (You), for this self, other participants are `remote participants`.
- `Stream` - Stream means video or audio media content that is either published by `local participant` or `remote participants`.

<br/>

## Permissions

- Your app needs to add permissions to use microphone and camera. Add below code your app's info.plist.

```swift
<key>NSCameraUsageDescription</key>
<string>Allow camera access to start video.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Allow microphone access to start audio.</string>
```

<br/>

## Token Generation

Token is used to create and validate a meeting using API and also initialise a meeting.

🛠️ `Development Environment`:

- You may use a temporary token for development. To create a temporary token, go to VideoSDK [dashboard](https://app.videosdk.live/api-keys) .

🌐 `Production Environment`:

- You must set up an authentication server to authorise users for production. To set up an authentication server, refer to our official example repositories. [videosdk-rtc-api-server-examples](https://github.com/videosdk-live/videosdk-rtc-api-server-examples)

> **Note** :
>
> Development environment tokens have a 7-day expiration period.

<br/>

## API: Create and Validate meeting

- `create meeting` - Please refer this [documentation](https://docs.videosdk.live/api-reference/realtime-communication/create-room) to create meeting.
- `validate meeting`- Please refer this [documentation](https://docs.videosdk.live/api-reference/realtime-communication/validate-room) to validate the meetingId.

<br/>

## [Initialize a Meeting](https://docs.videosdk.live/ios/api/sdk-reference/setup)

- You can initialize the meeting using `VideoSDK.initMeeting` method. this method configures meeting with given meeting-id.

```swift
    VideoSDK.config(token: "server-token")

    meeting = VideoSDK.initMeeting(
        meetingId: "meeting-id",
        participantId: "participant-id"
        participantName: "participant-name",
        micEnabled: true,
        webcamEnabled: true,
      )
```

<br/>

## [Enable/Disable Local Webcam](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

```swift
    buttonControlsView.onVideoTapped = { on in
        
        if !on {
            self.meeting?.enableWebcam()
        } else {
            self.meeting?.disableWebcam()
        }
    }
```

<br/>

## [Mute/Unmute Local Audio](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

```swift
    buttonControlsView.onMicTapped = { on in
        if !on {
            self.meeting?.unmuteMic()
        } else {
            self.meeting?.muteMic()
        }
    }
```

<br/>

## [Change Local Mic](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

```swift
    AVAudioSession.sharedInstance().changeAudioOutput(presenterViewController: self)
```

<br/>

## [Chat](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/pubsub)

- The chat feature allows participants to send and receive messages about specific topics to which they have subscribed.

```swift
    // listen/subscribe for chat topic
    meeting?.pubsub.subscribe(topic: CHAT_TOPIC, forListener: self)
    
    //write this block on click event
    meeting.pubSub.publish(topic: "CHAT", message: message, options: { persist: true })
    
    //unsubscribing messages on topic CHAT
    meeting.pubSub.unsubscribe("CHAT");
```

<br/>

## Raise Hand

- This feature allows participants to raise hand during the meeting.

```swift
    // listen/subscribe for raise-hand topic
    meeting?.pubsub.subscribe(topic: RAISE_HAND_TOPIC, forListener: self);
    
    // raise hand on click event
    self.meeting?.pubsub.publish(topic: RAISE_HAND_TOPIC, message: "Raise Hand by Me", options: [:])
};
```

<br/>

## [Recording](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

- Record meeting allows participants to record video & audio during the meeting. The recording files are available in developer dashboard. Any participant can start / stop recording any time during the meeting.

```swift
    let webhookUrl = "https://webhook.your-api-server.com"
    
    // start recording
    meeting.startRecording(webhookUrl: webhookUrl)
    
    // stop recording
    stopRecording()
```

<br/>

## [Live Streaming](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

- Interactive Live Streaming allows participants to to broadcast live streaming to other participants. Host can start / stop HLS any time during the meeting.

```swift
    // start live streaming
    startLivestream(outputs: outputs)
    
    // stop live streaming
    stopLivestream()
```

<br/>

## [Leave or End Meeting](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

```swift
  // Only one participant will leave/exit the meeting; the rest of the participants will remain.
  meeting?.leave();

  // The meeting will come to an end for each and every participant. So, use this function in accordance with your requirements.
  meeting?.end();
```

<br/>

## [Meeting Event callbacks](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

By registering callback handlers, VideoSDK sends callbacks to the client app whenever there is a change or update in the meeting after a user joins.

```swift
func onMeetingJoined() {
  // This event will be emitted when a localParticipant(you) successfully joined the meeting.
  print("onMeetingJoined");
}
func onMeetingLeft() {
  // This event will be emitted when a localParticipant(you) left the meeting.
  print("onMeetingLeft");
}
func onParticipantJoined(participant) {
  // This event will be emitted when a new participant joined the meeting.
  // [participant]: new participant who joined the meeting
  print(" onParticipantJoined", participant);
}
func onParticipantLeft(participant) {
  // This event will be emitted when a joined participant left the meeting.
  // [participantId]: id of participant who left the meeting
  print(" onParticipantLeft", participant);
}
func onSpeakerChanged = (activeSpeakerId) => {
  // This event will be emitted when any participant starts or stops screen sharing.
  // [activeSpeakerId]: Id of participant who shares the screen.
  print(" onSpeakerChanged", activeSpeakerId);
};
func onRecordingStarted() {
  // This event will be emitted when recording of the meeting is started.
  print(" onRecordingStarted");
}
func onRecordingStopped() {
  // This event will be emitted when recording of the meeting is stopped.
  print(" onRecordingStopped");
}
```

<br/>

## [Participant Events Callback](https://docs.videosdk.live/ios/api/sdk-reference/meeting-class/methods)

By registering callback handlers, VideoSDK sends callbacks to the client app whenever a participant's video, audio, or screen share stream is enabled or disabled.

```swift
  func onStreamEnabled(stream, participant) {
    // This event will be triggered whenever a participant's video, audio or screen share stream is enabled.
    print("onStreamEnabled");
  }
  func onStreamDisabled(stream, participant) {
    // This event will be triggered whenever a participant's video, audio or screen share stream is disabled.
    print(" onStreamDisabled");
  }
```

If you want to learn more about the SDK, read the Complete Documentation of [iOS VideoSDK](https://docs.videosdk.live/ios/api/sdk-reference/setup)

<br/>

## Project Description

<br/>

> **Note :**
>
> - **main** branch: Better UI with One-to-One and Conference call experience.
> - **v1-sample-code** branch: Simple UI with Group call experience.

<br/>

## Project Structure

We have separated conrtroller and components in following folder structure:

```
VideoSDK
└── view
    └── ButtonControlsView.swift
    └── ParticipantCellView.swift
└── API
    └── Constants.swift
    └── APIService.swift
└── models
    └── Message.swift
    └── ChatUser.swift
    └── MeetingData.swift
└── controllers
    └── StartMeetingViewController.swift
    └── MeetingViewController.swift
    └── ChatViewController.swift
```

<br/>

## Examples

- [Prebuilt SDK Examples](https://github.com/videosdk-live/videosdk-rtc-prebuilt-examples)
- [JavaScript SDK Example](https://github.com/videosdk-live/videosdk-rtc-javascript-sdk-example)
- [React JS SDK Example](https://github.com/videosdk-live/videosdk-rtc-react-sdk-example)
- [React Native SDK Example](https://github.com/videosdk-live/videosdk-rtc-react-native-sdk-example)
- [Flutter SDK Example](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example)
- [Android SDK Example](https://github.com/videosdk-live/videosdk-rtc-android-java-sdk-example)
- [iOS SDK Example](https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example)

## Documentation

[Read the documentation](https://docs.videosdk.live/) to start using Video SDK.

## Community

- [Discord](https://discord.gg/Gpmj6eCq5u) - To get involved with the Video SDK community, ask questions and share tips.
- [Twitter](https://twitter.com/video_sdk) - To receive updates, announcements, blog posts, and general Video SDK tips.
