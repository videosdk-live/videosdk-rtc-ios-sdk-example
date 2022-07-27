//
//  ButtonControlsView.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import VideoSDKRTC

class ButtonControlsView: UIView {
    
    // MARK: - Buttons
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var leaveMeetingButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Properties
    
    var onMicTapped: ((Bool) -> Void)?
    var onVideoTapped: ((Bool) -> Void)?
    var onEndMeetingTapped: (() -> Void)?
    var onMenuButtonTapped: (() -> Void)?
    var onChatButtonTapped: (() -> Void)?
    
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
    
    // Menu button
    var menuButtonEnabled: Bool = false {
        didSet {
            updateMenuButton()
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
    
    @IBAction func leaveMeetingButtonTapped(_ sender: Any) {
        onEndMeetingTapped?()
    }
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        onVideoTapped?(videoEnabled)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        onMenuButtonTapped?()
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        onChatButtonTapped?()
    }
    
}

extension ButtonControlsView {
    
    func setupUI() {
        self.layer.cornerRadius = 10
        
        updateMicButton()
        updateVideoButton()
        updateLeaveMeetingButton()
        updateMenuButton()
        updateChatButton()
        
        [micButton, videoButton, leaveMeetingButton, menuButton, chatButton].forEach {
            $0?.layer.cornerRadius = 8
            $0?.tintColor = .white
            $0?.heightAnchor.constraint(equalTo: $0!.widthAnchor, multiplier: 1.0).isActive = true
        }
    }
    
    func updateMicButton() {
        let imageName = micEnabled ? "mic_on" : "mic_off"
        let backgroundColor = micEnabled ? UIColor.systemLightBackground : UIColor.systemRed
        micButton.setImage(UIImage(named: imageName), for: .normal)
        micButton.backgroundColor = backgroundColor
    }
    
    func updateVideoButton() {
        let imageName = videoEnabled ? "camera_on" : "camera_off"
        let backgroundColor = videoEnabled ? UIColor.systemLightBackground : UIColor.systemRed
        videoButton.setImage(UIImage(named: imageName), for: .normal)
        videoButton.backgroundColor = backgroundColor
    }
    
    func updateLeaveMeetingButton() {
        leaveMeetingButton.setImage(UIImage(named: "call_end"), for: .normal)
        leaveMeetingButton.backgroundColor = UIColor.systemRed
    }
    
    func updateMenuButton() {
        let imageName = "more"
        let backgroundColor = !menuButtonEnabled ? UIColor.systemLightBackground : UIColor.systemRed
        menuButton.setImage(UIImage(named: imageName), for: .normal)
        menuButton.backgroundColor = backgroundColor
    }
    
    func updateChatButton() {
        let imageName = "chat"
        let backgroundColor = UIColor.systemLightBackground
        chatButton.setImage(UIImage(named: imageName), for: .normal)
        chatButton.backgroundColor = backgroundColor
    }
}
