# Video SDK IOS Example

This is VideoSDK RTC example code for iOS.

## Prerequisites

You must have the following installed:

- Xcode 12.0+
- Swift 5.0+

## Getting started

1. There are 2 options
   Option 1: Get Auth Token from [VideoSDK Dashboard](https://app.videosdk.live/dashboard)
   Option 2: Setting up Auth Server [Instructions](https://github.com/videosdk-live/videosdk-rtc-nodejs-sdk-example)

2. Clone the repo

   ```sh
   $ git clone https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example.git
   ```

3. run `pod install` in terminal from the Example project directory.

4. Either update `AUTH_TOKEN` or `AUTH_URL` in the `Constants.swift` file.

   ```
   public let AUTH_TOKEN = "#YOUR_GENERATED_TOKEN"
   ```

   OR

   ```
   public let AUTH_URL = "#YOUR_AUTH_SERVER_URL"
   ```
   
5. Run the project.

For more information, visit [official documentation](https://docs.videosdk.live/docs/guide/video-and-audio-calling-api-sdk/getting-started)

Related

- [Video SDK RTC React Example](https://github.com/videosdk-live/videosdk-rtc-react-sdk-example)
- [Video SDK RTC React Native Example](https://github.com/videosdk-live/videosdk-rtc-react-native-sdk-example)
- [Video SDK RTC Flutter Example](https://github.com/videosdk-live/videosdk-rtc-flutter-sdk-example)
- [Video SDK RTC Android Example](https://github.com/videosdk-live/videosdk-rtc-android-java-sdk-example)
- [Video SDK RTC iOS Example](https://github.com/videosdk-live/videosdk-rtc-ios-sdk-example)
