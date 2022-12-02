//
//  NewMeetingViewController.swift
//  VideoSDK_Example
//
//  Created by Parth Asodariya on 29/11/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VideoSDKRTC
import AVFoundation
import WebRTC

private let addStreamOutputSegueIdentifier = "Add Livestream Outputs"
private let recordingWebhookUrl = "https://www.google.com"
private let CHAT_TOPIC = "CHAT"
private let RAISE_HAND_TOPIC = "RAISE_HAND"

class NewMeetingViewController: UIViewController {
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var participantMainView: UIView!
    @IBOutlet weak var participantVideoView: RTCMTLVideoView!
    @IBOutlet weak var participantNameView: UIView!
    @IBOutlet weak var participantNameBackgroundView: UIView!
    @IBOutlet weak var lblParticipantName: UILabel!
    
    @IBOutlet weak var localParticipantMainView: UIView!
    @IBOutlet weak var localParticipantVideoContainerView: UIView!
    @IBOutlet weak var localParticipantVideoView: RTCMTLVideoView!
    @IBOutlet weak var localParticipantNameContainerView: UIView!
    @IBOutlet weak var localParticipantNameBackgroundView: UIView!
    @IBOutlet weak var lblLocalParticipantName: UILabel!
    
    
    @IBOutlet weak var meetingIDButton: UIButton!
    /// View for handling meeting controls consists of Mic, Video, and End buttons
    lazy var buttonControlsView: ButtonControlsView! = {
        Bundle.main.loadNibNamed("ButtonControlsView", owner: self, options: nil)?[0] as! ButtonControlsView
    }()
    
    /// Meeting data - required to start
    var meetingData: MeetingData!
    
    /// current meeting reference
    private var meeting: Meeting?
    
    /// keep track of participant indexPath for reference
    private var indexPaths: [String : IndexPath] = [:]
    
    /// video participants including self to show in Grid
    private var participants: [Participant] = []
    
    /// keep track of recording
    private var recordingStarted = false
    
    /// keep track of livestream
    private var liveStreamStarted = false
    
    /// Camera position
    private var cameraPosition = CameraPosition.front
    
    // MARK: - LIFE CYCLE
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
        setupVideoView()
        setupNameView()
        setupNameBackgroundView()
        
        // config
        VideoSDK.config(token: meetingData.token)

        // init meeting
        initializeMeeting()
        
        // set meeting id in button text
        meetingIDButton.setTitle("Meeting Id : \(meetingData.meetingId)", for: .normal)
    
    }
    
    // MARK: - Meeting
    
    private func initializeMeeting() {
        
        // initialize
        meeting = VideoSDK.initMeeting(
            meetingId: meetingData.meetingId,
            participantName: meetingData.name,
            micEnabled: meetingData.micEnabled,
            webcamEnabled: meetingData.cameraEnabled
        )
        
        // listener
        meeting?.addEventListener(self)
        
        // join
        meeting?.join()
    }
    

    // MARK: - Actions
    
    @IBAction func onClickCopyMeetingID(_ sender: UIButton) {
        UIPasteboard.general.string = meetingData.meetingId
        self.showToast(message: "Meeting id copied", font: .systemFont(ofSize: 18))
    }
   
}

// MARK: - MeetingEventListener

extension NewMeetingViewController: MeetingEventListener {

    /// Meeting started
    func onMeetingJoined() {
        
        // handle local participant on start
        guard let localParticipant = self.meeting?.localParticipant else { return }
        
        // add to list
        participants.append(localParticipant)
        
        // add event listener
        localParticipant.addEventListener(self)
        
        // show in ui
        //addParticipantToGridView()
        let nameComponents = localParticipant.displayName.components(separatedBy: " ")
        lblLocalParticipantName.text = nameComponents.first
        
        lblLocalParticipantName.text = nameComponents
            .reduce("") {
                ($0.isEmpty ? "" : "\($0.first?.uppercased() ?? "")") +
                ($1.isEmpty ? "" : "\($1.first?.uppercased() ?? "")")
            }
        
        // listen/subscribe for chat topic
        meeting?.pubsub.subscribe(topic: CHAT_TOPIC, forListener: self)
        
    // listen/subscribe for raise-hand topic
        meeting?.pubsub.subscribe(topic: RAISE_HAND_TOPIC, forListener: self)
    }
    
