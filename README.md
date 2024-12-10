# 🚀 Video SDK for iOS

[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.videosdk.live/react-native/guide/video-and-audio-calling-api-sdk/getting-started)
[![TestFlight](https://img.shields.io/badge/Download%20iOS-TestFlight-blue)](https://testflight.apple.com/join/LYj3QJPx)
[![Discord](https://img.shields.io/discord/876774498798551130?label=Join%20on%20Discord)](https://discord.gg/bGZtAbwvab)
[![Register](https://img.shields.io/badge/Contact-Know%20More-blue)](https://app.videosdk.live/signup)

At Video SDK, we’re building tools to help companies create world-class collaborative products with capabilities for live audio/video, cloud recordings, RTMP/HLS streaming, and interaction APIs.

### 🥳 Get **10,000 minutes free** every month! **[Try it now!](https://app.videosdk.live/signup)**


## 📚 **Table of Contents**

- [📱 **Demo App**](#-demo-app)
- [⚡ **Quick Setup**](#-quick-setup)
- [🔧 **Prerequisites**](#-prerequisites)
- [📦 **Running the Sample App**](#-running-the-sample-app)
- [🔥 **Meeting Features**](#-meeting-features)
- [🧠 **Key Concepts**](#-key-concepts)
- [🔑 **Token Generation**](#-token-generation)
- [🧩 **Project OverView**](#-project-overview)
- [📖 **Examples**](#-examples)
- [📝 **VideoSDK's Documentation**](#-documentation)
- [💬 **Join Our Community**](#-join-our-community)

## 📱 Demo App

📱 Download the Sample iOS app here: https://testflight.apple.com/join/26EBZkcX

## ⚡ Quick Setup

1. Sign up on [VideoSDK](https://app.videosdk.live/) to grab your API Key and Secret.
2. Familiarize yourself with [Token](https://docs.videosdk.live/android/guide/video-and-audio-calling-api-sdk/authentication-and-token)

## 🛠 Prerequisites

- iOS 13.0+
- Xcode 13.0+
- Swift 5.0+
- Valid [Video SDK Account](https://app.videosdk.live/signup)


## 📦 Running the Sample App

### Step 1: Clone the Repository

Clone the repository to your local environment.

```js
  git clone https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example.git
```
### Step 2. Install Pods

Run `pod install` in terminal from the Example project directory.

### Step 3. update `AUTH_TOKEN` in the `Constants.swift` file.

Generate temporary token from  [**Video SDK Account**](https://app.videosdk.live/signup).
   ```
   public let AUTH_TOKEN = "#YOUR_GENERATED_TOKEN"
   ```
### Step 4. Run the project.

Run App from Xcode. Please run the app in real device for better experience because audio and video is not supported in simulator.

## 🔥 Meeting Features

Unlock a suite of powerful features to enhance your meetings:

| Feature                        | Documentation                                                                                                                | Description                                                                                                      |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| 📋 **Precall Setup**           | [Setup Precall](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/setup-call/precall)                   | Configure audio, video devices, and other settings before joining the meeting.                                              |
| 🤝 **Join Meeting**            | [Join Meeting](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/setup-call/join-meeting)                | Allows participants to join a meeting.                                                                 |
| 🚪 **Leave Meeting**            | [Leave Meeting](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/setup-call/leave-end-meeting)                | Allows participants to leave a meeting.                                                                 |
| 🎤 **Toggle Mic**         | [Mic Control](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/handling-media/mute-unmute-mic)          | Toggle the microphone on or off during a meeting.                                                                  |
| 📷 **Toggle Camera**           | [Camera Control](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/handling-media/on-off-camera)         | Turn the video camera on or off during a meeting.                                                                  |
| 🖥️ **Screen Share**            | [Screen Share](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/handling-media/screen-share)          | Share your screen with other participants during the call.                                                      |
| 🔊 **Change Audio Device**     | [Switch Audio Device](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/handling-media/change-input-output-device#changing-inputoutput-audio-device) | Select an input-output device for audio during a meeting.                                                                |
| 🔌 **Change Video Device**     | [Switch Video Device](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/handling-media/change-input-output-device#changing-camera-input-device) | Select an output device for audio during a meeting.                                                                |
| ⚙️ **Optimize Audio Track**         | [Audio Track Optimization](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/render-media/optimize-audio-track)                                       | Enhance the quality and performance of media tracks.                                                            |
| ⚙️ **Optimize Video Track**         | [Video Track Optimization](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/render-media/optimize-video-track)                                       | Enhance the quality and performance of media tracks.                                                            |
| 💬 **Chat**                    | [In-Meeting Chat](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/collaboration-in-meeting/pubsub)      | Exchange messages with participants through a Publish-Subscribe mechanism.                                                   |
| 📸 **Image Capture**           | [Image Capturer](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/handling-media/image-capturer)        | Capture images of other participant from their video stream, particularly useful for Video KYC and identity verification scenarios.     |
| 📁 **File Sharing**            | [File Sharing](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/collaboration-in-meeting/upload-fetch-temporary-file) | Share files with participants during the meeting.                                                               |
| 🖼️ **Virtual Background**        | [Virtual Background](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/render-media/virtual-background)                                       | Add a virtual background or blur effect to your video during the call.                                                            |
| 📼 **Recording**               | [Recording](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/recording/Overview)                | Record the meeting for future reference.                                                                        |
| 📡 **RTMP Livestream**         | [RTMP Livestream](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/live-streaming/rtmp-livestream)        | Stream the meeting live to platforms like YouTube or Facebook.                                                  |
| 📝 **Real-time Transcription**           | [Real-time Transcription](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/transcription-and-summary/realtime-transcribe-meeting) | Generate real-time transcriptions of the meeting.                                                               |
| 🔇 **Toggle Remote Media**     | [Remote Media Control](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/control-remote-participant/remote-participant-media) | Control the microphone or camera of remote participants.                                                        |
| 🚫 **Mute All Participants**   | [Mute All](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/control-remote-participant/mute-all-participants) | Mute all participants simultaneously during the call.                                                           |
| 🗑️ **Remove Participant**      | [Remove Participant](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/control-remote-participant/remove-participant) | Eject a participant from the meeting.  |

## 🧠 Key Concepts

Understand the core components of our SDK:

- `Meeting` - A Meeting represents Real-time audio and video communication.

  **` Note: Don't confuse the terms Room and Meeting; both mean the same thing 😃`**

- `Sessions` - A particular duration you spend in a given meeting is referred as a session, you can have multiple sessions of a specific meetingId.
- `Participant` - A participant refers to anyone attending the meeting session. The `local participant` represents yourself (You), while all other attendees are considered `remote participants`.
- `Stream` - A stream refers to video or audio media content published by either the `local participant` or `remote participants`.


## 🔐 Token Generation

The token is used to create and validate a meeting using API and also initialize a meeting.

🛠️ `Development Environment`:

- You may use a temporary token for development. To create a temporary token, go to VideoSDK's [dashboard](https://app.videosdk.live/api-keys) .

🌐 `Production Environment`:

- You must set up an authentication server to authorize users for production. To set up an authentication server, please take a look at our official example repositories. [videosdk-rtc-api-server-examples](https://github.com/videosdk-live/videosdk-rtc-api-server-examples)

## 🧩 Project Overview

### App Behaviour with Different Meeting Types

- **One-to-One meeting** - The One-to-One meeting allows 2 participants to join a meeting in the app.

## 🏗️ Project Structure

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

## 🔐 App Permission 
- Your app needs to add permissions to use microphone and camera. Add below code your app's info.plist.

```swift
<key>NSCameraUsageDescription</key>
<string>Allow camera access to start video.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Allow microphone access to start audio.</string>
```


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

## 📖 Examples

### Examples for Conference

- [videosdk-rtc-prebuilt-examples](https://github.com/videosdk-live/videosdk-rtc-prebuilt-examples)
- [videosdk-rtc-javascript-sdk-example](https://github.com/videosdk-live/videosdk-rtc-javascript-sdk-example)
- [videosdk-rtc-react-sdk-examplee](https://github.com/videosdk-live/videosdk-rtc-react-sdk-example)
- [videosdk-rtc-react-native-sdk-example](https://github.com/videosdk-live/videosdk-rtc-react-native-sdk-example)
- [videosdk-rtc-flutter-sdk-example](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example)
- [videosdk-rtc-android-java-sdk-example](https://github.com/videosdk-live/videosdk-rtc-android-java-sdk-example)
- [videosdk-rtc-android-kotlin-sdk-example](https://github.com/videosdk-live/videosdk-rtc-android-kotlin-sdk-example)
- [videosdk-rtc-ios-sdk-example](https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example)

### Examples for Live Streaming

- [videosdk-hls-react-sdk-example](https://github.com/videosdk-live/videosdk-hls-react-sdk-example)
- [videosdk-hls-react-native-sdk-example](https://github.com/videosdk-live/videosdk-hls-react-native-sdk-example)
- [videosdk-hls-flutter-sdk-example](https://github.com/videosdk-live/videosdk-hls-flutter-sdk-example)
- [videosdk-hls-android-java-example](https://github.com/videosdk-live/videosdk-hls-android-java-example)
- [videosdk-hls-android-kotlin-example](https://github.com/videosdk-live/videosdk-hls-android-kotlin-example)


## 📝 Documentation

Explore more and start building with our [**Documentation**](https://docs.videosdk.live/)

## 🤝 Join Our Community

- **[Discord](https://discord.gg/Gpmj6eCq5u)**: Engage with the Video SDK community, ask questions, and share insights.
- **[X](https://x.com/video_sdk)**: Stay updated with the latest news, updates, and tips from Video SDK.
