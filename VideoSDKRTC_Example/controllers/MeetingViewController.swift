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
    @IBOutlet weak var localScreenSharedView: UIView!
    
    @IBOutlet weak var StopPresenting: UIButton!
    @IBOutlet weak var ivIsRecording: UIImageView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var btnCopyMeetingId: UIButton!
    @IBOutlet weak var viewCopyMeetingContainer: UIView!
    @IBOutlet weak var btnRotateCamera: UIButton!
    @IBOutlet weak var lblMeetingId: UILabel!
    
    @IBAction func StopPresentingTapped(_ sender: Any) {
        Task {
            await self.meeting?.disableScreenShare()
        }
    }
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
    
    private var isCameraOn = true
        
    private var isMicToggling = false
    
    private var isVideoToggling = false
    /// Notification center for sending and authorize notification
    var userNotificationCenter = UNUserNotificationCenter.current()
    
    
    // MARK: - Life Cycle
    
    override var prefersStatusBarHidden: Bool { true }

    var participantIsSharingScreen: Bool = false
    
    var valueOfVideoDevice: String?
    var valueOfAudioDevice: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.loaderShow(viewControler: self)
        
        prepareUI()
        setupActions()
//        addAudioChangeObserver()
        
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
//        self.requestNotificationAuthorization()
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
        
        [remoteParticipantNameContainer, remoteParticipantVideoContainer, localScreenSharedView].forEach {
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
        
        [participantViewsContainer, remoteParticipantNameContainer, remoteParticipantVideoContainer, remoteParticipantInnerNameView, viewRemoteMicContainer, localScreenSharedView].forEach {
            $0.roundCorners(corners: [.allCorners], radius: 12.0)
        }
        
        [localParticipantViewContainer, localParticipantViewNameContainer, localParticipantViewVideoContainer, remoteParticipantInnerNameView].forEach {
            $0.roundCorners(corners: [.allCorners], radius: 8.0)
        }
        
        ivIsRecording.isHidden = true
        
        localParticipantViewVideoContainer.isHidden = false
        remoteParticipantVideoContainer.isHidden = false
        localScreenSharedView.isHidden = true
    
    }
    
    // MARK: - Meeting
    
    func initializeMeeting() {
        guard let videoDevice = meetingData?.videoDevice else { return }

        let facingMode = getSelectedCameraPosition(for: videoDevice)

        // Create the custom video track using the selected camera
        guard let customVideoStream = try? VideoSDK.createCameraVideoTrack(
            encoderConfig: .h360p_w640p,
            facingMode: facingMode,
            multiStream: true
        ) else {
            print("Failed to create custom video stream")
            return
        }

        // Initialize the meeting with the custom video stream
        meeting = VideoSDK.initMeeting(
            meetingId: meetingData.meetingId,
            participantName: meetingData.name,
            micEnabled: meetingData.micEnabled,
            webcamEnabled: meetingData.cameraEnabled,
            customCameraVideoStream: customVideoStream
        )

        // Add event listeners and join the meeting
        meeting?.addEventListener(self)
        meeting?.join()
    }

    private func getSelectedCameraPosition(for device: String) -> AVCaptureDevice.Position {
        switch device {
        case "Front Camera":
            return .front
        case "Back Camera":
            return .back
        default:
            return .front
        }
    }

    
    
    @IBAction func btnRotateCameraTapped(_ sender: Any) {
        if isCameraOn {
            self.meeting?.switchWebcam()
        } else {
            self.showToast(message: "Camera is off", font: .boldSystemFont(ofSize: 12))
        }
    }
    
    @IBAction func btnCopyMeetingIdTapped(_ sender: Any) {
        guard let meetingId = lblMeetingId.text, !meetingId.isEmpty else { return }
        let meetingLink = "\(meetingId)"
        
        UIPasteboard.general.string = meetingLink
        self.showAlert(title: "MeetingId Copied", message: nil, autoDismiss: true)
    }
    
    func audioSetupForPrecall() {
        if let audio = meetingData?.audioDevice {
            meeting?.changeMic(selectedDevice: audio)
        }
    }
}


// MARK: - MeetingEventListener

extension MeetingViewController: MeetingEventListener {
    
    /// Meeting started
    func onMeetingJoined()  {

        guard let localParticipant = self.meeting?.localParticipant else { return }
        if participants.count < 2 {
            // add to list
            participants.append(localParticipant)

            setNameToView(localParticipant)
            
            // add event listener
            localParticipant.addEventListener(self)
            
            localParticipant.setQuality(.high)

            
            Task{// listen/subscribe for chat topic
                await meeting?.pubsub.subscribe(topic: CHAT_TOPIC, forListener: self)
                await meeting?.pubsub.subscribe(topic: RAISE_HAND_TOPIC, forListener: self)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.audioSetupForPrecall()
            }
            
        } else {
            //Navigate to error screen
        }
        DispatchQueue.main.async {
            Utils.loaderDismiss(viewControler: self)
        }
    }

