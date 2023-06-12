//
//  ParticipantStatsCellView.swift
//  VideoSDK_Example
//
//  Created by Parth Asodariya on 12/06/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class ParticipantStatsCellView: UITableViewCell {

    @IBOutlet weak var lblStatsHeader: UILabel!
    @IBOutlet weak var lblAudioValue: UILabel!
    @IBOutlet weak var lblVideoValue: UILabel!
    @IBOutlet weak var cellStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
