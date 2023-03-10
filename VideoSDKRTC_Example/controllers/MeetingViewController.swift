//
//  ViewController.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 11/01/23.
//

import UIKit
import VideoSDKRTC
import WebRTC
import AVFoundation

private let reuseIdentifier = "ParticipantViewCell"
private let addStreamOutputSegueIdentifier = "Add Livestream Outputs"
private let recordingWebhookUrl = "https://www.google.com"
private let CHAT_TOPIC = "CHAT"
private let RAISE_HAND_TOPIC = "RAISE_HAND"

class MeetingViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    
    @IBOutlet weak var viewRemoteMicContainer: UIView!
    @IBOutlet weak var imgRemoteMicEnabled: UIImageView!
    @IBOutlet weak var participantViewsContainer: UIView!
    @IBOutlet weak var remoteParticipantNameContainer: UIView!
    @IBOutlet weak var remoteParticipantVideoContainer: RTCMTLVideoView!
    @IBOutlet weak var remoteParticipantInnerNameView: UIView!
    @IBOutlet weak var lblRemoteParticipantName: UILabel!
    @IBOutlet weak var localParticipantViewContainer: UIView!
    @IBOutlet weak var localParticipantViewNameContainer: UIView!
    @IBOutlet weak var localParticipantViewVideoContainer: RTCMTLVideoView!
    
    @IBOutlet weak var ivIsRecording: UIImageView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var btnCopyMeetingId: UIButton!
    @IBOutlet weak var viewCopyMeetingContainer: UIView!
    @IBOutlet weak var btnRotateCamera: UIButton!
    @IBOutlet weak var lblMeetingId: UILabel!
    
    // MARK: - Properties
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
    
    /// Notification center for sending and authorize notification
    var userNotificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Life Cycle
    
    override var prefersStatusBarHidden: Bool { true }

    var participantIsSharingScreen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.loaderShow(viewControler: self)
        
        prepareUI()
        setupActions()
        addAudioChangeObserver()
        
        // config
        VideoSDK.config(token: meetingData.token)
        
        // init meeting
        initializeMeeting()
        
        // set meeting id in button text
        lblMeetingId.text = "\(meetingData.meetingId)"
        
        // setting up notification for viewcontroller to check, it going to background or not
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        // Assigning self delegate on userNotificationCenter
        self.userNotificationCenter.delegate = self
        
        // requesting authorization to send the local notification
        self.requestNotificationAuthorization()
    }
    
    // method called once app state changes to background
    @objc func appMovedToBackground() {
        self.sendNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let navigationController = segue.destination as? UINavigationController,
              let addStreamsController = navigationController.viewControllers.first as? AddStreamOutputiewController
        else { return }
        
        addStreamsController.onStart =  { streamOutputs in
            if !streamOutputs.isEmpty {
                self.meeting?.startLivestream(outputs: streamOutputs)
            } else {
                self.showAlert(title: "Error", message: "Add stream outputs to start livestream.")
            }
        }
    }
    
    func prepareUI() {
        buttonsView.addSubview(buttonControlsView)
        buttonControlsView.frame = buttonsView.bounds
        
        [remoteParticipantNameContainer, remoteParticipantVideoContainer].forEach {
            $0?.frame = CGRect(x: 0, y: 0, width: participantViewsContainer.frame.width, height: participantViewsContainer.frame.height)
            $0?.bounds = CGRect(x: 0, y: 0, width: participantViewsContainer.frame.width, height: participantViewsContainer.frame.height)
            $0?.clipsToBounds = true
        }
        
        [localParticipantViewVideoContainer, localParticipantViewNameContainer].forEach {
            $0?.frame = CGRect(x: 10, y: 0, width: localParticipantViewContainer.frame.width, height: localParticipantViewContainer.frame.height)
            $0?.bounds = CGRect(x: 10, y: 0, width: localParticipantViewContainer.frame.width, height: localParticipantViewContainer.frame.height)
            $0?.clipsToBounds = true
        }
        
        [localParticipantViewVideoContainer, remoteParticipantVideoContainer].forEach {
            $0?.videoContentMode = .scaleAspectFill
        }
        
        [participantViewsContainer, remoteParticipantNameContainer, remoteParticipantVideoContainer, remoteParticipantInnerNameView, viewRemoteMicContainer].forEach {
            $0.roundCorners(corners: [.allCorners], radius: 12.0)
        }
        
        [localParticipantViewContainer, localParticipantViewNameContainer, localParticipantViewVideoContainer, remoteParticipantInnerNameView].forEach {
            $0.roundCorners(corners: [.allCorners], radius: 8.0)
        }
        
        ivIsRecording.isHidden = true
        
        localParticipantViewVideoContainer.isHidden = false
        remoteParticipantVideoContainer.isHidden = false
    
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
    
    
    @IBAction func btnRotateCameraTapped(_ sender: Any) {
        self.meeting?.switchWebcam()
    }
    
    @IBAction func btnCopyMeetingIdTapped(_ sender: Any) {
        guard let meetingId = lblMeetingId.text, !meetingId.isEmpty else { return }
        let meetingLink = "\(meetingId)"
        
        UIPasteboard.general.string = meetingLink
        self.showAlert(title: "MeetingId Copied", message: nil, autoDismiss: true)
    }
}


