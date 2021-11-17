//
//  ParticipantViewCell.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import VideoSDKRTC
import WebRTC

class ParticipantViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var videoView: RTCMTLVideoView!
    @IBOutlet weak var videoNameBackgroundView: UIView!
    @IBOutlet weak var videoViewNameLabel: UILabel!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameInitialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var livestreamIndicator: UIImageView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    
    
    // MARK: - Properties
    
    private var participant: Participant?
    
    // handling for mic
    private var micEnabled = false {
        didSet {
            updateMicButton()
        }
    }
    
    // handling for video
    private var videoEnabled = false {
        didSet {
            updateVideoButton()
        }
    }
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        setupVideoView()
        setupNameView()
        updateMicButton()
        
        // border
        contentView.layer.borderWidth = 4.0
        micButton.makeRounded()
        videoButton.makeRounded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }
    
    // MARK: - View Update
    
    func setParticipant(_ participant: Participant) {
        self.participant = participant
        
        let nameComponents = participant.displayName.components(separatedBy: " ")
        videoViewNameLabel.text = participant.displayName
        nameLabel.text = nameComponents.first
        
        nameInitialsLabel.text = nameComponents
            .reduce("") {
                ($0.isEmpty ? "" : "\($0.first?.uppercased() ?? "")") +
                ($1.isEmpty ? "" : "\($1.first?.uppercased() ?? "")")
            }
    }
    
    func updateView(forStream stream: MediaStream, enabled: Bool) {
        switch stream.kind {
        case .video:
            if let videotrack = stream.track as? RTCVideoTrack {
                
                if enabled {
                    // show video
                    videotrack.add(videoView)
                    showVideoView(true)
                } else {
                    // hide video
                    videotrack.remove(videoView)
                    showVideoView(false)
                }
            }
        case .audio:
            updateMic(enabled)
            
        default:
            break
        }
    }
    
    func showActiveSpeakerIndicator(_ show: Bool) {
        contentView.layer.borderColor = show ? UIColor.blue.cgColor : UIColor.clear.cgColor
    }
    
    func reset() {
        participant = nil
        livestreamIndicator.isHidden = true
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        [nameLabel, nameInitialsLabel].forEach {
            $0?.text = ""
        }
        
        if let videoTrack = participant?.streams.first(where: { $1.kind == .video })?.value.track as? RTCVideoTrack {
            videoTrack.remove(videoView)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func micButtonTapped(_ sender: Any) {
        if micEnabled {
            participant?.disableMic()
        } else {
            participant?.enableMic()
        }
    }
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        if videoEnabled {
            participant?.disableWebcam()
        } else {
            participant?.enableWebcam()
        }
    }
}

// MARK: - Show/Hide

extension ParticipantViewCell {
    
    func showVideoView(_ show: Bool) {
        videoEnabled = show
        videoView.isHidden = !show
        nameContainerView.isHidden = show
        
        if show {
            bringSubviewToFront(videoContainerView)
        } else {
            bringSubviewToFront(nameContainerView)
        }
    }
    
    func updateMic(_ enabled: Bool) {
        micEnabled = enabled
    }
}


// MARK: - Setup UI

extension ParticipantViewCell {
    
    func setupVideoView() {
        videoView.videoContentMode = .scaleAspectFill
        
        [videoView, videoContainerView, videoNameBackgroundView].forEach {
            $0?.layer.cornerRadius = 5
        }
        videoNameBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func setupNameView() {
        nameView.makeRounded()
        nameContainerView.layer.cornerRadius = 5
    }
    
    func updateMicButton() {
        let imageName = micEnabled ? "mic" : "mic.slash"
        let backgroundColor = micEnabled ? UIColor.gray.withAlphaComponent(0.8) : UIColor.red.withAlphaComponent(0.8)
        micButton.setImage(UIImage(systemName: imageName), for: .normal)
        micButton.backgroundColor = backgroundColor
    }
    
    func updateVideoButton() {
        let imageName = videoEnabled ? "video" : "video.slash"
        let backgroundColor = videoEnabled ? UIColor.gray.withAlphaComponent(0.8) : UIColor.red.withAlphaComponent(0.8)
        videoButton.setImage(UIImage(systemName: imageName), for: .normal)
        videoButton.backgroundColor = backgroundColor
    }
}