    /// Meeting ended
    func onMeetingLeft() {
        
        // remove listeners
        meeting?.localParticipant.removeEventListener(self)
        meeting?.removeEventListener(self)
        
        // dismiss controller
        dismiss(animated: true, completion: nil)
    }
    
    /// A new participant joined
    func onParticipantJoined(_ participant: Participant) {
        
        // add new participant to list
        participants.append(participant)
        
        // add listener
        participant.addEventListener(self)
        
        let nameComponents = participant.displayName.components(separatedBy: " ")
        lblParticipantName.text = nameComponents.first
        
        lblParticipantName.text = nameComponents
            .reduce("") {
                ($0.isEmpty ? "" : "\($0.first?.uppercased() ?? "")") +
                ($1.isEmpty ? "" : "\($1.first?.uppercased() ?? "")")
            }
        
        //notification to participants via sharing participants
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "shareParticipants"), object: nil, userInfo: ["participants": participants])
    }
    
    /// A participant left from the meeting
    /// - Parameter participant: participant object
    func onParticipantLeft(_ participant: Participant) {
        
        // remove listener
        participant.removeEventListener(self)
        
        // find participant
        guard let index = self.participants.firstIndex(where: { $0.id == participant.id }) else {
            return
        }
        
        // remove participant from list
        participants.remove(at: index)
        
        // hide from ui
//        removeParticipantFromGridView(at: index)
        
        //notification to participants via sharing participants
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "shareParticipants"), object: nil, userInfo: ["participants": participants])
    }
    
    /// Called after recording starts
    func onRecordingStarted() {
        recordingStarted = true
        updateMenuButton()
        showAlert(title: "Recording Started", message: nil, autoDismiss: true)
    }
    
    /// Caled after recording stops
    func onRecordingStoppped() {
        print("meeting recording stopped")
        recordingStarted = false
        updateMenuButton()
    }
    
    /// Called after livestream starts
    func onLivestreamStarted() {
        liveStreamStarted = true
        updateMenuButton()
        showAlert(title: "Livestream Started", message: nil, autoDismiss: true)
    }
    
    /// Called after livestream stops
    func onLivestreamStopped() {
        print("livestream stopped")
        liveStreamStarted = false
        updateMenuButton()
    }
    
    /// Called when speaker is changed
    /// - Parameter participantId: participant id of the speaker, nil when no one is speaking.
    func onSpeakerChanged(participantId: String?) {
        
        // show indication for active speaker
//        if let participant = participants.first(where: { $0.id == participantId }),
//            let cell = cellForParticipant(participant) {
//
//            cell.showActiveSpeakerIndicator(true)
//        }
//
//        // hide indication for others participants
//        let otherParticipants = participants.filter { $0.id != participantId }
//        for participant in otherParticipants {
//            if let cell = cellForParticipant(participant) {
//                cell.showActiveSpeakerIndicator(false)
//            }
//        }
    }
    
    /// Called when host requests to turn on the mic/audio
    func onMicRequested(participantId: String?, accept: @escaping () -> Void, reject: @escaping () -> Void) {
        let requesterName = participants.first(where: { $0.id == participantId })?.displayName ?? "Meeting host"
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            reject()
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            accept()
        }
        showAlert(
            title: "Turn On Mic?",
            message: "\(requesterName) has requested to turn on the mic.",
            actions: [cancelAction, confirmAction])
    }
    
    /// Called when host requests to turn on the camera/video
    func onWebcamRequested(participantId: String?, accept: @escaping () -> Void, reject: @escaping () -> Void) {
        let requesterName = participants.first(where: { $0.id == participantId })?.displayName ?? "Meeting host"
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            reject()
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            accept()
        }
        
        showAlert(
            title: "Turn On Camera?",
            message: "\(requesterName) has requested to turn on the camera.",
            actions: [cancelAction, confirmAction])
    }
    
}

// MARK: - ParticipantEventListener

extension NewMeetingViewController: ParticipantEventListener {
 
