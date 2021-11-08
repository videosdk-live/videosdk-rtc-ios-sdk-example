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
    @IBOutlet weak var cameraButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - Properties
    
    var onMicTapped: ((Bool) -> Void)?
    var onVideoTapped: ((Bool) -> Void)?
    var onEndMeetingTapped: (() -> Void)?
    var onMenuButtonTapped: (() -> Void)?
    var onCameraTapped: ((CameraPosition) -> Void)?
    
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
    
    // handling camera position
    var cameraPosition = CameraPosition.front {
        didSet {
            updateCameraButton()
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
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        cameraPosition.toggle()
        onCameraTapped?(cameraPosition)
    }
    
}

extension ButtonControlsView {
    
    func setupUI() {
        self.layer.cornerRadius = 10
        
        updateMicButton()
        updateVideoButton()
        updateLeaveMeetingButton()
        updateMenuButton()
        updateCameraButton()
        
        [micButton, videoButton, leaveMeetingButton, menuButton, cameraButton].forEach {
            $0?.makeRounded()
            $0?.tintColor = .white
            $0?.heightAnchor.constraint(equalTo: $0!.widthAnchor, multiplier: 1.0).isActive = true
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
    
    func updateLeaveMeetingButton() {
        leaveMeetingButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        leaveMeetingButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
    }
    
    func updateMenuButton() {
        let imageName = "ellipsis"
        let backgroundColor = !menuButtonEnabled ? UIColor.gray.withAlphaComponent(0.8) : UIColor.red.withAlphaComponent(0.8)
        menuButton.setImage(UIImage(systemName: imageName), for: .normal)
        menuButton.backgroundColor = backgroundColor
    }
    
    func updateCameraButton() {
        let imageName = cameraPosition == .front ? "arrow.triangle.2.circlepath.camera" : "arrow.triangle.2.circlepath.camera.fill"
        let backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        cameraButton.setImage(UIImage(systemName: imageName), for: .normal)
        cameraButton.backgroundColor = backgroundColor
    }
}
