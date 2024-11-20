//
//  MenuOption.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 26/01/23.
//

import UIKit

enum MenuOption: String {
    case switchCamera = "Switch Camera"
    case startRecording = "Start Recording"
    case stopRecording = "Stop Recording"
//    case startLivestream = "Start Livestream"
//    case stopLivestream = "Stop Livestream"
    case toggleMic = "Toggle Mic"
    case toggleWebcam = "Toggle Webcam"
    case remove = "Remove"
    case leaveMeeting = "Leave"
    case endMeeting = "End Meeting"
    case switchAudioOutput = "Switch Audio Output"
    case toggleQuality = "Change Video Quality"
    case high = "High"
    case low = "Low"
    case medium = "Medium"
    case showParticipantList = "Show Participants List"
    case raiseHand = "Raise Hand"
    case startScreenShare = "Start Screen Share"
    case stopScreenShare = "Stop Screen Share"
    
    var style: UIAlertAction.Style {
        switch self {
        case .stopRecording, .remove, .endMeeting:
            return .destructive
        default:
            return .default
        }
    }
}