    /// Participant has enabled mic, video or screenshare
    /// - Parameters:
    ///   - stream: enabled stream object
    ///   - participant: participant object
    func onStreamEnabled(_ stream: MediaStream, forParticipant participant: Participant) {
        
        if stream.kind == .video {
            // show video
            if participant.isLocal {
                guard let track = stream.track as? RTCVideoTrack else {
                    return
                }
                track.add(localParticipantVideoView)
                localParticipantNameContainerView.isHidden = true
                localParticipantNameBackgroundView.isHidden = true
                showVideoView(true, view: localParticipantVideoView)
            } else {
                guard let track = stream.track as? RTCVideoTrack else {
                    return
                }
                track.add(participantVideoView)
                participantNameView.isHidden = true
                participantNameBackgroundView.isHidden = true
                showVideoView(true, view: participantVideoView)
            }
            return
        }
        
        if participant.isLocal {
            // turn on controls for local participant
            self.buttonControlsView.updateButtons(forStream: stream, enabled: true)
        }
    }
    
    /// Participant has disabled mic, video or screenshare
    /// - Parameters:
    ///   - stream: disabled stream object
    ///   - participant: participant object
    func onStreamDisabled(_ stream: MediaStream, forParticipant participant: Participant) {
        
        if stream.kind == .video {
            // show video
            if participant.isLocal {
                guard let track = stream.track as? RTCVideoTrack else {
                    return
                }
                track.remove(localParticipantVideoView)
                localParticipantNameContainerView.isHidden = false
                localParticipantNameBackgroundView.isHidden = false
                showVideoView(false, view: localParticipantVideoView)
            } else {
                guard let track = stream.track as? RTCVideoTrack else {
                    return
                }
                track.remove(participantVideoView)
                participantNameView.isHidden = false
                participantNameBackgroundView.isHidden = false
                showVideoView(false, view: participantVideoView)
            }
            return
        }
        
        if participant.isLocal {
            // turn off controls for local participant
            self.buttonControlsView.updateButtons(forStream: stream, enabled: false)
        }
    }
}

// MARK: - Chat

extension NewMeetingViewController {
    
