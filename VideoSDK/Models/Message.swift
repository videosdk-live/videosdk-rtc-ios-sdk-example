//
//  Message.swift
//  VideoSDK_Example
//
//  Created by Rushi Sangani on 26/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import MessageKit
import VideoSDKRTC

struct Message: MessageType {
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    // MARK: - Init
    
    init(pubsubMessage: PubSubMessage) {
        messageId = pubsubMessage.id
        kind = .text(pubsubMessage.message)
        sentDate = Date(string: pubsubMessage.timestamp) ?? Date()
        sender = ChatUser(senderId: pubsubMessage.senderId, displayName: pubsubMessage.senderName)
    }
}