    /// Meeting ended
    func onMeetingLeft() {
        // remove listeners
        meeting?.localParticipant.removeEventListener(self)
        meeting?.removeEventListener(self)
        participants.removeAll()
        
        // dismiss controller
        Utils.loaderDismiss(viewControler: self)
        
        // Navigate back to previous view
        DispatchQueue.main.async {
            // If presented modally
            if self.presentingViewController != nil {
                self.dismiss(animated: true)
            }
        }
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
        self.recordingStarted = true
        self.ivIsRecording.isHidden = false
        updateMenuButton()
        showAlert(title: "Recording Started", message: nil, autoDismiss: true)
    }
    
    /// Caled after recording stops
    func onRecordingStoppped() {
        self.ivIsRecording.isHidden = true
        recordingStarted = false
        updateMenuButton()
    }
    
//    /// Called after livestream starts
//    func onLivestreamStarted() {
//        liveStreamStarted = true
//        updateMenuButton()
//        showAlert(title: "Livestream Started", message: nil, autoDismiss: true)
//    }
//    
//    /// Called after livestream stops
//    func onLivestreamStopped() {
//        print("livestream stopped")
//        liveStreamStarted = false
//        updateMenuButton()
//    }
//    
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
        
//        if stream.kind == .share && participant.isLocal {
//            
//            showLocalScreenShareView(stream: stream)
//            return
//        }
//        else if stream.kind == .share && !participant.isLocal {
//            showRemoteScreenShare(stream: stream)
//            return
//        }
        
        Utils.loaderDismiss(viewControler: self)
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
        
//        if stream.kind == .share && participant.isLocal {
//            removeLocalScreenShareView(stream: stream)
//            return
//        }
//        else if stream.kind == .share && !participant.isLocal {
//            removeRemoteScreenShare(stream: stream)
//            return
//        }
        
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
                   guard !self.isMicToggling else { return }
                   self.isMicToggling = true

                       Task {
                           if !on {
                                self.meeting?.unmuteMic()
                           } else {
                                self.meeting?.muteMic()
                           }
                       }