// MARK: - MeetingEventListener

extension MeetingViewController: MeetingEventListener {
    
    /// Meeting started
    func onMeetingJoined() {
        
        // handle local participant on start
        guard let localParticipant = self.meeting?.localParticipant else { return }
        
        if participants.count < 2 {
            // add to list
            participants.append(localParticipant)
            
            setNameToView(localParticipant)
            
            // add event listener
            localParticipant.addEventListener(self)
            
            localParticipant.setQuality(.high)
            
            // listen/subscribe for chat topic
            meeting?.pubsub.subscribe(topic: CHAT_TOPIC, forListener: self)
            
            // listen/subscribe for raise-hand topic
            meeting?.pubsub.subscribe(topic: RAISE_HAND_TOPIC, forListener: self)
        } else {
            //Navigate to error screen
        }
        
        Utils.loaderDismiss(viewControler: self)
    }
    
    /// Meeting ended
    func onMeetingLeft() {
        
        // remove listeners
        meeting?.localParticipant.removeEventListener(self)
        meeting?.removeEventListener(self)
        
        // dismiss controller
        Utils.loaderDismiss(viewControler: self)
    }
    
    /// A new participant joined
    func onParticipantJoined(_ participant: Participant) {

        if participants.count < 2 {
            
            // add new participant to list
            participants.append(participant)
            
            // add listener
            participant.addEventListener(self)
            
            participant.setQuality(.high)
            
            self.setNameToView(participant)
        } else {
            //Navigate to Error Screen
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
        removeParticipantFromGridView(participant)
        
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
        if let participant = participants.first(where: { $0.id == participantId }), participants.count > 1 {
            showActiveSpeakerIndicator(participant.isLocal ? localParticipantViewContainer : participantViewsContainer, true)
        } else if let participant = participants.first(where: { $0.id == participantId }), participant.isLocal{
            showActiveSpeakerIndicator(participantViewsContainer, true)
        }

        // hide indication for others participants
        let otherParticipants = participants.filter { $0.id != participantId }
        for participant in otherParticipants {
            if participants.count > 1 && participant.isLocal {
                showActiveSpeakerIndicator(localParticipantViewContainer, false)
            } else {
                showActiveSpeakerIndicator(participantViewsContainer, false)
            }
        }
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
    
    func showActiveSpeakerIndicator(_ view: UIView, _ show: Bool) {
        // border
        view.layer.borderWidth = 4.0
        view.layer.borderColor = show ? UIColor.blue.cgColor : UIColor.clear.cgColor
    }
}

// MARK: - ParticipantEventListener

extension MeetingViewController: ParticipantEventListener {
    
    /// Participant has enabled mic, video or screenshare
    /// - Parameters:
    ///   - stream: enabled stream object
    ///   - participant: participant object
    func onStreamEnabled(_ stream: MediaStream, forParticipant participant: Participant) {
        updateView(participant: participant, forStream: stream, enabled: true)
        
        if participant.isLocal {
            // turn on controls for local participant
            self.buttonControlsView.updateButtons(forStream: stream, enabled: true)
        }
        
        //notification to participants via sharing participants
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "shareParticipants"), object: nil, userInfo: ["participants": self.participants])
    }
    
