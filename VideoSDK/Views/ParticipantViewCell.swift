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
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameInitialsLabel: UILabel!
    
    @IBOutlet weak var nameBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var livestreamIndicator: UIImageView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    // menu button tap handler
    public var onMenuTapped: ((Participant) -> Void)?
    
    // MARK: - Properties
    
    private var participant: Participant?
    
    // handling for mic
    private(set) var micEnabled = false
    
    // handling for video
    private(set) var videoEnabled = false
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        // border
        contentView.layer.borderWidth = 4.0
        
        setupVideoView()
        setupNameView()
        setupNameBackgroundView()
        setupButtons()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }
    
    // MARK: - View Update
    
    func setParticipant(_ participant: Participant) {
        self.participant = participant
        
        let nameComponents = participant.displayName.components(separatedBy: " ")
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
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        guard let peer = participant else { return }
        onMenuTapped?(peer)
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
        updateMicButton()
    }
}


// MARK: - Setup UI

extension ParticipantViewCell {
    
    func setupVideoView() {
        videoView.videoContentMode = .scaleAspectFill
        
        [videoView, videoContainerView].forEach {
            $0?.layer.cornerRadius = 5
        }
    }
    
    func setupNameView() {
        nameView.makeRounded()
        nameContainerView.layer.cornerRadius = 5
    }
    
    func setupNameBackgroundView() {
        nameBackgroundView.layer.cornerRadius = 5
        nameBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        nameLabel.textColor = UIColor.white
    }
    
    func setupButtons() {
        micButton.makeRounded()
        micButton.setImage(UIImage(named: "mic_off"), for: .normal)
        micButton.backgroundColor = UIColor.systemRed
        micButton.isUserInteractionEnabled = false
        updateMicButton()
        
        menuButton.setImage(UIImage(named: "more"), for: .normal)
        menuButton.layer.cornerRadius = 5
        menuButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func updateMicButton() {
        micButton.alpha = micEnabled ? 0.0 : 1.0
    }
}
