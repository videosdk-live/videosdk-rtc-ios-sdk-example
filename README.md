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
2. Familiarize yourself with [Token](https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/authentication-and-token)

## 🛠 Prerequisites

- iOS 18.0+
- Xcode with the iOS 18 SDK or later (this example is built with Xcode 27.0)
- Swift 5.0+
- Valid [Video SDK Account](https://app.videosdk.live/signup)


## 📦 Running the Sample App

### Step 1: Clone the Repository

Clone the repository to your local environment.

```js
  git clone https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example.git
```
### Step 2. Install Dependencies

The VideoSDK iOS SDK (4.0.0) is added with Swift Package Manager from [videosdk-rtc-ios-spm](https://github.com/videosdk-live/videosdk-rtc-ios-spm) (product `VideoSDKRTCSwift`, Exact Version `4.0.0`). Xcode resolves it when you open the workspace.

The other dependencies (MessageKit, IQKeyboardManagerSwift) use CocoaPods, so run `pod install` in terminal from the Example project directory, then open `VideoSDKRTC_Example.xcworkspace`.

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

### [Common package]
---
### 1. Pre-Call Setup on Join Screen

#### **[`StartMeetingViewController.swift`](./VideoSDKRTC_Example/controllers/StartMeetingViewController.swift)**

- **Purpose**: The Pre-Call Setup screen allows participants to configure their video and audio settings before joining or creating a meeting.
- **Key Features**:
  - **Camera Selection**: Toggle between front and back cameras using an action sheet, and pass the selected camera orientation to the meeting.
  - **Microphone Selection**: Choose a preferred microphone from the list of available devices using `VideoSDK.getAudioDevices()` for audio input and output during the meeting.
<p align="center">
<img width="300" src="https://cdn.videosdk.live/docs/github/ios_sdk_example/pre_call_screen.gif"/>
</p>

---

### 2. Create or Join Meeting

#### **[`APIService.swift`](./VideoSDKRTC_Example/API/APIService.swift)**
- **Purpose**: Handles API requests to generate tokens, create meetings, and validate meeting details.
  
#### **[`StartMeetingViewController.swift`](./VideoSDKRTC_Example/controllers/StartMeetingViewController.swift)**
- **Purpose**: Manages the process of creating or joining a meeting, including setting up audio, video, and navigation.
- **Key Features**:
  - **Meeting Creation & Joining**: Handles the logic for creating or joining a meeting and validates user input.
  - **Camera Setup**: Initializes and manages the camera for video capture.
  - **Microphone Setup**: Initializes and manages the microphone for audio capture.
  - **Notifications**: Requests notification permissions for in-app alerts when the app is moved to the background.
  - **Navigation**: Passes meeting data to `MeetingViewController` when the "join" or "create" button is tapped.

<p align="center">
<img width="300" src="https://cdn.videosdk.live/docs/github/ios_sdk_example/pre_screen.gif"/>
</p>

---

### 3. MeetingScreen

#### **[`MeetingViewController.swift`](./VideoSDKRTC_Example/controllers/MeetingViewController.swift)**
**Purpose**: Manages the meeting flow, including audio/video controls, screen sharing, participant management, and interactive features.

### Key Features

- **Meeting Initialization**: Initializes the meeting with `VideoSDK.initMeeting` using the meeting ID.
- **Stream Handling**: Manages local and remote participant video streams and layout.
- **Real-Time Chat**: Allows participants to send and receive messages.
- **Raise Hand**: Lets participants raise their hands during the meeting.
- **Microphone & Camera Controls**: Toggles muting/unmuting and enabling/disabling video.
- **Recording**: Allows recording of the meeting, available in the developer dashboard.
- **Interactive Live Streaming**: Hosts can start/stop live streaming (HLS).
- **Screen Sharing**: Participants can share their screen during the meeting.
- **Show Participant List**: Displays a list of all active participants.
- **Audio Output Switching**: Switches audio output between devices (e.g., speaker, Bluetooth).

### Listeners


- **MeetingEventLisetner**: Listens for multiple types of events which can be listened to know the current state of the meeting.
- **ParticipantEventListener**: Listens for multiple types of events which can be listened to know the about the participants in the meeting.

<p align="center">
<img width="300" src="https://cdn.videosdk.live/docs/github/ios_sdk_example/join_meeting.gif"/>
</p>

---
### 4. Chat

#### **[`ChatViewController.swift`](./VideoSDKRTC_Example/controllers/ChatViewController.swift)**
- **Purpose**: Manages the chat interface for the video meeting using the `MessageKit` framework.
- **Key Features**:
  - **Initialization**: Sets up the meeting and chat topic, and loads initial messages.
  - **Message Handling**: Handles adding new messages, reloading the chat, and scrolling to the latest message.
  - **UI Customization**: Customizes the appearance of the navigation bar, message collection view, and input bar.
  - **Real-Time Messaging**: Publishes messages in real-time using the meeting's pub/sub system.
    
#### **[`ChatUser.swift`](./ChatUser.swift)**: Represents a chat user with `senderId` and `displayName` conforming to `SenderType`.

#### **[`Message.swift`](./Message.swift)**: Represents a chat message with `sender`, `messageId`, `sentDate`, and `kind` conforming to `MessageType`.

<p align="center">
<img width="300" src="https://cdn.videosdk.live/docs/github/ios_sdk_example/chat_view.gif"/>
</p>

---

### 5. ParticipantList

#### **[`ParticipantViewController.swift`](./VideoSDKRTC_Example/controllers/ParticipantsViewController.swift)**
- **Purpose**: Displays a dynamic list of participants in the meeting using a table view.
- **Key Features**:
  - **Participant List Display**: Displays participants in a table view and updates automatically when the participant list changes.
  - **Dynamic Updates**: Automatically updates the participant list when participants join or leave the meeting.
  - **UI Customization**: Features a modern design with rounded top corners for the main view.

- **Methods**:
  - **notifyParticipants**: Updates the participant list and reloads the table view when a participant joins or leaves.
  - **btnClose_Clicked**: Dismisses the participant list view.

<p align="center">
<img width="300" src="https://cdn.videosdk.live/docs/github/ios_sdk_example/participant_list.gif"/>
</p>

---

### [OneToOneCall]

- This project handles one-on-one video call, providing features like microphone and camera control, screen sharing, and participant management. It supports real-time chat and meeting event listeners for tasks like recording and screen sharing.and handles permissions for audio, video, and screen sharing.

### [GroupCall]

 - **v1-sample-code** branch: Simple UI with Group call experience.
    
--- 
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
