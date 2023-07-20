//
//  AVAudioSession+Extension.swift
//  VideoSDK_Example
//
//  Created by ANSUYA on 12/02/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

var micPaused: Bool = false

extension AVAudioSession {
    
    func changeAudioOutput(presenterViewController : UIViewController, completion: @escaping (Bool) -> ()) {
        let CHECKED_KEY = "checked"
        let IPHONE_TITLE = "iPhone"
        let HEADPHONES_TITLE = "Headphones"
        let SPEAKER_TITLE = "Speaker"
        let CANCEL_TITLE = "Cancel"
        
        var deviceAction = UIAlertAction()
        var headphonesExist = false
        
        let currentRoute = self.currentRoute
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for input in self.availableInputs!{
            
            switch input.portType  {
            case AVAudioSession.Port.bluetoothA2DP, AVAudioSession.Port.bluetoothHFP, AVAudioSession.Port.bluetoothLE:
                let action = UIAlertAction(title: input.portName, style: .default) { (action) in
                    do {
                        // remove speaker if needed
                        try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        
                        // set new input
                        try self.setPreferredInput(input)
                        self.setupCommandCenter { isPlay in
                            completion(isPlay)
                        }
                    } catch let error as NSError {
                        print("audioSession error change to input: \(input.portName) with error: \(error.localizedDescription)")
                    }
                }
                
                if currentRoute.outputs.contains(where: {return $0.portType == input.portType}){
                    action.setValue(true, forKey: CHECKED_KEY)
                }
                
                if action.title?.count ?? 0 > 0 {
                    optionMenu.addAction(action)
                }
                break
                
            case AVAudioSession.Port.builtInReceiver: // AVAudioSession.Port.builtInMic
                deviceAction = UIAlertAction(title: IPHONE_TITLE, style: .default) { (action) in
                    do {
                        // remove speaker if needed
                        try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        
                        // set new input
                        try self.setPreferredInput(input)
                        self.setupCommandCenter { isPlay in
                            completion(isPlay)
                        }
                    } catch let error as NSError {
                        print("audioSession error change to input: \(input.portName) with error: \(error.localizedDescription)")
                    }
                }
                
                if currentRoute.outputs.contains(where: {return $0.portType == input.portType}){
                    deviceAction.setValue(true, forKey: CHECKED_KEY)
                }
                break
                
            case AVAudioSession.Port.headphones, AVAudioSession.Port.headsetMic:
                headphonesExist = true
                let action = UIAlertAction(title: HEADPHONES_TITLE, style: .default) { (action) in
                    do {
                        // remove speaker if needed
                        try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                        
                        // set new input
                        try self.setPreferredInput(input)
                        self.setupCommandCenter { isPlay in
                            completion(isPlay)
                        }
                    } catch let error as NSError {
                        print("audioSession error change to input: \(input.portName) with error: \(error.localizedDescription)")
                    }
                }
                
                if currentRoute.outputs.contains(where: {return $0.portType == input.portType}){
                    action.setValue(true, forKey: CHECKED_KEY)
                }
                
                if action.title?.count ?? 0 > 0 {
                    optionMenu.addAction(action)
                }
                break
            default:
                break
            }
        }
        
        if !headphonesExist {
            if deviceAction.title?.count ?? 0 > 0 {
                optionMenu.addAction(deviceAction)
            }
        }
        
        let speakerOutput = UIAlertAction(title: SPEAKER_TITLE, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            do {
                try self.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch let error as NSError {
                print("audioSession error turning on speaker: \(error.localizedDescription)")
            }
        })
        
        if currentRoute.outputs.contains(where: {return $0.portType == AVAudioSession.Port.builtInSpeaker}){
            speakerOutput.setValue(true, forKey: CHECKED_KEY)
        }
        
        if speakerOutput.title?.count ?? 0 > 0 {
            optionMenu.addAction(speakerOutput)
        }
        
        
        let cancelAction = UIAlertAction(title: CANCEL_TITLE, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        optionMenu.addAction(cancelAction)
        presenterViewController.present(optionMenu, animated: true, completion: nil)
        
    }
    
    func setupCommandCenter( completion: @escaping (Bool) -> ()) {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event in
            print("play")
            completion(true)
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { event in
            print("pause")
            micPaused = !micPaused
            completion(micPaused)
            return .success
        }
//        commandCenter.playCommand.addTarget(self, action: #selector(self.playCenter))
//        commandCenter.pauseCommand.addTarget(self, action: #selector(self.pauseCenter))
    
    }

    @objc func playCenter() {
        print("play")
//        self.state = .play
//        self.playBtn.setBackgroundImage("some image"), for: .normal)
//        self.player.play()
//        self.fetchTracks()
    }
    
    @objc func pauseCenter() {
        print("pause")
//        self.state = .pause
//        self.playBtn.setBackgroundImage("some image"), for: .normal)
//        self.player.pause()
//        self.fetchTracks()
    }
}
