//
//  MeetingViewController.swift
//  VideoSDK_Example
//
//  Created by VideoSDK Team Team on 13/09/21.
//  Copyright © 2021 Zujo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import VideoSDK
import AVFoundation

struct MeetingData {
    let token: String
    let name: String
    let meetingId: String
    let micEnabled: Bool
    let cameraEnabled: Bool
}

private let reuseIdentifier = "ParticipantViewCell"

class MeetingViewController: UICollectionViewController {
    
    // MARK: - View
    
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

// MARK: - MeetingEventListener, ParticipantEventListener

extension MeetingViewController: MeetingEventListener, ParticipantEventListener {
    
    /// Meeting started
    func onMeetingJoined() {
        
        // show local participant in the grid if available
        guard let localParticipant = self.meeting?.localParticipant else { return }
        
        // event listener for self
        localParticipant.addEventListener(self)
        
        // add to list and show in grid
        participants.append(localParticipant)
        addParticipantToGridView()
    }
    
    /// Meeting ended
    func onMeetingLeft() {
        // remove listeners
        meeting?.localParticipant.removeEventListener(self)
        meeting?.removeEventListener(self)
        
        // dismiss
        dismiss(animated: true, completion: nil)
    }
    
    /// A new participant joined
    func onParticipantJoined(_ participant: Participant) {
        // add listener
        participant.addEventListener(self)
        
        // add new participant to list and show in grid
        participants.append(participant)
        addParticipantToGridView()
    }
    
    /// A participant left from the meeting
    /// - Parameter participant: participant object
    func onParticipantLeft(_ participant: Participant) {
        // remove listener
        participant.removeEventListener(self)
        
        // remove from list and update ui
        guard let index = self.participants.firstIndex(where: { $0.id == participant.id }) else {
            return
        }
        
        // remove participant from list and grid
        participants.remove(at: index)
        removeParticipantFromGridView(at: index)
    }
    
    /// Participant has enabled mic, video or screenshare
    /// - Parameters:
    ///   - stream: enabled stream object
    ///   - participant: participant object
    func onStreamEnabled(_ stream: MediaStream, forParticipant participant: Participant) {
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
        
        /// Mic tap
        buttonControlsView.onMicTapped = { on in
            if on {
                self.meeting?.muteMic()
            } else {
                self.meeting?.unmuteMic()
            }
        }
        
        /// Video tap
        buttonControlsView.onVideoTapped = { on in
            if on {
                self.meeting?.disableWebcam()
            } else {
                self.meeting?.enableWebcam()
            }
        }
        
        /// End Tap
        buttonControlsView.onEndMeetingTapped = {
            self.meeting?.leave()
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
        
        var group: NSCollectionLayoutGroup!
        
        switch participants.count {
        case 1:
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
        case 2:
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.45))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
        case 3:
            // item
            let smallItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let smallItem = NSCollectionLayoutItem(layoutSize: smallItemSize)
            smallItem.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // inner group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.45))
            let innerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: innerGroupSize, subitems: [smallItem])
            
            // large item
            let largeItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.45))
            let largeItem = NSCollectionLayoutItem(layoutSize: largeItemSize)
            largeItem.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // group
            let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            group = NSCollectionLayoutGroup.vertical(layoutSize: outerGroupSize, subitems: [innerGroup, largeItem])
            
        case 4:
            // item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            // inner group
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
            let innerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: innerGroupSize, subitems: [item])
            
            // group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [innerGroup, innerGroup])
            
        default:
            break
        }
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        // compositional layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        // invalidate previous layout and set new one
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
}

// MARK: - Helpers

private extension MeetingViewController {
    
    func setupUI() {
        view.addSubview(buttonControlsView)
        
        buttonControlsView.translatesAutoresizingMaskIntoConstraints = false
        buttonControlsView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        buttonControlsView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        buttonControlsView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        buttonControlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        
        view.bringSubviewToFront(buttonControlsView)
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
}