                       // Reset flag after delay
                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                           self.isMicToggling = false
                       }
               }
        
        // onVideoTapped
        buttonControlsView.onVideoTapped = { on in
            guard !self.isVideoToggling else { return }
            self.isVideoToggling = true

                Task {
                    if !on {
                        guard let customVideoStream = try? VideoSDK.createCameraVideoTrack(encoderConfig: .h720p_w1280p, facingMode: .front, multiStream: true) else { return }
                         self.meeting?.enableWebcam(customVideoStream: customVideoStream)
                        self.isCameraOn = true
                    } else {
                         self.meeting?.disableWebcam()
                        self.isCameraOn = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isVideoToggling = false
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
//            menuOptions.append(!self.liveStreamStarted ? .startLivestream : .stopLivestream)
            menuOptions.append(.startScreenShare)
            menuOptions.append(.stopScreenShare)
            
            self.showActionsheet(options: menuOptions, fromView: self.buttonControlsView.btnMoreOptions) { option in
                switch option {
                    
                case .startRecording:
                        self.meeting?.startRecording(webhookUrl: "")
            
                case .stopRecording:
                    self.meeting?.stopRecording()

//                case .startLivestream:
//                    self.performSegue(withIdentifier: addStreamOutputSegueIdentifier, sender: nil)
//                    
//                case .stopLivestream:
//                    self.stopLivestream()
                    
                case .switchAudioOutput:
//                    AVAudioSession.sharedInstance().changeAudioOutput(presenterViewController: self)
                    self.changeAudioOutput(presenterViewController: self)
                    
                case .showParticipantList:
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let participantsViewController = storyBoard.instantiateViewController(withIdentifier: "ParticipantsViewController") as! ParticipantsViewController
                    participantsViewController.participants = self.participants
                    self.present(participantsViewController, animated: true, completion: nil)
                    
                case .raiseHand:
                    self.meeting?.pubsub.publish(topic: RAISE_HAND_TOPIC, message: "Raise Hand by Me", options: [:])
                    
                case .startScreenShare:
                    Task {
                        await self.meeting?.enableScreenShare()
                    }
                case .stopScreenShare:
                    Task {
                        await self.meeting?.disableScreenShare()
                    }
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
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5){
                        if enabled {
                            if participant.isLocal {
                                self.localScreenSharedView.isHidden = false
                            }
                            if let videoStream = self.participants.first(where: {$0.id == participant.id})?.streams.first(where: { $1.kind == .state(value: .video) })?.value.track as? RTCVideoTrack {
                                videoStream.remove(self.remoteParticipantVideoContainer)
                                
                                shareTrack.add(self.remoteParticipantVideoContainer)
                                if participant.isLocal {
                                    self.remoteParticipantVideoContainer.isHidden = true
                                } else {
                                    self.remoteParticipantVideoContainer.isHidden = false
                                }
                                self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFit
                                self.remoteParticipantNameContainer.isHidden = true
                                if let localVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: { $1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                                    localVideoStream.remove(self.localParticipantViewVideoContainer)
                                    //                                    videoStream.add(self.localParticipantViewVideoContainer)
                                    self.localParticipantViewVideoContainer.isHidden = true
                                    self.localParticipantViewNameContainer.isHidden = true
                                    self.localParticipantViewContainer.isHidden = true
                                }
                            } else {
                                shareTrack.add(self.remoteParticipantVideoContainer)
                                self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFit
                                if participant.isLocal {
                                    self.remoteParticipantVideoContainer.isHidden = true
                                    self.remoteParticipantNameContainer.isHidden = true
                                } else {
                                    self.remoteParticipantVideoContainer.isHidden = false
                                    self.remoteParticipantNameContainer.isHidden = false
                                }
                                //                                self.remoteParticipantVideoContainer.isHidden = false
                                if let localVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: { $1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                                    localVideoStream.remove(self.localParticipantViewVideoContainer)
                                }
                                self.localParticipantViewVideoContainer.isHidden = true
                                self.localParticipantViewNameContainer.isHidden = true
                                self.localParticipantViewContainer.isHidden = true
                            }
                        } else {
                            if participant.isLocal {
                                self.localScreenSharedView.isHidden = true
                            }
                            if self.participants.count > 1 {
                                shareTrack.remove(self.remoteParticipantVideoContainer)
                                if let videoStream = self.participants.first(where: {!$0.isLocal})?.streams.first(where: { $1.kind == .state(value: .video) })?.value.track as? RTCVideoTrack {
                                    //                                videoStream.remove(self.localParticipantViewVideoContainer)
                                    videoStream.add(self.remoteParticipantVideoContainer)
                                    self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFill
                                    self.remoteParticipantVideoContainer.isHidden = false
                                    self.remoteParticipantNameContainer.isHidden = true
                                } else {
                                    self.remoteParticipantVideoContainer.isHidden = true
                                    self.remoteParticipantNameContainer.isHidden = false
                                }
                                if let localVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: { $1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                                    localVideoStream.add(self.localParticipantViewVideoContainer)
                                    self.localParticipantViewContainer.isHidden = false
                                    self.localParticipantViewVideoContainer.isHidden = false
                                    self.localParticipantViewNameContainer.isHidden = true
                                }
                            } else {
                                if let localVideoStream = self.participants.first(where: { $0.isLocal })?.streams.first(where: { $1.kind == .state(value: .video)})?.value.track as? RTCVideoTrack {
                                    localVideoStream.add(self.remoteParticipantVideoContainer)
                                    self.remoteParticipantVideoContainer.isHidden = false
                                    self.remoteParticipantNameContainer.isHidden = true
                                    self.localParticipantViewVideoContainer.isHidden = true
                                    self.localParticipantViewNameContainer.isHidden = false
                                }
                            }
                            
                            //
                        }
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
                    self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFit
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
                        self.localParticipantViewVideoContainer.videoContentMode = .scaleAspectFit
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
                self.remoteParticipantVideoContainer.videoContentMode = .scaleAspectFit
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
    
    func changeAudioOutput(presenterViewController: UIViewController) {

        let CHECKED_KEY = "checked"
        let Mics = self.meeting?.getMics() ?? []
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for mic in Mics {
            
            let action = UIAlertAction(title: mic.deviceName, style: .default) {  UIAlertAction in
                self.meeting?.changeMic(selectedDevice: mic.deviceName)

                optionMenu.dismiss(animated: true, completion: nil)
            }
            
            if  AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: {$0.portType.rawValue == mic.deviceType}) {
                action.setValue(true, forKey: CHECKED_KEY)
            }
                
            if action.title?.count ?? 0 > 0 {
                optionMenu.addAction(action)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        presenterViewController.present(optionMenu, animated: true, completion: nil)
    }

    
}

