//
//  BroadcastScreenCapturer.h
//  Pods
//
//  Created by Parth Asodariya on 23/06/23.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kRTCScreensharingSocketFD;
extern NSString* const kRTCAppGroupIdentifier;
extern NSString* const kRTCScreenSharingExtension;

@class iOSSocketConnectionFrameReader;

@interface iOSBroadcastScreenCapturer : RTCVideoCapturer
- (void)startCapture;
- (void)stopCapture;
- (void)stopCaptureWithCompletionHandler:(nullable void (^)(void))completionHandler;

@end

NS_ASSUME_NONNULL_END
