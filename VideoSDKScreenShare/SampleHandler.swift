//
//  SampleHandler.swift
//  ScreenBroadcastiOS
//
//  Created by Parth Asodariya on 23/06/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import ReplayKit
import OSLog

let broadcastLogger = OSLog(subsystem: "live.videosdk.flutter.example", category: "Broadcast")
private enum Constants {
    // the App Group ID value that the app and the broadcast extension targets are setup with. It differs for each app.
    static let appGroupIdentifier = "group.videosdk.broadcast"
}

class SampleHandler: RPBroadcastSampleHandler {
    
    private var clientConnection: SocketConnection?
    private var uploader: SampleUploader?
   
    private var frameCount: Int = 0
   
    var socketFilePath: String {
     let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)
       return sharedContainer?.appendingPathComponent("rtc_SSFD").path ?? ""
    }
    
    override init() {
        super.init()
          if let connection = SocketConnection(filePath: socketFilePath) {
            clientConnection = connection
            setupConnection()
            uploader = SampleUploader(connection: connection)
          }
          os_log(.debug, log: broadcastLogger, "%{public}s", socketFilePath)
      }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        frameCount = 0
               
       DarwinNotificationCenter.shared.postNotification(.broadcastStarted)
       openConnection()
       
       let notificationName = CFNotificationName("videosdk.flutter.startScreenShare" as CFString)
       let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
       CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, true)
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        DarwinNotificationCenter.shared.postNotification(.broadcastStopped)
        clientConnection?.close()
        let notificationName = CFNotificationName("videosdk.flutter.stopScreenShare" as CFString)
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, nil, true)
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            frameCount += 1
            if frameCount % 3 == 0 {
                uploader?.send(sample: sampleBuffer)
            }
            break
        case .audioApp:
            break
        case .audioMic:
            break
        @unknown default:
            break
        }
    }
}

private extension SampleHandler {
  
    func setupConnection() {
        clientConnection?.didClose = { [weak self] error in
            if let error = error {
                self?.finishBroadcastWithError(error)
            } else {
                // the displayed failure message is more user friendly when using NSError instead of Error
                let JMScreenSharingStopped = 10001
                let customError = NSError(domain: RPRecordingErrorDomain, code: JMScreenSharingStopped, userInfo: [NSLocalizedDescriptionKey: "Screen sharing stopped"])
                self?.finishBroadcastWithError(customError)
            }
        }
    }
    
    func openConnection() {
        let queue = DispatchQueue(label: "broadcast.connectTimer")
        let timer = DispatchSource.makeTimerSource(queue: queue)
        
//        let notificationName = CFNotificationName("videosdk.flutter.log" as CFString)
//        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
//        CFNotificationCenterPostNotification(notificationCenter, notificationName, nil, ["testing": "connection name is here"] as CFDictionary, true)

        timer.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(500))
        timer.setEventHandler { [weak self] in
            guard self?.clientConnection?.open() == true else {
                return
            }
            
            timer.cancel()
        }
        
        timer.resume()
    }
}
