//
//  ParticipantViewCell.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import VideoSDK
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
    
    @IBOutlet weak var mutedMicButton: UIButton!
    
    
    // MARK: - Properties
    
    private var participant: Participant?
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        setupVideoView()
        setupNameView()
        setupMicView()
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
            if enabled {
                // hide muted mic
                hideMutedMic(true)
            } else {
                // show muted mic
                hideMutedMic(false)
            }
            
        default:
            break
        }
    }
    
    func reset() {
        participant = nil
        
        [nameLabel, nameInitialsLabel].forEach {
            $0?.text = ""
        }
        
        if let videoTrack = participant?.streams.first(where: { $1.kind == .video })?.value.track as? RTCVideoTrack {
            videoTrack.remove(videoView)
        }
    }
}

// MARK: - Show/Hide

extension ParticipantViewCell {
    
    func showVideoView(_ show: Bool) {
        videoView.isHidden = !show
        nameContainerView.isHidden = show
        
        if show {
            bringSubviewToFront(videoContainerView)
        } else {
            bringSubviewToFront(nameContainerView)
        }
    }
    
    func hideMutedMic(_ hide: Bool) {
        mutedMicButton.isHidden = hide
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
    
    func setupMicView() {
        mutedMicButton.setImage(UIImage(systemName: "mic.slash"), for: .normal)
        mutedMicButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        mutedMicButton.isUserInteractionEnabled = false
        mutedMicButton.makeRounded()
    }
}
