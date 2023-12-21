//
//  MeetingViewController.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import VideoSDKRTC
import AVFoundation

enum MenuOption: String {
    case switchCamera = "Switch Camera"
    case startRecording = "Start Recording"
    case stopRecording = "Stop Recording"
    case startLivestream = "Start Livestream"
    case stopLivestream = "Stop Livestream"
    case toggleMic = "Toggle Mic"
    case toggleWebcam = "Toggle Webcam"
    case remove = "Remove"
    case leaveMeeting = "Leave"
    case endMeeting = "End Meeting"
    case switchAudioOutput = "Switch Audio Output"
    case toggleQuality = "Change Video Quality"
    case high = "High"
    case low = "Low"
    case medium = "Medium"
    case showParticipantList = "Show Participants List"
    case raiseHand = "Raise Hand"
    case startHLS = "Start HLS"
    case stopHLS = "Stop HLS"
    case changeMode = "Change Mode"
    case pin = "Pin"
    case unpin = "Unpin"
    case stats = "Get Stats"
    
    var style: UIAlertAction.Style {
        switch self {
        case .stopRecording, .stopLivestream, .remove, .endMeeting:
            return .destructive
        default:
            return .default
        }
    }
}

private let reuseIdentifier = "ParticipantViewCell"
private let addStreamOutputSegueIdentifier = "Add Livestream Outputs"
private let recordingWebhookUrl = "https://www.google.com"
private let CHAT_TOPIC = "CHAT"
private let RAISE_HAND_TOPIC = "RAISE_HAND"

var isConference: Bool = true

