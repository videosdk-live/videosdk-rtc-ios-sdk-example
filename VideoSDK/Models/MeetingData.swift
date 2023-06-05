//
//  MeetingData.swift
//  VideoSDK_Example
//
//  Created by Rushi Sangani on 26/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import VideoSDKRTC

struct MeetingData {
    let token: String
    let name: String
    let participantId: String? = ""
    let meetingId: String
    let micEnabled: Bool
    let cameraEnabled: Bool
    let mode: Mode?
}
