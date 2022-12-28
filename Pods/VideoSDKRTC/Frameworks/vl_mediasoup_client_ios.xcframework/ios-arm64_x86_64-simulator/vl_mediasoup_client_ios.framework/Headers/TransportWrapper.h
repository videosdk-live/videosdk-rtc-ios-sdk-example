//
//  TransportWrapper.h
//  mediasoup-client-ios
//
//  Created by Ethan.
//  Copyright © 2019 Ethan. All rights reserved.
//
#import "Transport.hpp"
#import "ProducerWrapper.h"
#import "ConsumerWrapper.h"
#import "SendTransport.h"
#import "RecvTransport.h"
#import "Transport.h"

#ifndef TransportWrapper_h
#define TransportWrapper_h

@interface TransportWrapper : NSObject {}
+(NSString *)getNativeId:(NSValue *)nativeTransport;
+(NSString *)getNativeConnectionState:(NSValue *)nativeTransport;
+(NSString *)getNativeAppData:(NSValue *)nativeTransport;
+(NSString *)getNativeStats:(NSValue *)nativeTransport;
+(bool)isNativeClosed:(NSValue *)nativeTransport;
+(void)nativeRestartIce:(NSValue *)nativeTransport iceParameters:(NSString *)iceParameters;
+(void)nativeUpdateIceServers:(NSValue *)nativeTransport iceServers:(NSString *)iceServers;
+(void)nativeClose:(NSValue *)nativeTransport;
+(NSValue *)nativeGetNativeTransport:(NSValue *)nativeTransport;
+(::Producer *)nativeProduce:(NSValue *)nativeTransport listener:(Protocol<ProducerListener> *)listener track:(NSUInteger)track encodings:(NSArray *)encodings codecOptions:(NSString *)codecOptions appData:(NSString *)appData;
+(void)nativeFreeTransport:(NSValue *)nativeTransport;
+(::Consumer *)nativeConsume:(NSValue *)nativeTransport listener:(id<ConsumerListener>)listener id:(NSString *)id producerId:(NSString *)producerId kind:(NSString *)kind rtpParameters:(NSString *)rtpParameters appData:(NSString *)appData;
+(mediasoupclient::Transport *)extractNativeTransport:(NSValue *)nativeTransport;

@end

class SendTransportListenerWrapper : public mediasoupclient::SendTransport::Listener {
private:
  Protocol<SendTransportListener>* listener_;
public:
  SendTransportListenerWrapper(Protocol<SendTransportListener>* listener)
  : listener_(listener) {}
  
  ~SendTransportListenerWrapper() {
    [listener_ release];
  }
  
  std::future<void> OnConnect(mediasoupclient::Transport* nativeTransport, const nlohmann::json& dtlsParameters) override {
    if (this->listener_ != nullptr && nativeTransport != nullptr) {
      [this->listener_ onConnect: [NSString stringWithUTF8String:nativeTransport->GetId().c_str()]
                  dtlsParameters: [NSString stringWithUTF8String:dtlsParameters.dump().c_str()]];
    }

    std::promise<void> promise;
    promise.set_value();
    return promise.get_future();
  };
  
  void OnConnectionStateChange(mediasoupclient::Transport* nativeTransport, const std::string& connectionState) override {
    if (this->listener_ != nullptr && nativeTransport != nullptr) {
      [this->listener_ onConnectionStateChange: [NSString stringWithUTF8String:nativeTransport->GetId().c_str()]
                               connectionState: [NSString stringWithUTF8String:connectionState.c_str()]];
    }
  };
  
  std::future<std::string> OnProduce(mediasoupclient::SendTransport* nativeTransport,
                                     const std::string& kind,
                                     nlohmann::json rtpParameters,
                                     const nlohmann::json& appData) override {
      
    __block std::promise<std::string> promise;
    
    [this->listener_ onProduce: [NSString stringWithUTF8String:nativeTransport->GetId().c_str()]
                          kind: [NSString stringWithUTF8String:kind.c_str()]
                 rtpParameters: [NSString stringWithUTF8String:rtpParameters.dump().c_str()]
                       appData: [NSString stringWithUTF8String:appData.dump().c_str()]
                      callback: ^(NSString* id) { promise.set_value(std::string([id UTF8String])); }];
    
    return promise.get_future();
  };

  std::future<std::string> OnProduceData(mediasoupclient::SendTransport* nativeTransport,
                                         const nlohmann::json& sctpStreamParameters,
                                         const std::string& label,
                                         const std::string& protocol,
                                         const nlohmann::json& appData) {
    
    __block std::promise<std::string> promise;
    promise.set_value(std::string("not implemented"));
    return promise.get_future();
  };
};

class RecvTransportListenerWrapper final : public mediasoupclient::RecvTransport::Listener {
private:
  Protocol<TransportListener>* listener_;
public:
  RecvTransportListenerWrapper(Protocol<TransportListener>* listener)
  : listener_(listener) {}
  
  ~RecvTransportListenerWrapper() {
    delete this;
  }

  std::future<void> OnConnect(mediasoupclient::Transport* nativeTransport,
                              const nlohmann::json& dtlsParameters) override {
    if (this->listener_ != nullptr && nativeTransport != nullptr) {
      [this->listener_ onConnect: [NSString stringWithUTF8String:nativeTransport->GetId().c_str()]
                  dtlsParameters: [NSString stringWithUTF8String:dtlsParameters.dump().c_str()]];
    }
    
    std::promise<void> promise;
    promise.set_value();
    return promise.get_future();
  };
  
  void OnConnectionStateChange(mediasoupclient::Transport* nativeTransport, const std::string& connectionState) override {
    if (this->listener_ != nullptr && nativeTransport != nullptr) {
      [this->listener_ onConnectionStateChange: [NSString stringWithUTF8String:nativeTransport->GetId().c_str()]
                               connectionState: [NSString stringWithUTF8String:connectionState.c_str()]];
    }
  };
};

class OwnedSendTransport {
public:
  OwnedSendTransport(mediasoupclient::SendTransport* transport, SendTransportListenerWrapper* listener)
  : transport_(transport), listener_(listener) {}
  
  ~OwnedSendTransport() {
    delete transport_;
    delete listener_;
  }
  
  mediasoupclient::SendTransport* transport() const { transport_; }
  
private:
  mediasoupclient::SendTransport* transport_;
  SendTransportListenerWrapper* listener_;
};

class OwnedRecvTransport {
public:
  OwnedRecvTransport(mediasoupclient::RecvTransport* transport, RecvTransportListenerWrapper* listener)
  : transport_(transport), listener_(listener) {}
  
  ~OwnedRecvTransport() {
    delete transport_;
    delete listener_;
  }
  
  mediasoupclient::RecvTransport* transport() const { return transport_; }
  
private:
  mediasoupclient::RecvTransport* transport_;
  RecvTransportListenerWrapper* listener_;
};

#endif /* TransportWrapper_h */