    /// Participant has disabled mic, video or screenshare
    /// - Parameters:
    ///   - stream: disabled stream object
    ///   - participant: participant object
    func onStreamDisabled(_ stream: MediaStream, forParticipant participant: Participant) {
        updateView(participant: participant, forStream: stream, enabled: false)
        
        if participant.isLocal {
            // turn off controls for local participant
            self.buttonControlsView.updateButtons(forStream: stream, enabled: false)
        }
        
        //notification to participants via sharing participants
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "shareParticipants"), object: nil, userInfo: ["participants": self.participants])
    }
}

// MARK: - PubSubMessageListener

extension MeetingViewController: PubSubMessageListener {
    
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

private extension MeetingViewController {
    
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
            menuOptions.append(.switchAudioOutput)
            menuOptions.append(!self.recordingStarted ? .startRecording : .stopRecording)
            menuOptions.append(!self.liveStreamStarted ? .startLivestream : .stopLivestream)
            
            self.showActionsheet(options: menuOptions, fromView: self.buttonControlsView.btnMoreOptions) { option in
                switch option {
                    
                case .startRecording:
                    Utils.loaderShow(viewControler: self)
                    DispatchQueue.main.async {
                        self.meeting?.startRecording(webhookUrl: "")
                        Utils.loaderDismiss(viewControler: self)
                        self.ivIsRecording.isHidden = false
                    }
                    
                case .stopRecording:
                    self.stopRecording()
                    self.ivIsRecording.isHidden = true
                    
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

// MARK: - Chat

extension MeetingViewController {
    
    func openChat() {
        let chatViewController = ChatViewController(meeting: meeting!, topic: CHAT_TOPIC)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

// MARK: - Helpers

private extension MeetingViewController {
    
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
    
    func updateMenuButton() {
        // show enabled when recording or livestream enabled
        buttonControlsView.menuButtonEnabled = (recordingStarted || liveStreamStarted)
    }
    
    /// Set the name of the participant to name view
    func setNameToView(_ participant: Participant){
        let nameComponents = participant.displayName.components(separatedBy: " ")
        self.lblRemoteParticipantName.text = nameComponents
            .reduce("") {
                ($0.isEmpty ? "" : "\($0.first?.uppercased() ?? "")") +
                ($1.isEmpty ? "" : "\($1.first?.uppercased() ?? "")")
            }
        self.remoteParticipantInnerNameView.roundCorners(corners: .allCorners, radius: 20.0)
    }
    
    func updateView(participant: Participant, forStream stream: MediaStream, enabled: Bool) { // true
        switch stream.kind {
        case .state(value: .video):
            if let videotrack = stream.track as? RTCVideoTrack {
                if enabled {
                    showVideoView(participant: participant, stream: videotrack) // show video
                } else {
                    hideVideoView(participant: participant, stream: videotrack) // hide video
                }
            }
            
        case .state(value: .audio):
            updateMic(participant: participant, enabled)
            
        case .share:
            if let shareTrack = stream.track as? RTCVideoTrack {
                if enabled {
                    if let videoStream = self.participants.first(where: {$0.id == participant.id})?.streams.first(where: { $1.kind == .state(value: .video) })?.value.track as? RTCVideoTrack {
                        videoStream.remove(self.remoteParticipantVideoContainer)
                        shareTrack.add(self.remoteParticipantVideoContainer)
                        self.remoteParticipantVideoContainer.isHidden = false
                        self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFit
                        self.remoteParticipantNameContainer.isHidden = false
                        if let localVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: { $1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                            localVideoStream.remove(self.localParticipantViewVideoContainer)
                            videoStream.add(self.localParticipantViewVideoContainer)
                            self.localParticipantViewVideoContainer.isHidden = false
                            self.localParticipantViewNameContainer.isHidden = true
                            self.localParticipantViewContainer.isHidden = false
                        }
                    } else {
                        shareTrack.add(self.remoteParticipantVideoContainer)
                        self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFit
                        self.remoteParticipantVideoContainer.isHidden = false
                        self.remoteParticipantNameContainer.isHidden = false
                        if let localVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: { $1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                            localVideoStream.remove(self.localParticipantViewVideoContainer)
                        }
                        self.localParticipantViewVideoContainer.isHidden = true
                        self.localParticipantViewNameContainer.isHidden = false
                        self.localParticipantViewContainer.isHidden = false
                    }
                } else {
                    shareTrack.remove(self.remoteParticipantVideoContainer)
                    if let videoStream = self.participants.first(where: {$0.id == participant.id})?.streams.first(where: { $1.kind == .state(value: .video) })?.value.track as? RTCVideoTrack {
                        videoStream.remove(self.localParticipantViewVideoContainer)
                        videoStream.add(self.remoteParticipantVideoContainer)
                        self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFill
                        self.remoteParticipantVideoContainer.isHidden = false
                        self.remoteParticipantNameContainer.isHidden = false
                    } else {
                        self.remoteParticipantVideoContainer.isHidden = false
                        self.remoteParticipantNameContainer.isHidden = false
                    }
                    if let localVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: { $1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                        localVideoStream.add(self.localParticipantViewVideoContainer)
                        self.localParticipantViewVideoContainer.isHidden = false
                        self.localParticipantViewNameContainer.isHidden = true
                    }
                }
            }
            
        default:
            break
        }
    }
    
    func showVideoView(participant: Participant, stream: RTCVideoTrack){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5){
                if self.participants.count > 1 {
                    if let currentVideoTrack = self.participants.first(where: { $0.isLocal })?.streams.first(where: {$1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                        currentVideoTrack.remove(self.remoteParticipantVideoContainer)
                        currentVideoTrack.remove(self.localParticipantViewVideoContainer)
                    }
                    let hasShareStream = self.participants.first(where: { !$0.isLocal })?.streams.contains(where: {$1.kind == .share})
                    if hasShareStream ?? false {
                        if let currentVideoTrack = self.participants.first(where: { !$0.isLocal })?.streams.first(where: {$1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                            currentVideoTrack.add(self.localParticipantViewVideoContainer)
                            self.localParticipantViewVideoContainer.isHidden = false
                            self.localParticipantViewNameContainer.isHidden = true
                        }
                    } else {
                        stream.add(participant.isLocal ? self.localParticipantViewVideoContainer : self.remoteParticipantVideoContainer)
                        if participant.isLocal {
                            self.localParticipantViewVideoContainer.isHidden = false
                            self.localParticipantViewNameContainer.isHidden = true
                            self.localParticipantViewContainer.isHidden = false
                        } else {
                            self.remoteParticipantVideoContainer.isHidden = false
                            self.remoteParticipantNameContainer.isHidden = true
                        }
                        if let localParticipantVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: {$1.kind == .state(value: .video )})?.value.track as? RTCVideoTrack {
                            localParticipantVideoStream.add(self.localParticipantViewVideoContainer)
                            self.localParticipantViewVideoContainer.isHidden = false
                            self.localParticipantViewNameContainer.isHidden = true
                            self.localParticipantViewContainer.isHidden = false
                        }
                        
                    }
                } else {
                    stream.add(self.remoteParticipantVideoContainer)
                    self.remoteParticipantVideoContainer.isHidden = false
                    self.remoteParticipantNameContainer.isHidden = true
                }
            }
        }
        
    }
    
    func hideVideoView(participant: Participant, stream: RTCVideoTrack){
        UIView.animate(withDuration: 0.5){
            if self.participants.count > 1 {
                let hasShareStream = self.participants.first(where: { !$0.isLocal })?.streams.contains(where: {$1.kind == .share})
                if hasShareStream ?? false {
                    if !participant.isLocal {
                        if let currentVideoTrack = self.participants.first(where: { !$0.isLocal })?.streams.first(where: {$1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                            currentVideoTrack.remove(self.localParticipantViewVideoContainer)
                            self.localParticipantViewVideoContainer.isHidden = true
                            self.localParticipantViewNameContainer.isHidden = false
                        } else {
                            self.localParticipantViewVideoContainer.isHidden = true
                            self.localParticipantViewNameContainer.isHidden = false
                        }
                    }
                } else {
                    stream.remove(participant.isLocal ? self.localParticipantViewVideoContainer : self.remoteParticipantVideoContainer)
                    if participant.isLocal {
                        self.localParticipantViewVideoContainer.videoContentMode = .scaleAspectFill
                        self.localParticipantViewVideoContainer.isHidden = true
                        self.localParticipantViewNameContainer.isHidden = false
                    } else {
                        self.remoteParticipantVideoContainer.isHidden = true
                        self.remoteParticipantNameContainer.isHidden = false
                    }
                }
            } else {
                stream.remove(self.remoteParticipantVideoContainer)
                self.remoteParticipantVideoContainer.isHidden = true
                self.remoteParticipantNameContainer.isHidden = false
            }
        }
    }
    
    func updateMic(participant: Participant, _ enabled: Bool) {
        if !participant.isLocal {
            participantViewsContainer.bringSubviewToFront(viewRemoteMicContainer)
            viewRemoteMicContainer.isHidden = enabled
        } else if participants.count == 1 {
            participantViewsContainer.bringSubviewToFront(viewRemoteMicContainer)
            viewRemoteMicContainer.isHidden = enabled
        }
    }
    
    func removeParticipantFromGridView(_ participant: Participant) {
        UIView.animate(withDuration: 0.5){
            if !participant.isLocal {
                self.localParticipantViewVideoContainer.isHidden = true
                self.localParticipantViewNameContainer.isHidden = true
                self.localParticipantViewContainer.isHidden = true
                self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFill
                // other remote participant
                if let remoteParticipant = self.participants.first(where: { $0.id != participant.id }) {
                    // find videostream of remote participant
                    if let videoStream = remoteParticipant.streams.first(where: { $1.kind == .state(value: .video) })?.value.track as? RTCVideoTrack  {
                        // added remote video stream to remote participant video container
                        videoStream.add(self.remoteParticipantVideoContainer)
                        // hide remote name container
                        self.remoteParticipantNameContainer.isHidden = true
                        // set remained participant name
                        self.setNameToView(remoteParticipant)
                        // show remote video container
                        self.remoteParticipantVideoContainer.isHidden = false
                        // show remote participant main container
                        self.participantViewsContainer.isHidden = false
                    } else {
                        // show remote name container
                        self.remoteParticipantNameContainer.isHidden = false
                        // set remained participant name
                        self.setNameToView(remoteParticipant)
                        // hide remote video container
                        self.remoteParticipantVideoContainer.isHidden = true
                        // show remote participant main container
                        self.participantViewsContainer.isHidden = false
                    }
                }
            }
        }
    }
    
}

// MARK: - Notification Center Methods

extension MeetingViewController {
    
    func requestNotificationAuthorization() {
        self.userNotificationCenter.requestAuthorization(options: UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)) { (success, error) in
            if let error = error {
                print("requestAuthorization error: ", error)
            }
        }
    }
    
    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Your application is in background"
        notificationContent.body = "This may cause you to leave the meeting automatically"
        notificationContent.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "backgroundNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        self.userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
}

