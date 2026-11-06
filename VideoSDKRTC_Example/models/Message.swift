//
//  Message.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 20/01/23.
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
        sentDate = pubsubMessage.timestamp.toDate() ?? Date()
        sender = ChatUser(senderId: pubsubMessage.senderId, displayName: pubsubMessage.senderName)
    }

    // Builds the local copy of a message this app just sent
    init(localText: String, sender: SenderType) {
        messageId = UUID().uuidString
        kind = .text(localText)
        sentDate = Date()
        self.sender = sender
    }
}
