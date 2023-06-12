//
//  StatsModel.swift
//  VideoSDK_Example
//
//  Created by Parth Asodariya on 12/06/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

class StatsModel {
    var header: String
    var audioStat: String
    var videoStat: String
    
    init(header: String, audioStat: String, videoStat: String) {
        self.header = header
        self.audioStat = audioStat
        self.videoStat = videoStat
    }
}
