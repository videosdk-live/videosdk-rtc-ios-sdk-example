//
//  BroadcastScreenCapturer.h
//  Pods
//
//  Created by Parth Asodariya on 23/06/23.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((availability(swift, unavailable)))
extern NSString* const kRTCScreensharingSocketFD;

__attribute__((availability(swift, unavailable)))
extern NSString* const kRTCAppGroupIdentifier;

__attribute__((availability(swift, unavailable)))
extern NSString* const kRTCScreenSharingExtension;

@class iOSSocketConnectionFrameReader;

__attribute__((availability(swift, unavailable)))
@interface iOSBroadcastScreenCapturer : RTCVideoCapturer
- (void)startCapture;
- (void)stopCapture;
- (void)stopCaptureWithCompletionHandler:(nullable void (^)(void))completionHandler;

@end

NS_ASSUME_NONNULL_END
