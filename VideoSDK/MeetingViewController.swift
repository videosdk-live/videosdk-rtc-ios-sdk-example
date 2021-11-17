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

struct MeetingData {
    let token: String
    let name: String
    let meetingId: String
    let micEnabled: Bool
    let cameraEnabled: Bool
}

enum MenuOption: String {
    case startRecording = "Start Recording"
    case stopRecording = "Stop Recording"
    case startLivestream = "Start Livestream"
    case stopLivestream = "Stop Livestream"
    
    var style: UIAlertAction.Style {
        switch self {
        case .startRecording, .startLivestream:
            return .default
        case .stopRecording, .stopLivestream:
            return .destructive
        }
    }
}

private let reuseIdentifier = "ParticipantViewCell"
private let addStreamOutputSegueIdentifier = "Add Livestream Outputs"
private let recordingWebhookUrl = "https://www.google.com"

class MeetingViewController: UIViewController, UICollectionViewDataSource {
    
    // MARK: - View
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var screenSharingView: ScreenSharingView!
    
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
    
    
    // MARK: - Life Cycle
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup
        setupUI()
        setupActions()
        addAudioChangeObserver()
        
        // config
        VideoSDK.config(token: meetingData.token)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // init meeting
        initializeMeeting()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        meeting = nil
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
        
        // set
        cell.setParticipant(participant)
        
        return cell
    }
}

// MARK: - MeetingEventListener

extension MeetingViewController: MeetingEventListener {
    
    /// Meeting started
    func onMeetingJoined() {
        
        // handle local participant on start
        guard let localParticipant = self.meeting?.localParticipant else { return }
        
        // add to list
        participants.append(localParticipant)
        
        // add event listener
        localParticipant.addEventListener(self)
        
        // show in ui
        addParticipantToGridView()
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
        
        // show stream in cell
        if let cell = self.cellForParticipant(participant) {
            cell.updateView(forStream: stream, enabled: true)
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
        
        if stream.kind == .share {
            // hide screen share
            showScreenSharingView(false)
            screenSharingView.hideMediastream(stream)
            return
        }
        
        // hide stream in cell
        if let cell = self.cellForParticipant(participant) {
            cell.updateView(forStream: stream, enabled: false)
        }
        
        if participant.isLocal {
            // turn off controls for local participant
            self.buttonControlsView.updateButtons(forStream: stream, enabled: false)
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
            self.meeting?.leave()
        }
        
        // onCameraTapped
        buttonControlsView.onCameraTapped = { position in
            self.meeting?.switchWebcam(position: position)
        }
        
        /// Menu tap
        buttonControlsView.onMenuButtonTapped = {
            var menuOptions: [MenuOption] = []
            menuOptions.append(!self.recordingStarted ? .startRecording : .stopRecording)
            menuOptions.append(!self.liveStreamStarted ? .startLivestream : .stopLivestream)
            
            self.showActionsheet(options: menuOptions, fromView: self.buttonControlsView.menuButton) { option in
                switch option {
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
        
        view.addSubview(buttonControlsView)
        
        buttonControlsView.translatesAutoresizingMaskIntoConstraints = false
        buttonControlsView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        buttonControlsView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        buttonControlsView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        buttonControlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        
        view.bringSubviewToFront(buttonControlsView)
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
