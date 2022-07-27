//
//  ParticipantCellView.swift
//  VideoSDK_Example
//
//  Created by Parth Asodariya on 25/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import VideoSDKRTC

class ParticipantCellView: UITableViewCell {
    @IBOutlet weak var cellBackgroundView: UIView?
    @IBOutlet weak var cellParticipantImageView: UIImageView?
    @IBOutlet weak var cellParticipantName: UILabel?
    @IBOutlet weak var cellParticipantIsHost: UILabel?
    @IBOutlet weak var cellParticipantMicEnable: UIButton?
    @IBOutlet weak var cellParticipantVideoEnable: UIButton?
    
    // MARK: - Properties
    
    private var participant: Participant?
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupUI(_ participant: Participant) {
        self.participant = participant
        
        cellBackgroundView?.layer.cornerRadius = 10.0
        
        let nameComponents = self.participant?.displayName.components(separatedBy: " ")
        cellParticipantName?.text = nameComponents?.first
        
        cellParticipantIsHost?.text = self.participant?.isLocal ?? false ? "Host" : ""
        
        cellParticipantIsHost?.isHidden = self.participant?.isLocal ?? false ? false : true
        
        if (self.participant?.streams.first(where: { $1.kind == .audio })?.value) != nil {
            cellParticipantMicEnable?.setImage(UIImage(named: "mic_on"), for: .normal)
        } else {
            cellParticipantMicEnable?.setImage(UIImage(named: "mic_off"), for: .normal)
        }
        
        if (self.participant?.streams.first(where: { $1.kind == .video })?.value) != nil {
            cellParticipantVideoEnable?.setImage(UIImage(named: "camera_on"), for: .normal)
        } else {
            cellParticipantVideoEnable?.setImage(UIImage(named: "camera_off"), for: .normal)
        }
        
        
        
    }
}
