//
//  BackgroundKeepAlive.swift
//  VideoSDK_Example
//
//  Created by Parth Asodariya on 03/07/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import AVFoundation

/// Keeps the app running in the background by looping a silent buffer while
/// no other audio I/O (mic/remote audio) is active. iOS only honors the
/// `audio` background mode while audio hardware is actually running, so a
/// meeting with no audio tracks gets suspended and drops its socket without
/// this. Note: App Review guideline 2.5.4 requires background audio to be
/// used for its intended purpose — prefer real audio, PiP, or CallKit where
/// possible.
final class BackgroundKeepAlive {

    static let shared = BackgroundKeepAlive()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var isRunning = false

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode,
                       format: AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1))
        engine.mainMixerNode.outputVolume = 0
    }

    func start() {
        guard !isRunning else { return }

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1),
              let silence = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4410) else { return }
        silence.frameLength = silence.frameCapacity

        do {
            try engine.start()
        } catch {
            print("BackgroundKeepAlive: failed to start engine: \(error.localizedDescription)")
            return
        }

        player.play()
        player.scheduleBuffer(silence, at: nil, options: .loops)
        isRunning = true
        print("BackgroundKeepAlive: started")
    }

    func stop() {
        guard isRunning else { return }
        player.stop()
        engine.stop()
        isRunning = false
        print("BackgroundKeepAlive: stopped")
    }
}
