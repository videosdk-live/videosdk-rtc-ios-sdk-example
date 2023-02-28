//
//  ButtonControlsView.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 26/01/23.
//


import UIKit
import VideoSDKRTC

class ButtonControlsView: UIView {
    
    // MARK: - Buttons
    
    @IBOutlet weak var viewEndMeetingContainer: UIView!
    @IBOutlet weak var leaveMeetingButton: UIButton!
    
    @IBOutlet weak var viewToggleMicContainer: UIView!
    @IBOutlet weak var imgToggleMic: UIImageView!
    @IBOutlet weak var btnToggleMic: UIButton!
    
    @IBOutlet weak var viewToggleVideoContainer: UIView!
    @IBOutlet weak var imgToggleVideo: UIImageView!
    @IBOutlet weak var btnToggleVideo: UIButton!
    
    @IBOutlet weak var viewChatContainer: UIView!
    @IBOutlet weak var btnChatMessage: UIButton!
    
    @IBOutlet weak var viewMoreOptionsContainer: UIView!
    @IBOutlet weak var btnMoreOptions: UIButton!
    
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
        case .state(value: .video):
            self.videoEnabled = enabled
        case .state(value: .audio):
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
        
        updateMicButton()
        updateVideoButton()
        updateLeaveMeetingButton()
        updateMenuButton()
        updateChatButton()
        
        [viewEndMeetingContainer, viewToggleMicContainer, viewToggleVideoContainer, viewChatContainer, viewMoreOptionsContainer].forEach {
            $0.roundCorners(corners: [.allCorners], radius: 12.0)
        }
        
        [viewToggleMicContainer, viewToggleVideoContainer, viewChatContainer, viewMoreOptionsContainer].forEach {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        }
    }
    
    func updateMicButton() {
        let imageName = micEnabled ? "mic_on" : "mic_off"
        let backgroundColor = micEnabled ? UIColor.clear : UIColor.systemLightBackground
        imgToggleMic.image = UIImage(named: imageName)
        imgToggleMic.tintColor = micEnabled ? UIColor.white : UIColor.black
        viewToggleMicContainer.backgroundColor = backgroundColor
    }
    
    func updateVideoButton() {
        let imageName = videoEnabled ? "camera_on" : "camera_off"
        let backgroundColor = videoEnabled ? UIColor.clear : UIColor.systemLightBackground
        imgToggleVideo.image = UIImage(named: imageName)
        imgToggleVideo.tintColor = videoEnabled ? UIColor.white : UIColor.black
        viewToggleVideoContainer.backgroundColor = backgroundColor
    }
    
    func updateLeaveMeetingButton() {
//        btnLeaveMeeting.setImage(UIImage(named: "call_end"), for: .normal)
//        btnLeaveMeeting.backgroundColor = UIColor.systemRed
    }
    
    func updateMenuButton() {
//        let imageName = "more"
//        let backgroundColor = !menuButtonEnabled ? UIColor.systemLightBackground : UIColor.systemRed
//        btnMoreOptions.setImage(UIImage(named: imageName), for: .normal)
//        btnMoreOptions.backgroundColor = backgroundColor
    }
    
    func updateChatButton() {
//        let imageName = "chat"
//        let backgroundColor = UIColor.systemLightBackground
//        btnChat.setImage(UIImage(named: imageName), for: .normal)
//        btnChat.backgroundColor = backgroundColor
    }
}
