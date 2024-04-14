//
//  SocketConnection.h
//  Pods
//
//  Created by Parth Asodariya on 23/06/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface iOSSocketConnection : NSObject

- (instancetype)initWithFilePath:(nonnull NSString*)filePath;
- (void)openWithStreamDelegate:(id<NSStreamDelegate>)streamDelegate;
- (void)close;

@end

NS_ASSUME_NONNULL_END
