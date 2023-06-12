//
//  StatsViewController.swift
//  VideoSDK_Example
//
//  Created by Parth Asodariya on 12/06/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import VideoSDKRTC

class StatsViewController: UIViewController {

    @IBOutlet weak var tblStats: UITableView!
    
    var participant: Participant? = nil
    var statsInterval: Timer? = nil
    var audioStats: [String: Any] = [:]
    var videoStats: [String: Any] = [:]
    var statsCollection: [StatsModel]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statsInterval = Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(self.calculateStats),
                             userInfo: nil,
                             repeats: true)
        
        
    }
    
    @objc func calculateStats() {
        audioStats = participant?.getAudioStats() ?? [:]
        videoStats = participant?.getVideoStats() ?? [:]
        print("audioStats: \(audioStats)")
        print("videoStats: \(videoStats)")
        statsCollection?.removeAll()
        statsCollection?.append(StatsModel(header: "Latency", audioStat: String((audioStats["rtt"] as? Double ?? 0.0).rounded(toPlaces: 2)), videoStat: String((videoStats["rtt"] as? Double ?? 0.0).rounded(toPlaces: 2))))
        statsCollection?.append(StatsModel(header: "Jitter", audioStat: String((audioStats["jitter"] as? Double ?? 0.0).rounded(toPlaces: 2)), videoStat: String((videoStats["jitter"] as? Double ?? 0.0).rounded(toPlaces: 2))))
        let audioPacketsLost: Double = ((Double(audioStats["packetsLost"] as? Int ?? 0)/Double(audioStats["totalPackets"] as? Int ?? 0)) * 100).rounded(toPlaces: 2)
        let videoPacketsLost: Double = ((Double(videoStats["packetsLost"] as? Int ?? 0)/Double(videoStats["totalPackets"] as? Int ?? 0)) * 100).rounded(toPlaces: 2)
        statsCollection?.append(StatsModel(header: "Packet Lost", audioStat: "\(audioPacketsLost)", videoStat: "\(videoPacketsLost)"))
        let aBitrate = "\(audioStats["bitrate"] ?? 0.0)"
        let vBitrate = "\(videoStats["bitrate"] ?? 0.0)"
        let audioBit = "\(aBitrate.split(separator: ".")[0]).\(aBitrate.split(separator: ".")[1].prefix(2))"
        let videoBit = "\(vBitrate.split(separator: ".")[0]).\(vBitrate.split(separator: ".")[1].prefix(2))"
        statsCollection?.append(StatsModel(header: "Bitrate", audioStat: audioBit, videoStat: videoBit))
        let audioSize = audioStats["size"] as? [String:Any] ?? [:]
        let videoSize = videoStats["size"] as? [String:Any] ?? [:]
        let audioHeight = audioSize["height"] as? Int ?? 0
        let audioWidth = audioSize["width"] as? Int ?? 0
        let videoHeight = videoSize["height"] as? Int ?? 0
        let videoWidth = videoSize["width"] as? Int ?? 0
        statsCollection?.append(StatsModel(header: "Frame Rate", audioStat: String(audioSize["width"] as? Double ?? 0.0), videoStat: String(videoSize["framerate"] as? Double ?? 0.0)))
        statsCollection?.append(StatsModel(header: "Resolution", audioStat: "\(audioHeight)X\(audioWidth)" == "0X0" ? "-" : "\(audioHeight)X\(audioWidth)", videoStat: "\(videoHeight)X\(videoWidth)" == "0X0" ? "-" : "\(videoHeight)X\(videoWidth)"))
        statsCollection?.append(StatsModel(header: "Codec", audioStat: audioStats["codec"] as? String ?? "-", videoStat: videoStats["codec"] as? String ?? "-"))
        tblStats.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if statsInterval != nil {
            statsInterval?.invalidate()
            statsInterval = nil
        }
    }
    
}

extension StatsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statsCollection?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participantCell = tableView.dequeueReusableCell(withIdentifier: "ParticipantStatsCellView", for: indexPath) as! ParticipantStatsCellView
    
        participantCell.lblStatsHeader.text = statsCollection![indexPath.row].header
        participantCell.lblAudioValue.text = statsCollection![indexPath.row].audioStat
        participantCell.lblVideoValue.text = statsCollection![indexPath.row].videoStat
        
        return participantCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
