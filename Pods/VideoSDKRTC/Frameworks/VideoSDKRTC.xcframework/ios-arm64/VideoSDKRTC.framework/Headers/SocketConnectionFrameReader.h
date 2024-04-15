//
//  SocketConnectionFrameReader.h
//  Pods
//
//  Created by Parth Asodariya on 23/06/23.
//

#import <AVFoundation/AVFoundation.h>
#import <WebRTC/RTCVideoCapturer.h>

NS_ASSUME_NONNULL_BEGIN

@class iOSSocketConnection;

@interface iOSSocketConnectionFrameReader : RTCVideoCapturer

- (instancetype)initWithDelegate:(__weak id<RTCVideoCapturerDelegate>)delegate;
- (void)startCaptureWithConnection:(nonnull iOSSocketConnection*)connection;
- (void)stopCapture;

@end

NS_ASSUME_NONNULL_END
