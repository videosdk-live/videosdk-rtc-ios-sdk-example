//
//  ParticipantsViewController.swift
//  VideoSDK_Example
//
//  Created by Milan Patoliya on 25/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import VideoSDKRTC

class ParticipantsViewController: UIViewController {
 
    
    @IBOutlet weak var lblParticipants: UILabel!
    @IBOutlet weak var mainView: UIView!
    //@IBOutlet weak var tblParticipantsView: UITableView?
    
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
        mainView.roundCorners([.topLeft,.topRight], radius: 20)
        lblParticipants.text = "Participants (\(participants.count))"
    }

    @IBAction func btnClose_Clicked(_ sender: Any) {
        self.dismiss(animated: true)
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