class MeetingViewController: UIViewController, UICollectionViewDataSource, UIScrollViewDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - View
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var screenSharingView: ScreenSharingView!
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var meetingIDButton: UIButton!
    /// View for handling meeting controls consists of Mic, Video, and End buttons
    lazy var buttonControlsView: ButtonControlsView! = {
        Bundle.main.loadNibNamed("ButtonControlsView", owner: self, options: nil)?[0] as! ButtonControlsView
    }()
    
    
    // MARK: - Properties
    
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
    
    /// keep track of HLS
    private var hlsStreamStarted = false
    
    /// Camera position
    private var cameraPosition = CameraPosition.front
    
    /// Notification center for sending and authorize notification
    var userNotificationCenter = UNUserNotificationCenter.current()
    
    
    // MARK: - Life Cycle
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils.loaderShow(viewControler: self)
        
        // setup
        setupUI()
        setupActions()
        addAudioChangeObserver()
        
        // config
        VideoSDK.config(token: meetingData.token)
        
        // init meeting
        initializeMeeting()
        
        // set meeting id in button text
        meetingIDButton.setTitle("Meeting Id : \(meetingData.meetingId)", for: .normal)
        
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
    
    
    // MARK: - Meeting
    
    private func initializeMeeting() {
        
        // MARK :- With CustomVideoTrack with multiStream `true`
        guard let customVideoStream = try? VideoSDK.createCameraVideoTrack(encoderConfig: .h1080p_w1440p, facingMode: .front, multiStream: true) else { return }
        
        // initialize
        meeting = VideoSDK.initMeeting(
            meetingId: meetingData.meetingId,
            participantName: meetingData.name,
            micEnabled: meetingData.micEnabled,
            webcamEnabled: meetingData.cameraEnabled,
            customCameraVideoStream: customVideoStream,
            mode: .CONFERENCE
        )
        
        // MARK :- Without CustomVideoTrack
        /*meeting = VideoSDK.initMeeting(
            meetingId: meetingData.meetingId,
            participantName: meetingData.name,
            micEnabled: meetingData.micEnabled,
            webcamEnabled: meetingData.cameraEnabled
        )*/
        
        // listener
        meeting?.addEventListener(self)
        
        // join
        meeting?.join(cameraPosition: .front)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParticipantViewCell
        
        // get participant
        let participant = participants[indexPath.row]
        
        // save indexPath
        indexPaths[participant.id] = indexPath
        
        // set isPinned or not
        let isPinned = self.meeting?.pinnedParticipants.contains(where: { $0.key == participant.id }) ?? false
        
        // set
        cell.setParticipant(participant, isPinned: isPinned)
        
        // on menu tap
        cell.onMenuTapped = { peer in
            self.showParticipantControlOptions(peer)
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPaths = collectionView.indexPathsForVisibleItems
        let visibleParticipants: [Participant] = indexPaths.map { participants[$0.row] }
        let nonVisibleParticipants: [Participant] = participants.filter { !visibleParticipants.contains($0) }
        
        // resume streams for visible participants
        visibleParticipants.forEach { participant in
            if let videoStream = participant.streams.first(where: { $1.kind == .state(value: .video) })?.value {
                videoStream.resume()
            }
        }
        // pause streams for non visible participants
        nonVisibleParticipants.forEach { participant in
            if let videoStream = participant.streams.first(where: { $1.kind == .state(value: .video) })?.value {
                videoStream.pause()
            }
        }
        
        for data in self.collectionView.visibleCells {
            if let indexPath = self.collectionView.indexPath(for: data as UICollectionViewCell) {
                let cell = collectionView.cellForItem(at: indexPath) as? ParticipantViewCell
                if let participant = self.participants[indexPath.row].streams.values.first {
                    cell?.updateView(forStream: participant, enabled: true)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onClickCopyMeetingID(_ sender: UIButton) {
        UIPasteboard.general.string = meetingData.meetingId
        self.showToast(message: "Meeting id copied", font: .systemFont(ofSize: 18))
    }
    
    // Mark: - Delegate Methods for Local notificatiom
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
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

// MARK: - MeetingEventListener

extension MeetingViewController: MeetingEventListener {
    
    /// Meeting started
    func onMeetingJoined() {
        
        // handle local participant on start
        guard let localParticipant = self.meeting?.localParticipant else { return }
        
        if localParticipant.mode == .CONFERENCE {
            localParticipant.pin()
        }
        
        // add to list
        participants.append(localParticipant)
        
        // add event listener
        localParticipant.addEventListener(self)
        
        // show in ui
        addParticipantToGridView()
        
        // listen/subscribe for chat topic
        meeting?.pubsub.subscribe(topic: CHAT_TOPIC, forListener: self)
        
        // listen/subscribe for raise-hand topic
        meeting?.pubsub.subscribe(topic: RAISE_HAND_TOPIC, forListener: self)
        
        Utils.loaderDismiss(viewControler: self)
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
        
        // show in ui
        addParticipantToGridView()
        
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
        removeParticipantFromGridView(at: index)
        
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
        if let participant = participants.first(where: { $0.id == participantId }),
           let cell = cellForParticipant(participant) {
            
            cell.showActiveSpeakerIndicator(true)
        }
        
        // hide indication for others participants
        let otherParticipants = participants.filter { $0.id != participantId }
        for participant in otherParticipants {
            if let cell = cellForParticipant(participant) {
                cell.showActiveSpeakerIndicator(false)
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
    
    func onMeetingStateChanged(meetingState: MeetingState) {
        switch meetingState {
            case .CONNECTING:
                print("Meeting is connecting")
                
            case .CONNECTED:
                print("Meeting connected")
                
            case .CLOSING:
                print("Meeting is closing")
                
            case .CLOSED:
                print("Meeting is closed")
                
            case .CANCELLED:
                print("Meeting is cancelled")
        }
    }
    
    func onError(error: VideoSDKError) {
        switch error {
            case .INVALID_TOKEN: print("Invalid Token")

            case .INVALID_MEETING_ID: print("Invalid Meeting Id")
            
            case .INVALID_API_KEY: print("Invalid API Key")
            
            case .INVALID_PERMISSIONS: print("Invalid Permissions")
            
            case .INVALID_PARTICIPANT_ID: print("Invalid Participant ID")
            
            case .INVALID_LIVESTREAM_CONFIG: print("Invalid LiveStream Config")
            
            case .ACCOUNT_DEACTIVATED: print("Account Deactivated")
            
            case .ACCOUNT_DISCONTINUED: print("Account Discontinued")
            
            case .DUPLICATE_PARTICIPANT: print("Duplicate Participant")
            
            case .HLS_FAILED: print("HLS failed")
            
            case .START_HLS_FAILED: print("Start HLS failed")
            
            case .STOP_HLS_FAILED: print("Stop HLS failed")
            
            case .START_RECORDING_FAILED: print("Start recording failed")
            
            case .START_LIVESTREAM_FAILED: print("Start liveStream failed")
            
            case .STOP_RECORDING_FAILED: print("Stop recording failed")
            
            case .STOP_LIVESTREAM_FAILED: print("Stop liveStream failed")
            
            case .RECORDING_FAILED: print("Recording failed")
            
            case .MAX_SPEAKER_REACHED: print("Max speaker reached")
             
            case .MAX_PARTCIPANT_REACHED: print("Maximum participant limit reached")
             
            case .LIVESTREAM_FAILED: print("Error while getting display media")
             
            case .ERROR_GET_VIDEO_MEDIA: print("Error while getting video media")
            
            case .ERROR_GET_AUDIO_MEDIA: print("Error while getting audio media")
            
            case .ERROR_GET_DISPLAY_MEDIA: print("Error while getting display media")
            
            case .ERROR_GET_VIDEO_MEDIA_PERMISSION_DENIED: print("Permission denied while getting video camera permission")
            
            case .ERROR_GET_AUDIO_MEDIA_PERMISSION_DENIED: print("Permission denied while getting audio speaker permission")
            
            case .ERROR_GET_DISPLAY_MEDIA_PERMISSION_DENIED: print("Permission denied while getting display media permission")
            
            case .UNKNOWN_ERROR: print("Unknown Error")
        }
    }
    
    func onHlsStateChanged(state: HLSState, hlsUrl: HLSUrl?) {
        switch(state) {
            case .HLS_STARTING:
                print("HLS Starting")
                
            case .HLS_STARTED:
                self.hlsStreamStarted = true
                print("HLS Started")
                
            case .HLS_PLAYABLE:
                print("HLS Playable")
                
            case .HLS_STOPPING:
                print("HLS Stopping")
                
            case .HLS_STOPPED:
                self.hlsStreamStarted = false
                print("HLS Stopped")
            }
    }
    
    func onRecordingStateChanged(state: RecordingState) {
        switch(state) {
            case .RECORDING_STARTING:
                print("recording starting")
            
            case .RECORDING_STARTED:
                print("recording started")
                
            case .RECORDING_STOPPING:
                print("recording stopping")
        
            case .RECORDING_STOPPED:
                print("recording stopped")
        }
    }
    
    func onLivestreamStateChanged(state: LiveStreamState) {
        switch(state) {
            case .LIVESTREAM_STARTING:
                print("livestream starting")
            
            case .LIVESTREAM_STARTED:
                print("livestream started")
                
            case .LIVESTREAM_STOPPING:
                print("livestream stoping")
        
            case .LIVESTREAM_STOPPED:
                print("livestream stopped")
        }
    }

    func onPinStateChanged(participantId: String, pinType: PinType) {
        if let participant = participants.first(where: { $0.id == participantId }),
           let cell = cellForParticipant(participant) {

            cell.updatePinButton(self.meeting?.pinnedParticipants.contains(where: { $0.key == participantId }) ?? false)
        }
    }
    
    func onParticipantModeChanged(participantId: String, mode: Mode) {
        print("Participant \(self.participants.first(where: { $0.id == participantId })?.displayName ?? "") mode changed to \(mode.rawValue)")
    }
    
}

// MARK: - ParticipantEventListener

extension MeetingViewController: ParticipantEventListener {
    
    /// Participant has enabled mic, video or screenshare
    /// - Parameters:
    ///   - stream: enabled stream object
    ///   - participant: participant object
    func onStreamEnabled(_ stream: MediaStream, forParticipant participant: Participant) {
        
        if stream.kind == .share {
            // show screen share
            showScreenSharingView(true)
            screenSharingView.showMediastream(stream)
            return
        }
        
        let videoStreams = (participant.streams.filter{ $1.kind == .state(value: .video) }).count
        
        if stream.kind == .state(value: .video)  {
            if videoStreams <= 1 {
                // show stream in cell
                if let cell = self.cellForParticipant(participant) {
                    cell.updateView(forStream: stream, enabled: true)
                }
            }
        } else {
            if let cell = self.cellForParticipant(participant) {
                cell.updateView(forStream: stream, enabled: true)
            }
        }
    
        
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
        
        if stream.kind == .share {
            // hide screen share
            showScreenSharingView(false)
            screenSharingView.hideMediastream(stream)
            return
        }
        
        let videoStreams = (participant.streams.filter{ $1.kind == .state(value: .video) }).count
        
        if stream.kind == .state(value: .video) {
            if videoStreams < 1 {
                // hide stream in cell
                if let cell = self.cellForParticipant(participant) {
                    cell.updateView(forStream: stream, enabled: false)
                }
            }
        } else {
            if let cell = self.cellForParticipant(participant) {
                cell.updateView(forStream: stream, enabled: false)
            }
        }
        
        if participant.isLocal {
            // turn off controls for local participant
            self.buttonControlsView.updateButtons(forStream: stream, enabled: false)
        }
        
        //notification to participants via sharing participants
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "shareParticipants"), object: nil, userInfo: ["participants": self.participants])
    }
}

// MARK: - Chat

extension MeetingViewController {
    
    func openChat() {
        let chatViewController = ChatViewController(meeting: meeting!, topic: CHAT_TOPIC)
        navigationController?.pushViewController(chatViewController, animated: true)
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
                // MARK: - With CustomVideoTrack and multiStream `false`
                guard let customVideoStream = try? VideoSDK.createCameraVideoTrack(encoderConfig: .h480p_w640p, facingMode: .front, multiStream: false) else { return }
                self.meeting?.enableWebcam(customVideoStream: customVideoStream)
                
                // MARK: - Without CustomVideoTrack
                /*self.meeting?.enableWebcam()*/
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
            menuOptions.append(.changeMode)
            
            self.showActionsheet(options: menuOptions, fromView: self.buttonControlsView.menuButton) { option in
                switch option {
                case .switchCamera:
                    self.meeting?.switchWebcam()
                    
                case .startRecording:
                    self.showAlertWithTextField(title: "Enter Webhook Url", value: recordingWebhookUrl) { url in
                        // with config
                        self.meeting?.startRecording(webhookUrl: url!, awsDirPath: "", config: RecordingConfig(layout: ConfigLayout(type: .GRID, priority: .PIN, gridSize: 4), theme: .DARK, mode: .video_and_audio, quality: .med, orientation: .landscape))
                        
                        // without config
                        // self.meeting?.startRecording(webhookUrl: url!)
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
                    
                case .changeMode:
                    if isConference {
                        self.meeting?.changeMode(.VIEWER)
                    } else {
                        self.meeting?.changeMode(.CONFERENCE)
                    }
                    isConference = !isConference
                    
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
    
    func showParticipantControlOptions(_ participant: Participant) {
        guard let cell = cellForParticipant(participant) else { return }
        
        // toggle mic, toggle cam
        var menuOptions: [MenuOption] = [.toggleMic, .toggleWebcam]
        
        // toggle video quality
        if participant.streams.contains(where: { $1.kind == .state(value: .video) }) && !participant.isLocal {
            menuOptions.append(.toggleQuality)
        }
        
        if (self.meeting?.pinnedParticipants.contains(where: { $0.key == participant.id }) ?? false) {
            menuOptions.append(.unpin)
        } else {
            menuOptions.append(.pin)
        }
        
        menuOptions.append(.stats)
        
        // remove
        menuOptions.append(.remove)
        
        self.showActionsheet(options: menuOptions, fromView: cell.menuButton) { option in
            switch option {
            case .toggleMic:
                if !cell.micEnabled {
                    participant.enableMic()
                } else {
                    participant.disableMic()
                }
                
            case .toggleWebcam:
                if !cell.videoEnabled {
                    participant.enableWebcam()
                } else {
                    participant.disableWebcam()
                }
                
            case .remove:
                participant.remove()
                
            case .toggleQuality:
                self.showQualitySelectionsheet(options: [.high, .medium, .low], fromView: cell.menuButton, currentQuality: participant.videoQuality) { quality in
                    
                    // set quality
                    participant.setQuality(quality)
                }
                
            case .pin:
                if !participant.isLocal {
                    participant.pin()
                } else {
                    self.meeting?.localParticipant.pin()
                }
                
            case .unpin:
                if !participant.isLocal {
                    participant.unpin()
                } else {
                    self.meeting?.localParticipant.unpin()
                }
                
            case .stats:
                let statsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController
                statsVC?.participant = participant
                if #available(iOS 15.0, *) {
                    self.presentModal(viewController: statsVC!)
                } else {
                    self.present(statsVC!, animated: true, completion: nil)
                }
                
            default:
                break
            }
        }
    }
}

// MARK: - CollectionViewLayout

private extension MeetingViewController {
    
    func updateCollectionViewLayout() {
        
        /*
         1: Single View (Self)
         2: One-to-One (Vertical Grid)
         3: One-to-Many (2 Horizontal + 1 Vertical)
         4: One-to-Many (2 Horizontal + 2 Vertical)
         */
        
        // inset
        let inset: CGFloat = 3
        // group
        let group = getCollectionViewLayoutGroup(forCount: participants.count)
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        // compositional layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        // invalidate previous layout and set new one
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func getCollectionViewLayoutGroup(forCount count: Int) -> NSCollectionLayoutGroup {
        let inset: CGFloat = 3
        switch count {
        case 1:
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
        case 2:
            let width: NSCollectionLayoutDimension = screenSharingView.isHidden ? .fractionalWidth(1) : .fractionalWidth(0.5)
            let height: NSCollectionLayoutDimension = screenSharingView.isHidden ? .fractionalHeight(0.5) : .fractionalHeight(1)
            
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            if screenSharingView.isHidden {
                return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            } else {
                return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            }
            
        case 3:
            if !screenSharingView.isHidden {
                return getDefaultCollectionViewLayoutGroup()
            }
            
            // item
            let smallItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let smallItem = NSCollectionLayoutItem(layoutSize: smallItemSize)
            smallItem.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // inner group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
            let innerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: innerGroupSize, subitems: [smallItem])
            
            // large item
            let largeItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
            let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)
            largeItem.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // group
            let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            return NSCollectionLayoutGroup.vertical(layoutSize: outerGroupSize, subitems: [innerGroup, largeItem])
            
        default:
            return getDefaultCollectionViewLayoutGroup()
        }
    }
    
    func getDefaultCollectionViewLayoutGroup() -> NSCollectionLayoutGroup {
        let inset: CGFloat = 3
        
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        // inner group
        let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        let innerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: innerGroupSize, subitems: [item])
        
        // group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [innerGroup, innerGroup])
    }
}

// MARK: - Helpers

private extension MeetingViewController {
    
    func setupUI() {
        // initially hide screensharing view
        screenSharingView.isHidden = true
        
        buttonsView.addSubview(buttonControlsView)
        buttonControlsView.frame = buttonsView.bounds
    }
    
    func updateMenuButton() {
        // show enabled when recording or livestream enabled
        buttonControlsView.menuButtonEnabled = (recordingStarted || liveStreamStarted)
    }
    
    func cellForParticipant(_ participant: Participant) -> ParticipantViewCell? {
        if let indexPath = self.indexPaths[participant.id],
           let cell = self.collectionView.cellForItem(at: indexPath) as? ParticipantViewCell {
            return cell
        }
        return nil
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
    
    func addParticipantToGridView() {
        let index = participants.endIndex-1
        
        collectionView.performBatchUpdates {
            self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
        } completion: { completed in
            self.updateCollectionViewLayout()
        }
    }
    
    func removeParticipantFromGridView(at index: Int) {
        collectionView.performBatchUpdates {
            self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        } completion: { completed in
            self.updateCollectionViewLayout()
        }
    }
    
    func showScreenSharingView(_ show: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.screenSharingView.isHidden = !show
        } completion: { completed in
            self.updateCollectionViewLayout()
        }
    }
}
