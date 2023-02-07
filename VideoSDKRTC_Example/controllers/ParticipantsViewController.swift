//
//  ParticipantsViewController.swift
//  VideoSDKRTC_Example
//
//  Created by Parth Asodariya on 31/01/23.
//

import Foundation
import UIKit
import VideoSDKRTC

class ParticipantsViewController: UIViewController {
 
    
    @IBOutlet weak var lblParticipants: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tblParticipantsView: UITableView?
    
    /// video participants including self to show in Grid
    var participants: [Participant] = []
    
    init(participants: [Participant]) {
        self.participants = participants
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        mainView.roundCorners(corners: [.topLeft,.topRight], radius: 20)
        lblParticipants.text = "Participants (\(participants.count))"
        
        // removing any existing observer for 'shareParticipants'
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "shareParticipants"), object: nil)
        // adding new observer for 'shareParticipants'
        NotificationCenter.default.addObserver(self, selector: #selector(notifyParticipants(_:)), name: NSNotification.Name(rawValue: "shareParticipants"), object: nil)
    }

    @IBAction func btnClose_Clicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func notifyParticipants(_ notification:NSNotification)
    {
        if let updatedParticipants = notification.userInfo!["participants"] as? [Participant] {
            self.participants = updatedParticipants
            self.tblParticipantsView?.reloadData()
      }
    }
}

extension ParticipantsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let participantCell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCellView", for: indexPath) as! ParticipantCellView
        
        participantCell.setupUI(participants[indexPath.row])
        
        return participantCell
    }
    
}