    func openChat() {
        let chatViewController = ChatViewController(meeting: meeting!, topic: CHAT_TOPIC)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

// MARK: - PubSubMessageListener

extension NewMeetingViewController: PubSubMessageListener {
    
    func onMessageReceived(_ message: PubSubMessage) {
        print("Message Received:= " + message.message)
        let localParticipantID = participants.first(where: { $0.isLocal == true })?.id
        if(message.topic == RAISE_HAND_TOPIC){
           
            self.showToast(message: "\(message.senderId == localParticipantID ? "You" : "\(message.senderName)") raised hand 🖐🏼", font: .systemFont(ofSize: 18))
        } else {
            if let chatViewController = navigationController?.topViewController as? ChatViewController {
                chatViewController.showNewMessage(message)
                
            } else {
                
                if message.senderId != localParticipantID {
                    self.showToast(message: "\(message.senderName) says: \(message.message)", font: .systemFont(ofSize: 18))
                }
            }
        }
        
        
    }
}

// MARK: - Actions

private extension NewMeetingViewController {
    
    func setupActions() {
        
        // onMicTapped
        buttonControlsView.onMicTapped = { on in
            if !on {
                self.meeting?.unmuteMic()
            } else {
                self.meeting?.muteMic()
            }
        }
        
        // onVideoTapped
        buttonControlsView.onVideoTapped = { on in
            //self.meeting?.pubsub.publish(topic: CHAT_TOPIC, message: "How are you?", options: [:])
            
            if !on {
                self.meeting?.enableWebcam()
            } else {
                self.meeting?.disableWebcam()
            }
        }
        
        // onEndMeetingTapped
        buttonControlsView.onEndMeetingTapped = {
            let menuOptions: [MenuOption] = [.leaveMeeting, .endMeeting]
            
            self.showActionsheet(options: menuOptions, fromView: self.buttonControlsView.leaveMeetingButton) { option in
                switch option {
                case .leaveMeeting:
                    self.meeting?.leave()
                case .endMeeting:
                    self.meeting?.end()
                default:
                    break
                }
            }
        }
        
        /// Chat Button Tap
        buttonControlsView.onChatButtonTapped = {
            self.openChat()
        }
        
        /// Menu tap
        buttonControlsView.onMenuButtonTapped = {
            var menuOptions: [MenuOption] = []
            menuOptions.append(.showParticipantList)
            menuOptions.append(.raiseHand)
            menuOptions.append(.switchCamera)
            menuOptions.append(.switchAudioOutput)
            menuOptions.append(!self.recordingStarted ? .startRecording : .stopRecording)
            menuOptions.append(!self.liveStreamStarted ? .startLivestream : .stopLivestream)
            
            self.showActionsheet(options: menuOptions, fromView: self.buttonControlsView.menuButton) { option in
                switch option {
                case .switchCamera:
                    self.meeting?.switchWebcam()
            
                case .startRecording:
                    self.showAlertWithTextField(title: "Enter Webhook Url", value: recordingWebhookUrl) { url in
                        self.meeting?.startRecording(webhookUrl: url!)
                    }
                case .stopRecording:
                    self.stopRecording()
                    
                case .startLivestream:
                    self.performSegue(withIdentifier: addStreamOutputSegueIdentifier, sender: nil)
                
                case .stopLivestream:
                    self.stopLivestream()
                    
                case .switchAudioOutput:
                    AVAudioSession.sharedInstance().changeAudioOutput(presenterViewController: self)
                    
                case .showParticipantList:
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let participantsViewController = storyBoard.instantiateViewController(withIdentifier: "ParticipantsViewController") as! ParticipantsViewController
                    participantsViewController.participants = self.participants
                    self.present(participantsViewController, animated: true, completion: nil)
                    
                case .raiseHand:
                    self.meeting?.pubsub.publish(topic: RAISE_HAND_TOPIC, message: "Raise Hand by Me", options: [:])
                
                default:
                    break
                }
            }
        }
    }
    
    func stopRecording() {
        meeting?.stopRecording()
    }
    
    func stopLivestream() {
        meeting?.stopLivestream()
    }
    
}


// MARK: - Helpers

private extension NewMeetingViewController {
    
    func setupUI() {
        // initially hide screensharing view
//        screenSharingView.isHidden = true
        
        buttonsView.addSubview(buttonControlsView)
        buttonControlsView.frame = buttonsView.bounds
    }
    
    func updateMenuButton() {
        // show enabled when recording or livestream enabled
        buttonControlsView.menuButtonEnabled = (recordingStarted || liveStreamStarted)
    }
    
    func addAudioChangeObserver() {
        // change audio output to louder speaker
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: nil) { notification in
            guard let info = notification.userInfo,
                let value = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
                let reason = AVAudioSession.RouteChangeReason(rawValue: value) else { return }
            switch reason {
            case .categoryChange: try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            default: break
            }
        }
    }
//
//    func addParticipantToGridView() {
//        let index = participants.endIndex-1
//
//        collectionView.performBatchUpdates {
//            self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
//        } completion: { completed in
//            self.updateCollectionViewLayout()
//        }
//    }
//
//    func removeParticipantFromGridView(at index: Int) {
//        collectionView.performBatchUpdates {
//            self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//        } completion: { completed in
//            self.updateCollectionViewLayout()
//        }
//    }

    func showVideoView(_ show: Bool, view: RTCMTLVideoView) {
        UIView.animate(withDuration: 0.5) {
            self.view.isHidden = !show
        } completion: { completed in
            
        }
    }
    
    func setupVideoView() {
        participantVideoView.videoContentMode = .scaleAspectFill
        
        [participantVideoView, participantMainView].forEach {
            $0?.layer.cornerRadius = 5
        }
    }
    
    func setupNameView() {
        localParticipantNameContainerView.layer.cornerRadius = 5
        localParticipantNameBackgroundView.layer.cornerRadius = 5
        participantNameBackgroundView.layer.cornerRadius = 5
        participantNameView.layer.cornerRadius = 5
        lblLocalParticipantName.textColor = UIColor.white
        lblParticipantName.textColor = UIColor.white
        
    }
    
    func setupNameBackgroundView() {
        localParticipantNameBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        participantNameView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        participantNameBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func setupButtons() {
//        micButton.makeRounded()
//        micButton.setImage(UIImage(named: "mic_off"), for: .normal)
//        micButton.backgroundColor = UIColor.systemRed
//        micButton.isUserInteractionEnabled = false
//        updateMicButton()
//
//        menuButton.setImage(UIImage(named: "more"), for: .normal)
//        menuButton.layer.cornerRadius = 5
//        menuButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func updateMicButton() {
//        micButton.alpha = micEnabled ? 0.0 : 1.0
    }
}



