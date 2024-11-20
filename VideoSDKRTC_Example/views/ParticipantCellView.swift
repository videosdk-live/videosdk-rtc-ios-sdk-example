//
//  ParticipantCellView.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 31/01/23.
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
        
        cellParticipantMicEnable?.layer.cornerRadius = 17.5
        cellParticipantMicEnable?.layer.borderColor = UIColor.lightGray.cgColor
        cellParticipantMicEnable?.layer.borderWidth = 1
        
        cellParticipantVideoEnable?.layer.cornerRadius = 17.5
        cellParticipantVideoEnable?.layer.borderColor = UIColor.lightGray.cgColor
        cellParticipantVideoEnable?.layer.borderWidth = 1
        
        let nameComponents = self.participant?.displayName.components(separatedBy: " ")
        cellParticipantName?.text = nameComponents?.first
        
//        cellParticipantIsHost?.text = self.participant?.isLocal ?? false ? "Host" : ""
        
        cellParticipantIsHost?.isHidden = self.participant?.isLocal ?? false ? false : true
        
        if (self.participant?.streams.first(where: { $1.kind == .state(value: .audio) })?.value) != nil {
            cellParticipantMicEnable?.setImage(UIImage(named: "mic_on"), for: .normal)
            cellParticipantMicEnable?.backgroundColor = UIColor.clear
        } else {
            cellParticipantMicEnable?.setImage(UIImage(named: "mic_off"), for: .normal)
            cellParticipantMicEnable?.backgroundColor = UIColor.systemRed
        }
        
        if (self.participant?.streams.first(where: { $1.kind == .state(value: .video) })?.value) != nil {
            cellParticipantVideoEnable?.setImage(UIImage(named: "camera_on"), for: .normal)
            cellParticipantVideoEnable?.backgroundColor = UIColor.clear
        } else {
            cellParticipantVideoEnable?.setImage(UIImage(named: "camera_off"), for: .normal)
            cellParticipantVideoEnable?.backgroundColor = UIColor.systemRed
        }
    }
}

