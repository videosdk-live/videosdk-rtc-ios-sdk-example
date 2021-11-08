//
//  ScreenSharingView.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 22/10/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import VideoSDKRTC
import WebRTC

class ScreenSharingView: UIView {

    // MARK: - Views
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoView: RTCMTLVideoView!
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    // MARK: - Public
    
    func showMediastream(_ stream: MediaStream) {
        guard let track = stream.track as? RTCVideoTrack else {
            return
        }
        track.add(videoView)
    }
    
    func hideMediastream(_ stream: MediaStream) {
        guard let track = stream.track as? RTCVideoTrack else {
            return
        }
        track.remove(videoView)
    }
}

private extension ScreenSharingView {
    
    func setupViews() {
        videoView.videoContentMode = .scaleAspectFit
        
        [containerView, videoView].forEach {
            $0?.layer.cornerRadius = 5
        }
    }
}
