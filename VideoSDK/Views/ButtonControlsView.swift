//
//  ButtonControlsView.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import VideoSDK

class ButtonControlsView: UIView {
    
    // MARK: - Buttons
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var endMeetingButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Properties
    
    var onMicTapped: ((Bool) -> Void)?
    var onVideoTapped: ((Bool) -> Void)?
    var onEndMeetingTapped: (() -> Void)?
    
    // handling for mic
    var micEnabled = true {
        didSet {
            updateMicButton()
        }
    }
    
    // handling for video
    var videoEnabled = true {
        didSet {
            updateVideoButton()
        }
    }
    
    // Update Buttons
    func updateButtons(forStream stream: MediaStream, enabled: Bool) {
        switch stream.kind {
        case .video:
            self.videoEnabled = enabled
        case .audio:
            self.micEnabled = enabled
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @IBAction func micButtonTapped(_ sender: Any) {
        onMicTapped?(micEnabled)
    }
    
    @IBAction func endMeetingButtonTapped(_ sender: Any) {
        onEndMeetingTapped?()
    }
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        onVideoTapped?(videoEnabled)
    }
}

extension ButtonControlsView {
    
    func setupUI() {
        self.layer.cornerRadius = 10
        
        updateMicButton()
        updateVideoButton()
        updateEndMeetingButton()
        
        [micButton, videoButton, endMeetingButton].forEach {
            $0?.makeRounded()
            $0?.tintColor = .white
        }
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
    
    func updateEndMeetingButton() {
        endMeetingButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        endMeetingButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
    }
}
